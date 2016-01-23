classdef Intersection
    %INTERSECTION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        A
        b
        points
        f
    end
    
    methods
        function self = Intersection(points, f)
            self.points = points;
            self.f = f;
            self.A = [];
            self.b = [];
            for i=1:size(points, 1)
                p = points(i, :);
                if i==size(points, 1)
                    q = points(1, :);
                else
                    q = points(i+1, :);
                end
                self.A(end+1, :) = [p(2)-q(2) q(1)-p(1)];
                self.b(end+1, :) = p(1)*q(2)-p(2)*q(1);
            end
        end
    end
    
end

