function result = extract_dt(ts, dt)
    % function: extract_dt
    % input: ts, dt
    % output: dt, it is 1 if not specified.
    
    if nargin>=2
        result = dt;
    elseif numel(ts)>=2
        result = ts(2)-ts(1);
    else
        result = 1.;
    end
end

