function C = normal_constraints(p)
    % function: normal_constraints: Defines probabilistic yalmip constraints 
    %           that are normal.
    % input: p
    % output: C : Yalmip constraints corresponding to the Normal random
    %             variable.
    
    % NORMALS_MAP: registery having all the indices of all normal variables
    global NORMALS_MAP;
    if ~isempty(NORMALS_MAP)
        % variables that predicate p depends on:
        vars = depends(p);
        vars = vars(NORMALS_MAP.isKey(num2cell(vars)));
        % decleration that C is a normal constraint for yalmip
        C = uncertain(recover(vars), 'normal', zeros(length(vars), 1), eye(length(vars)));
    else
        C = [];
    end
end

