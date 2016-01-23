classdef QuadrotorWithBattery < Quadrotor
    % class: Quadrotor_with_battery: Subclass of system used for defining the nonlinear 
    %                   dynamics of a quadrotor.
    % methods: plotter, Quadrotor

    methods

        function self = QuadrotorWithBattery(dt, size)
            self@Quadrotor(dt, size);
            LinAlg = LinearAlgebra();
            g = 9.81;
            m = 0.5;
            I = diag([5e-3, 5e-3, 10e-3]);
            dyn = Dynamics(13, 4);
            [x, u] = dyn.symbols();
            f1 = [x(4); x(5); x(6)];
            f2 = [0; 0; g] - (1/m)*LinAlg.zyx_Euler_RotationMat(x(9),x(8),x(7))*[0;0;u(4)];
            f3 = LinAlg.zyx_Ang_RateMat(x(9), x(8), x(7))*[x(10); x(11); x(12)];
            f4 = I\([u(1); u(2); u(3)]-LinAlg.SkewSymmetric_3Dim([x(10); x(11); x(12)])*I*[x(10); x(11); x(12)]);
            f5 = -abs(u(4)); % Battery usage
            dyn.set_f([f1; f2; f3; f4; f5]);
            dyn.set_g(x(1:3));
            self.set_dynamics(dyn);
        end
    end
    
end

