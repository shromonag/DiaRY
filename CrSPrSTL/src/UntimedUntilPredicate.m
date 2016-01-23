classdef UntimedUntilPredicate < Predicate
    % class: UntimedUntilPredicate
    % properties: p,q,shift: pUq, We might want to satisfy it at t=shift,
    % instead of t =0
    % methods: Tconstraints, Fconstraints: Defines yalmip constraints for
    %           satisfaction of UntimedUntilPredicate.
    
    properties
        p
        q
        shift
    end
    
    methods
        function self = UntimedUntilPredicate(p, q, shift)
            self.p = p;
            self.q = q;
            switch (nargin)
                case 3
                    self.shift = shift;
                case 2
                    self.shift = 0;
                otherwise
                    error('Invalid number of arguments')
            end
        end
        function C = Tconstraints(self, T, dt, t0)
            a = min(round(self.shift/dt), numel(T));
            Tp = binvar(1, numel(T));
            Tq = binvar(1, numel(T));
            C = [self.p.Tconstraints(Tp, dt, t0) self.q.Tconstraints(Tq, dt, t0)];
            Z = binvar(1, numel(T));
            C = [C, Z<=[Tq(1+a:end), ones(1, a)]+[T(2:end), 1]];
            C = [C, T<=Z, T<=[Tp(1+a:end), ones(1, a)]];
        end
        
        function C = Trobust(self, t, dt, t0)
            error('Not implemented yet');
        end
        
        function C = Fconstraints(self, F, dt, t0)
            a = min(round(self.shift/dt), numel(F));
            Fp = binvar(1, numel(F));
            Fq = binvar(1, numel(F));
            C = [self.p.Fconstraints(Fp, dt, t0) self.q.Fconstraints(Fq, dt, t0)];
            Z = binvar(1, numel(F));
            C = [C, Z<=[Fq(1+a:end), ones(1, a)], Z<=[F(2:end), 1]];
            C = [C, F<=Z+[Fp(1+a:end), ones(1, a)]];
        end
        
        function C = Frobust(self, F, dt, t0)
            error('Not implemented yet!');
        end
        
        %function C = forced_constraints(varargin) %#ok<STOUT>
        %    error('Forced constraints cannot be implemented for not!');
        %end
    end
    
end

