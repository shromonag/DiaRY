function f = extract_function(input)
    % function: extract_function
    % input: string, function of time, single value
    % output: function(t,dt)
    
    if isa(input, 'char')
        try
            f = evalin('caller', 'evalin(''caller'', [''@(t, dt) '' input])');
            f(0, 0);
        catch
            f = evalin('base', ['@(t, dt) ' input]);
        end
    elseif isa(input, 'function_handle')
        switch nargin(input)
            case 0
                f = @(t, dt) input();
            case 1
                f = @(t, dt) input(t);
            otherwise
                f = input;
        end
    else
        f = @(t, dt) input;
    end
end

