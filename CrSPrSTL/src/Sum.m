classdef Sum < Objective
    % class: Sum
    % properties: f
    % methods: value: Given an objective function, it adds them up for a
    % time horizon
    properties
        f
    end
    
    methods
        function self = Sum(f)
            if nargin == 0
                self.f = @(t, dt) 0.;
            else
                self.f = extract_function(f);
            end
        end
        function result = value(self, varargin)
            dt = extract_dt(varargin{:});
            result = 0;
            for t = varargin{1}
                result = result + self.f(t, dt);
            end
        end
    end
end

