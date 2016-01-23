function result = standard_normal(varargin)
    % function: standard_normal
    % input: varargin: size of the normal variable
    % output: Normal random variable with mu = 0 and variance = I

    % Registary of all normal variables in constraints:
    global NORMALS_MAP;
    if isempty(NORMALS_MAP)
        NORMALS_MAP = containers.Map('KeyType', 'int64', 'ValueType', 'any');
    end
    if numel(varargin)==1
        result = sdpvar(varargin{1}, 1);
    else
        result = sdpvar(varargin{:});
    end
    for xnum = depends(result) % depends: Gives the yalmip index of all variables that a constraint depends on
        %recover = inverse(depends) : goes from yalmip index to the variables
        NORMALS_MAP(xnum) = recover(xnum);
    end
end