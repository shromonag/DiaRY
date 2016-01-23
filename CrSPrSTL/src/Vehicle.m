classdef Vehicle < System
    % class: Vehicle: Subclass of system used for defining the nonlinear 
    %                   dynamics of a point-mass model of a vehicle
    % methods: plotter, Vehicle
    properties
        size
    end
    
    methods
        function self = Vehicle(dt, size)
            self@System(dt);
            self.size = size;
            dyn = Dynamics(4, 2);
            [x, u] = dyn.symbols();
            % State: x, y, heading, speed
            % Control: steer, acceleration
            f1 = x(4)*cos(x(3));
            f2 = x(4)*sin(x(3));
            f3 = x(4)*u(1)/self.size;
            f4 = u(2);
            dyn.set_f([f1; f2; f3; f4]);
            dyn.set_g(x);
            self.set_dynamics(dyn);
        end
    end
    
end

