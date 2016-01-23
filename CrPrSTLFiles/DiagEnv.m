%% This is the object definition for a diagnosis object for CrPrSTL systems

classdef DiagEnv
    properties
        CrPrSTLenv 
        pathToController
        STLparseTrees
        isAuto
        autoInfo
    end
    methods
        function diagObject = DiagEnv(CrPrSTLenv, pathToController, isAuto, autoInfo)
            diagObject.CrPrSTLenv = CrPrSTLenv;
            diagObject.pathToController = pathToController;
            diagObject.isAuto = isAuto;
            diagObject.autoInfo = autoInfo;
        end
        
        function Diagrun_closed_loop(self, L, t1, t2)
            env = self.CrPrSTLenv;
            dt = env.get_dt();
            plotter = env.get_plotter();
            for i = 1:numel(env.systems)
                env.systems(i) = Diaginitialize(self, env.systems(i), t1);
            end
            for t = t1:dt:t2
    
                for i = 1:numel(env.systems)
                    
                    [env.systems(i), isFail] = Diagfind_control(self, env.systems(i), L, t);
                    
                    if isFail 
                        break;
                    end
                end
                plotter.capture_past(t);
                plotter.capture_future(t:dt:t+L*dt);
                if isFail 
                    break;
                end
                drawnow;
                if t==t1
                    if ~isempty(plotter.fig)
                        env.movie = getframe(plotter.fig);
                    end
                else
                    if ~isempty(plotter.fig)
                        env.movie(end+1) = getframe(plotter.fig);
                    end
                end
                for i = 1:numel(env.systems)
                    env.systems(i).advance(t);
                end
            end
        end
        
        function system = Diaginitialize(diagObject, system, t)
            system.history = struct('t', [], 'x', [], 'u', [], 'y', []);
            DiagMinimize(system, t, system.dt, DiagAndPredicate(system.constraints{:}));
            system.history.x(:, end+1) = value(system.x(t));
            system.history.t(:, end+1) = t;
        end
        
        function [system, isFail] = Diagfind_control(diagObject, system, L, t)
            isFail = 0;
            x0 = system.history.x(:, end);
            u0 = value(system.u(t));
            if size(system.history.u, 2)>0
                u0 = system.history.u(:, end);
            end
            T1 = max(t-system.dt*L, system.history.t(1));
            T2 = t+system.dt*L;
            past = T1:system.dt:t-system.dt;
            past_ind = max(length(system.history.t)-L, 1):length(system.history.t)-1;
            x_past = system.history.x(:, [past_ind length(system.history.t)]);
            u_past = system.history.u(:, past_ind);
            y_past = system.history.y(:, past_ind);
            keep_past = DiagP(@(tprime, dt) system.x([past t])==x_past);
            if ~isempty(past)
                keep_past = DiagAndPredicate(keep_past, DiagP(@(t, dt) system.u(past)==u_past), DiagP(@(t, dt) system.y(past)==y_past));
            end
            if isa(system.dynamics, 'DiagPredicate')
                dynamics = system.dynamics; %#ok<PROP>
            else
                dynamics = system.dynamics.local_dynamics(system.dt, x0, u0, t, system.x, system.u, system.y); %#ok<PROP>
            end
            dynamic_constraints = {};
            for i = 1:length(system.dyn_constraints)
                dynamic_constraints{i} = system.dyn_constraints{i}(x0, t, system.dt); %#ok<AGROW>
            end
            dyn_constraint = diagalways(DiagAndPredicate(dynamic_constraints{:}), t-T1, t-T1);
            nodeID = 0;
            STLparseTrees = [];
            for i = 1 : length(system.constraints)
                [C, STLparseTreeNodes] = system.constraints{i}.enforce(system.dt, T1, T2, T1, T1, nodeID);
                STLparseTrees = [STLparseTrees parseTree(STLparseTreeNodes)];
            end
            for i = 1 : length(STLparseTrees)
                j = length(STLparseTrees(i).STLnodes);
                while j >= 1
                    if strcmp(STLparseTrees(i).STLnodes(j).nodeType, 'phi') ~= 1
                        if strcmp(STLparseTrees(i).STLnodes(j).nodeType, 'always') == 1 || strcmp(STLparseTrees(i).STLnodes(j).nodeType, 'eventually') == 1 || strcmp(STLparseTrees(i).STLnodes(j).nodeType, 'until') == 1
                            STLparseTrees(i).STLnodes(j).STLinterval(2) = min(L+1, STLparseTrees(i).STLnodes(j).STLinterval(2));
                        end
                        for k = 1 : length(STLparseTrees(i).STLnodes(j).childNodes)
                            childPos = STLparseTrees(i).STLnodes(j).nodeID - STLparseTrees(i).STLnodes(j).childNodes(k);
                            STLparseTrees(i).STLnodes(j - childPos).support = STLparseTrees(i).STLnodes(j).support + STLparseTrees(i).STLnodes(j).STLinterval;
                            if STLparseTrees(i).STLnodes(j-childPos).support(1) > L + 1
                                STLparseTrees(i).STLnodes(j-childPos).support(1) = L + 1;
                            end
                            if STLparseTrees(i).STLnodes(j-childPos).support(2) > L + 1
                                STLparseTrees(i).STLnodes(j-childPos).support(2) = L + 1;
                            end
                        end
                    end
                    j = j - 1;              
                end
            end
            [diag, STLnodes] = DiagMinimize(system, T1:system.dt:T2, system.dt, DiagAndPredicate(system.constraints{:}, diagalways(dynamics, t-T1, inf), keep_past, dyn_constraint)); %#ok<PROP>
            k = 1;
            for i = 1 : length(STLparseTrees)
                for j = 1 : length(STLparseTrees(i).STLnodes)
                    STLparseTrees(i).STLnodes(j).consBreakUp = STLnodes(k).consBreakUp;
                    k = k + 1;
                    if strcmp(STLparseTrees(i).STLnodes(j).nodeType, 'phi') == 1
                        if STLparseTrees(i).STLnodes(j).support(1) == 0 && STLparseTrees(i).STLnodes(j).support(2) == 0
                            STLparseTrees(i).STLnodes(j).support(1) = 1;
                            STLparseTrees(i).STLnodes(j).support(2) = 1;
                        end
                    end
                    if length(STLparseTrees(i).STLnodes(j).consBreakUp) > STLparseTrees(i).STLnodes(j).support(2)
                        r = length(STLparseTrees(i).STLnodes(j).consBreakUp);
                        s = STLparseTrees(i).STLnodes(j).support(2);
                        while r >= 1
                            if s == 0
                                s = s-1;
                            end
                            
                            STLparseTrees(i).STLnodes(j).consBreakUp(r).t = s;
                            s = s-1;
                            r = r-1;
                            
                        end
                    end
                end
            end
            if diag.problem
                fprintf('Model is infeasible at time %0.2f\n', t);
                gurobi_write(diag.solverinput.model, diagObject.pathToController);
                diagObject.STLparseTrees = STLparseTrees;
                DRobject = DiagRepairObject(diagObject.STLparseTrees, diagObject.pathToController, 0, diagObject.isAuto, diagObject.autoInfo);
                DRobject = DiagnosisRepair(DRobject);
                feedbackSTLparseTrees(DRobject.STLparseTrees, system.dt, L);
                isFail = 1;
            end
            system.history.u(:, end+1) = value(system.u(t));
            system.history.y(:, end+1) = value(system.y(t));
        end
        
        
    end
end

function [result, STLnodes] = DiagMinimize(varargin)
    [system, dt, ts, p] = Diagextract_args(varargin{:});
    [C, STLnodes] = p.enforce(dt, ts(1), ts(end), ts(1), ts(1), 0);
    V = system.objective.value(ts,dt);
    [result, reordering, expandedConstrMapping, mapImpliesF] = optimizeWithFeedback(C, V, sdpsettings('solver', 'gurobi', 'savesolveroutput', 1, 'savesolverinput', 1));
    reorderingUpdate = UpdateReordering(STLnodes, mapImpliesF);
    STLnodes = UpdateParseTree(reorderingUpdate, reordering, expandedConstrMapping, STLnodes);
end

function [system, dt, ts, p] = Diagextract_args(varargin)
    if isa(varargin{end}, 'DiagPredicate')
        system = varargin{1};
        dt = extract_dt(varargin{2:end-1});
        ts = varargin{2};
        p = varargin{end};
    else
        system = varargin{1};
        dt = extract_dt(varargin{1:end});
        ts = varargin{2};
        p = DiagAndPredicate();
    end
end