classdef Sensor < handle
    properties
        mu
        S
        threshold
        wall
        sensors
    end
    methods
        function self = Sensor(sensors, threshold)
            self.sensors = sensors;
            self.threshold = threshold;
            self.mu = [0; 0; 0; -1];
            self.S = zeros(4);
        end
        function result = classify(self, x)
            x = [x; 1];
            m = self.mu'*x;
            s = sqrt(x'*self.S*x);
            result = normcdf(-m/s)-self.threshold;
            %if normcdf(-m/s)>=self.threshold
            %    result = false;
            %else
            %    result = true;
            %end
        end
        function sense(self, obstacle, x, t)
            LinAlg = LinearAlgebra();
            position = x(1:3);
            rotation = LinAlg.zyx_Euler_RotationMat(x(7),x(8),x(9));
            x_train = rotation * self.sensors' + repmat(position, 1, size(self.sensors, 1));
            x_train = x_train';
            y_train = zeros(size(x_train, 1), 1);
            for i = 1:size(x_train, 1)
                if obstacle(x_train(i, :)', t)
                    y_train(i) = 1;
                else
                    y_train(i) = -1;
                end
            end
            x_train = [x_train ones(length(y_train), 1)];
            [self.mu, self.S] = linearGP(x_train, y_train, 1);
            self.wall = normal(self.mu, self.S);
        end
    end
end

