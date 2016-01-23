classdef Quadrotor < System
    % class: Quadrotor: Subclass of system used for defining the nonlinear 
    %                   dynamics of a quadrotor.
    % methods: plotter, Quadrotor
    properties
        size
        sensor
    end
    
    methods
        function set_sensor(self, sensor, obstacle_model)
            self.sensor = sensor;
            function C = dyn_constraint(x, t)
                self.sensor.sense(obstacle_model, x, t);
                C = always(Pr(@(t, dt) self.sensor.wall'*[self.x(t, 1:3); 1]<=0)>=self.sensor.threshold, 0.1, inf);
            end
            self.add_dyn_constraint(@dyn_constraint);
        end
%         function set_obstacle(self, obstacle)
%             if isa(obstacle, 'function_handle')
%                 switch nargin(obstacle)
%                     case 0
%                         self.obstacle = @(x, t) obstacle();
%                     case 1
%                         self.obstacle = @(x, t) obstacle(x);
%                     case 2
%                         self.obstacle = obstacle;
%                     otherwise
%                         error('Invalid number of arguments');
%                 end
%             end
%         end
%         function plotter = create_plotter(self)
%             plotter = QuadrotorPlotter(0.08);
%             plotter.set_position_signal(self.x(:, 1:3));
%             plotter.set_rotation_signal(self.x(:, 7:9));
%             plotter.set_obstacle(self.obstacle);
%             if ~isempty(self.sensor)
%                 plotter.set_sensor(self.sensor);
%             end
%         end
        function self = Quadrotor(dt, size)
            self@System(dt);
            self.size = size;
            self.sensor = [];
            LinAlg = LinearAlgebra();
            g = 9.81;
            m = 0.5;
            I = diag([5e-3, 5e-3, 10e-3]);
            dyn = Dynamics(12, 4);
            [x, u] = dyn.symbols();
            f1 = [x(4); x(5); x(6)];
            f2 = [0; 0; g] - (1/m)*LinAlg.zyx_Euler_RotationMat(x(9),x(8),x(7))*[0;0;u(4)];
            f3 = LinAlg.zyx_Ang_RateMat(x(9), x(8), x(7))*[x(10); x(11); x(12)];
            f4 = I\([u(1); u(2); u(3)]-LinAlg.SkewSymmetric_3Dim([x(10); x(11); x(12)])*I*[x(10); x(11); x(12)]);
            dyn.set_f([f1; f2; f3; f4]);
            dyn.set_g(x(1:3));
            self.set_dynamics(dyn);
        end
        function run_closed_loop(self, L, t1, t2)
            env = QuadrotorEnvironment(self);
            env.run_closed_loop(L, t1, t2);
        end
    end
    
end

