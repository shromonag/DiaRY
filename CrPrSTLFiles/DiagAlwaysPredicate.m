classdef DiagAlwaysPredicate < DiagPredicate
    % class: AlwaysPredicate: G_[t1,t2] p, Gp = G_[0,inf] p
    % properties: predicate, time bounds [t1,t2]
    % methods: Tconstraints, Fconstraints: Defines yalmip constraints for
    %           satisfaction of AlwaysPredicates.

    properties
        p
        t1
        t2
    end
    
    methods
        function self = DiagAlwaysPredicate(p, t1, t2)
            self.p = p;
            switch (nargin)
                case 3
                    self.t1 = t1;
                    self.t2 = t2;
                case 1
                    self.t1 = 0;
                    self.t2 = inf;
                otherwise
                    error('Invalid number of parameters')
            end
        end
        
        function [C, STLnodes] = enforce(self, dt, l0, l1, t0, t1, nodeID)
            [C, childSTLnode] = self.p.enforce(dt, l0, l1, t0+self.t1, t1+self.t2, nodeID);
            nodeID = childSTLnode(end).nodeID + 1;
            alwaysNode = STLnode('always', nodeID);
            alwaysNode.STLinterval = [round(self.t1/dt)+1 round(self.t2/dt)+1];
            alwaysNode.childNodes = childSTLnode(end).nodeID;
            STLnodes = [childSTLnode alwaysNode];
        end
        
        function [C, STLnodes] = Tconstraints(self, T, dt, t0, nodeID)
            a = round(self.t1/dt);
            b = round(self.t2/dt);
            Tp = binvar(1, numel(T));
            [C, childNode] = self.p.Tconstraints(Tp, dt, t0,nodeID);
            alwaysNode = STLnode('always', childNode(end).nodeID+1);
            alwaysNode.STLinterval = [round(self.t1/dt)+1 round(self.t2/dt)+1];
            alwaysNode.childNodes = childNode(end).nodeID;
            constrSet = [];
            for t = a:min(b, numel(T)-1)
                init = length(C);
                C = [C, T(1:end)<=[Tp(1+t:end), ones(1, t)]]; %#ok<AGROW>
                constrSet = [constrSet setsCons(t+1, length(C)-init)];
            end
            alwaysNode.consBreakUp = constrSet;
            STLnodes = [childNode alwaysNode];
        end
        
        function C = Trobust(self, T, dt, t0)
            a = round(self.t1/dt);
            b = round(self.t2/dt);
            Tp = sdpvar(1, numel(T));
            Tps = {};
            C = self.p.Trobust(Tp, dt, t0);
            for t = a:min(b, numel(T)-1)
                Tps = [Tps {Tp(1+t:end)}]; %#ok<AGROW>
            end
            C = [C, min_ge(Tps, T)];
        end
        
        function [C, STLnodes] = Fconstraints(self, F, dt, t0, nodeID)
            a = round(self.t1/dt);
            b = round(self.t2/dt);
            Fp = binvar(1, numel(F));
            [C, childNode] = self.p.Fconstraints(Fp, dt, t0, nodeID);
            alwaysNode = STLnode('always', childNode(end).nodeID+1);
            alwaysNode.STLinterval = [round(self.t1/dt)+1 round(self.t2/dt)+1];
            alwaysNode.childNodes = childNode(end).nodeID;
            
            Fsum = 0;
            for t = a:min(b, numel(F))
                % Being optimistic about future
                Fsum = Fsum + [Fp(1+t:end), ones(1, t)];
            end
            init = length(C);
            C = [C, F<=Fsum];
            alwaysNode.consBreakUp = setsCons(0, length(C)-init);
            STLnodes = [childNode alwaysNode];
        end
        % TODO: For implementing adversarial agents
        function C = Frobust(self, F, dt, t0)
            a = round(self.t1/dt);
            b = round(self.t2/dt);
            Fp = sdpvar(1, numel(F));
            C = self.p.Frobust(Fp, dt, t0);
            Fps = {};
            for t = a:min(b, numel(F))
                Fps = [Fps {Fp(1+t:end)}];
            end
            C = [C, max_ge(Fps, F)];
        end
        
        %function C = forced_constraints(self, dt, L_start, L_end, t_start, t_end)
        %    C = self.p.forced_constraints(dt, L_start, L_end, t_start+self.t1, t_end+self.t2);
        %end
    end
    
end

