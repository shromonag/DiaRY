classdef QuadrotorEnvironment < Environment
    %QUADROTORENVIRONMENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        obstacles
    end
    
    methods
        function self = QuadrotorEnvironment(varargin)
            self@Environment(varargin{:});
            self.obstacles = [];
        end
        function add_obstacle(self, obstacle)
            self.obstacles = [self.obstacles obstacle];
        end
        function result = obstacle_model(self)
            function o = f(x, t)
                o = false;
                for i = 1:numel(self.obstacles)
                    if self.obstacles(i).f(x, t)
                        o = true;
                    end
                end
            end
            result = @f;
        end
        function plotter = get_plotter(self)
            plotter = QuadrotorPlotter(self.get_dt());
            for i = 1:numel(self.systems)
                if isa(self.systems(i), 'Quadrotor')
                    plotter.add_quadrotor(self.systems(i));
                end
            end
            for i = 1:numel(self.obstacles)
                plotter.add_obstacle(self.obstacles(i));
            end
        end
    end
    
end

