classdef ProbabilisticPredicate < Predicate
    % class: ProbabilisticPredicate
    % properties: f, pr: inner predicate, threshold on the probability
    % methods: Tconstraints, Fconstraints: Defines yalmip constraints for
    %           satisfaction of ProbabilisticPredicate.

    properties
        f 
        pr 
    end
    
    methods
        function self = ProbabilisticPredicate(f, pr)
            self.f = extract_function(f); % inner predicate: can be a function of time
            self.pr = extract_function(pr); % threshold on probability: can be a function of time
        end
        function C = enforce(self, dt, l0, l1, t0, t1)
            l1 = l0+round((l1-l0)/dt)*dt;
            t0 = max(t0, l0);
            t1 = min(t1, l1);
            C = [];
            for i=0:round((t1-t0)/dt)
                t = t0+i*dt;
                constraint = sdpvar(self.f(t, dt))>=0;
                nC = normal_constraints(constraint);
                if ~isempty(nC)
                    C = [C derandomize([probability(constraint)>=self.pr(t, dt) nC])]; %#ok<AGROW>
                else
                    C = [C constraint]; %#ok<AGROW>
                end
            end
        end
        function C = Tconstraints(self, T, dt, t0)
            C = [];
            for i=1:numel(T)
                t = t0+(i-1)*dt;
                constraint = sdpvar(self.f(t, dt))>=0;
                % Defining Normal constraints: specifying variables that
                % are normal
                nC = normal_constraints(constraint);
                if ~isempty(nC)
                    % derandomize: given uncertain constraints or other =>
                    % generates yalmip constraints without probability
                    C = [C implies(T(i), derandomize([probability(constraint)>=self.pr(t, dt) nC]))]; %#ok<AGROW>
                else
                    C = [C implies(T(i), constraint)]; %#ok<AGROW>
                end
            end
        end
        
        function C = Trobust(self, T, dt, t0)
            error('Not implemented yet');
        end
            
        function C = Fconstraints(self, F, dt, t0)
            C = [];
            for i=1:numel(F)
                t = t0+(i-1)*dt;
                constraint = sdpvar(self.f(t))<=0; % Negating the probabilistic constraint
                nC = normal_constraints(constraint);
                if ~isempty(nC)
                    C = [C implies(F(i), derandomize([probability(constraint)>=self.pr(t, dt) nC]))]; %#ok<AGROW>
                else
                    C = [C implies(F(i), constraint)]; %#ok<AGROW>
                end
            end
        end
        
        function C = Frobust(self, F, dt, t0)
            error('Not implemented yet');
        end
    end
end

