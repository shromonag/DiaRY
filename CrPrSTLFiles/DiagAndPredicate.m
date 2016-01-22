classdef DiagAndPredicate < DiagPredicate
    % class: AndPredicate
    % properties: ps: a set of predicates 
    % methods: Tconstraints, Fconstraints: Defines yalmip constraints for
    %           satisfaction of AndPredicate.
    
    properties
        ps
    end
    methods
        function self = DiagAndPredicate(varargin)
            self.ps = varargin;
        end
         function [C, STLnodes] = enforce(self, dt, l0, l1, t0, t1, nodeID)
             C = [];
             childNodes = [];
             childSTLnodes = [];
             for i = 1:numel(self.ps)
                 [Cnode, STLnodes] = self.ps{i}.enforce(dt, l0, l1, t0, t1, nodeID);
                 childNodes = [childNodes STLnodes(end).nodeID];
                 childSTLnodes = [childSTLnodes STLnodes];
                 nodeID = STLnodes(end).nodeID + 1;
                 C = [C Cnode]; %#ok<AGROW>
             end
             andNode = STLnode('and', nodeID);
             andNode.childNodes = childNodes;
             andNode.STLinterval = [0 0];
             STLnodes = [childSTLnodes andNode];
         end
        function [C, STLnodes] = Tconstraints(self, T, dt, t0, nodeID)
            C = [];
            childNodes = [];
            childSTLnodes = [];
            for i = 1:numel(self.ps)
                [Cnode, STLnode] = self.ps{i}.Tconstraints(T, dt, t0, nodeID);
                childNodes = [childNodes nodeID];
                childSTLnodes = [childSTLnodes STLnodes];
                nodeID = STLnode(end).nodeID + 1;
                C = [C, Cnode]; %#ok<AGROW>
            end
            andNode = STLnode('and', nodeID);
            andNode.childNodes = childNodes;
            andNode.STLinterval = [0 0];
            STLnodes = [childSTLnodes andNode];
        end
        function C = Trobust(self, T, dt, t0)
            C = [];
            for i = 1:numel(self.ps)
                C = [C, self.ps{i}.Trobust(T, dt, t0)]; %#ok<AGROW>
            end
        end
        function [C, STLnodes] = Fconstraints(self, F, dt, t0, nodeID)
            C = [];
            Fsum = 0;
            childNodes = [];
            childSTLnodes = [];
            for i = 1:numel(self.ps)
                Fp = binvar(1, numel(F));
                Fsum = Fsum + Fp;
                [Cnode, STLnodes] = self.ps{i}.Fconstraints(Fp, dt, t0,nodeID)
                childNodes = [childNodes nodeID];
                childSTLnodes = [childSTLnodes STLnodes];
                nodeID = STLnodes(end).nodeID + 1;
                C = [C, Cnode];  %#ok<AGROW>
            end
            andNode = STLnode('and', nodeID);
            andNode.childNodes = childNodes;
            andNode.STLinterval = [0 0];
            
            init = length(C);
            C = [C, F<=Fsum];
            constrSet = setsCons(0, length(C)-init);
            andNode.consBreakUp = constrSet;
            
            STLnodes = [childSTLnodes andNode];
        end
        % TODO: for implementing adversarial agents
        function C = Frobust(self, F, dt, t0)
            C = [];
            Fps = {};
            for i = 1:numel(self.ps)
                Fp = sdpvar(1, numel(F));
                Fps = [Fmax {Fp}]; %#ok<AGROW>
                C = [C, self.ps{i}.Frobust(Fp, dt, t0)]; %#ok<AGROW>
            end
            C = [C, max_ge(Fps, F)];
        end
        %function C = forced_constraints(self, dt, L_start, L_end, t_start, t_end)
        %    C = [];
        %    for i = 1:numel(self.ps)
        %        C = [C, self.ps{i}.forced_constraints(dt, L_start, L_end, t_start, t_end)]; %#ok<AGROW>
        %    end
        %end
    end
end