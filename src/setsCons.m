%% Object definition for sets of constraints

classdef setsCons 
    properties
        % Time
        t
        % Number of Constraints
        cons
        % Actual constraints in MILP
        consList
        % Slack added
        slack 
    end
    methods
        function setsofCons = setsCons(t, cons)
            setsofCons.t = t;
            setsofCons.cons = cons;
            setsofCons.slack = 0;
        end
    end
end