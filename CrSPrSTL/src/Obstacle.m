classdef Obstacle
    %OBSTACLE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        f
    end
    
    methods
        function self = Obstacle(obstacle)
            if isa(obstacle, 'function_handle')
                switch nargin(obstacle)
                    case 0
                        self.f = @(x, t) obstacle();
                    case 1
                        self.f = @(x, t) obstacle(x);
                    case 2
                        self.f = obstacle;
                    otherwise
                        error('Invalid number of arguments');
                end
            else
                error('Invalid input');
            end
        end
    end
    
end

