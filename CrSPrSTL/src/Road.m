classdef Road
    %ROAD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % Goes from p to q
        p
        q
        width
        left
        right
    end
    
    methods
        function self = Road(p, q, width, sides)
            self.p = p(:);
            self.q = q(:);
            self.width = width;
            if nargin<=3
                sides = 'both';
            end
            self.left = strcmp(sides, 'left') || strcmp(sides, 'both');
            self.right = strcmp(sides, 'right') || strcmp(sides, 'both');
        end
    end
    
end

