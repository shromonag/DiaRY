classdef DiagNotPredicate < DiagPredicate
    % class: NotPredicate
    % properties: p: predicate
    % methods: Tconstraints, Fconstraints: Defines yalmip constraints for
    %           satisfaction of NotPredicate.

    properties
        p
    end
    
    methods
        function self = DiagNotPredicate(p)
            self.p = p;
        end
        function [C, STLnodes] = Tconstraints(self, T, dt, t0, nodeID)
            [C, childNode] = self.p.Fconstraints(T, dt, t0, nodeID);
            notNode = STLnode('not', childNode(end).nodeID+1);
            notNode.STLinterval = [0 0];
            notNode.childNodes = [childNode(end).nodeID];
            STLnodes = [childNode notNode];
        end
        function C = Trobust(self, T, dt, t0)
            C = self.p.Frobust(T, dt, t0);
        end
        function [C, STLnodes] = Fconstraints(self, F, dt, t0, nodeID)
            [C, childNode] = self.p.Tconstraints(F, dt, t0, nodeID);
            notNode = STLnode('not', childNode(end).nodeID+1);
            notNode.STLinterval = [0 0];
            notNode.childNodes = [childNode(end).nodeID];
            STLnodes = [childNode notNode];
        end
        function C = Frobust(self, F, dt, t0)
            C = self.p.Trobust(F, dt, t0);
        end
        %function C = forced_constraints(varargin) %#ok<STOUT>
        %    error('Forced constraints cannot be implemented for not!');
        %end
    end
    
end

