classdef DiagP < DiagPredicate
    % class P
    % properties: f : composed predicate 
    % methods: Tconstraints, Fconstraints: Decomposes the predicate
    %           function and produces a set of yalmip constraints

    properties
        f
    end
    
    methods
        function self = DiagP(f)
            self.f = extract_function(f);
        end
        
        function [C, predNode] = enforce(self, dt, l0, l1, t0, t1, nodeID)
            l1 = l0+round((l1-l0)/dt)*dt;
            t0 = max(t0, l0);
            t1 = min(t1, l1);
            C = [];
            
            predNode = STLnode('phi', nodeID);
            constrSet = [];
            
            for i=0:round((t1-t0)/dt)
                t = t0+i*dt;
                
                init = length(C);
                C = [C, self.f(t, dt)];  %#ok<AGROW>
                constrSet = [constrSet setsCons(i+1, length(C) - init)];
                
            end
            
            predNode.consBreakUp = constrSet;
            predNode.STLinterval = [0 0];
            predNode.childNodes = [-1];
            
        end
        
        function [C,predNode] = Tconstraints(self, T, dt, t0, nodeID)
            C = [];
            
            predNode = STLnode('phi', nodeID);
            constrSet = [];
            
            for i=1:numel(T)
                t = t0+(i-1)*dt;
                init = length(C);
                C = [C, implies(T(i), self.f(t, dt))]; %#ok<AGROW>
                constrSet = [constrSet setsCons(i, length(C)-init)];
            end
            
            predNode.consBreakUp = constrSet;
            predNode.STLinterval = [0 0];
            predNode.childNodes = [-1];
        end
        
        function C = Trobust(self, T, dt, t0)
            C = [];
            for i=1:numel(T)
                t = t0+(i-1)*dt;
                C = [C, sdpvar(self.f(t, dt))>=T(i)]; %#ok<AGROW>
            end
        end
    
        function [C, predNode] = Fconstraints(self, F, dt, t0, nodeID)
            C = [];
            
            predNode = STLnode('phi', nodeID);
            constrSet = [];
            
            for i=1:numel(F)
                t = t0+(i-1)*dt;
                init = length(C);
                C = [C, implies(self.f(t, dt), false(F(i)))]; %#ok<AGROW>
                constrSet = [constrSet setsCons(i, length(C)-init)];
            end
            
            predNode.consBreakUp = constrSet;
            predNode.STLinterval = [0 0];
            predNode.childNodes = [-1];
        end
        
        function C = Frobust(self, F, dt, t0)
            C = [];
            for i=1:numel(F)
                t = t0+(i-1)*dt;
                C = [C, -sdpvar(self.f(t, dt))>=F(i)]; %#ok<AGROW>
            end
        end
    end
end

