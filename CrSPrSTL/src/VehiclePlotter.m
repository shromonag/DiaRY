classdef VehiclePlotter < handle
    properties
        fig
        axis
        vehicles
        roads
        intersections
        grass
        t_last
        dt
    end
    
    methods
        function self = VehiclePlotter(dt)
            self.vehicles = {};
            self.dt = dt;
        end
        
        function add_vehicle(self, vehicle)
            self.vehicles{end+1} = struct('size', vehicle.size, 'x', vehicle.x, 'past', [], 'future', [], 'past_plot', [], 'future_plot', [], 'vehicle_plot', []);
        end
        
        function add_road(self, road)
            self.roads{end+1} = struct('p', road.p, 'q', road.q, 'width', road.width, 'left', road.left, 'right', road.right);
        end
        
        function add_intersection(self, intersection)
            self.intersections{end+1} = struct('p', intersection.points, 'f', intersection.f, 'lights', []);
        end
        
        function create_figure(self)
            past_style = {'LineWidth', 2};
            future_style = {'--g'};
            self.fig = figure;
            hold on;
            axis equal;
            self.axis = gca;
            self.grass = patch('FaceColor', [0 0.5 0.03], 'EdgeColor', 'none');
            for i = 1:numel(self.vehicles)
                if i==1
                    [img, ~, alpha] = imread('car-red.png');
                else
                    [img, ~, alpha] = imread('car-yellow.png');
                end
                self.vehicles{i}.vehicle_plot = warp(img);
                set(self.vehicles{i}.vehicle_plot, 'Zdata', -0.001*ones(2));
                set(self.vehicles{i}.vehicle_plot, 'FaceAlpha', 'texturemap', 'AlphaData', alpha);
                self.vehicles{i}.past_plot = plot(0, 0, past_style{:});
                self.vehicles{i}.future_plot = plot(0, 0, future_style{:});
            end
            for i = 1:numel(self.intersections)
                points = self.intersections{i}.p;
                for j = 1:size(points, 1)
                    p = points(j, :);
                    q = points(mod(j, 4)+1, :);
                    a = (q-p)/norm(q-p);
                    b = [a(2) -a(1)];
                    theta = linspace(0, 2*pi, 20);
                    self.intersections{i}.lights = [self.intersections{i}.lights patch(0.09*cos(theta)+q(1)+0.2*(1.5*a(1)+b(1)), 0.09*sin(theta)+q(2)+0.2*(1.5*a(2)+b(2)), ones(1, length(theta))*0.001, 'FaceColor', 'red', 'EdgeColor', 'black')];
                end
            end
            for i = 1:numel(self.roads)
                p = self.roads{i}.p;
                q = self.roads{i}.q;
                w = self.roads{i}.width;
                a = [0 1; -1 0]*(q-p)/norm(q-p);
                lpoints = [p-a*w/2., q-a*w/2.];
                lstyle = '--';
                if self.roads{i}.left
                    lstyle = '-';
                end
                line(lpoints(1, :), lpoints(2, :), ones(1, 2)*-0.003, 'Color', 'white', 'LineStyle', lstyle);
                rpoints = [p+a*w/2., q+a*w/2.];
                rstyle = '--';
                if self.roads{i}.right
                    rstyle = '-';
                end
                line(rpoints(1, :), rpoints(2, :), ones(1, 2)*-0.003, 'Color', 'white', 'LineStyle', rstyle);
                w = w*0.95;
                points = [p+a*w/2., p-a*w/2., q-a*w/2., q+a*w/2];
                road = patch('FaceColor', [0.5 0.5 0.5], 'EdgeColor', 'none');
                set(road, 'Xdata', points(1, :), 'Ydata', points(2, :), 'Zdata', ones(1, 4)*-0.002);
            end
            for i = 1:numel(self.roads)
            end
            view(2);
            axis(2*[-1 1 -1 1]); %#ok<CPROP>
            set(self.axis, 'YDir', 'Normal');
        end
        
        function show(self)
            if isempty(self.fig)
                self.create_figure();
            end
            xl = xlim(self.axis);
            yl = ylim(self.axis);
            set(self.grass, 'Xdata', [xl(1) xl(1) xl(2) xl(2)], 'Ydata', [yl(1) yl(2) yl(2) yl(1)], 'Zdata', ones(1, 4)*-0.004);
            if ~isempty(self.t_last)
                for i = 1:numel(self.intersections)
                    for j = 1:numel(self.intersections{i}.lights)
                        if xor(self.intersections{i}.f(self.t_last+self.dt), mod(j, 2))
                            color = 'green';
                        else
                            color = 'red';
                        end
                        set(self.intersections{i}.lights(j), 'FaceColor', color);
                    end
                end
            end
            for i = 1:numel(self.vehicles)
                if ~isempty(self.vehicles{i}.past)
                    if i==1
                        set(self.vehicles{i}.past_plot, 'Xdata', self.vehicles{i}.past(1, :), 'Ydata', self.vehicles{i}.past(2, :));
                    end
                    x_last = self.vehicles{i}.past(:, end);
                    points = [-0.5 -0.25; 0.5 -0.25; -0.5 0.25; 0.5 0.25]*self.vehicles{i}.size;
                    theta = x_last(3);
                    points = ([cos(theta) -sin(theta); sin(theta) cos(theta)]*points')';
                    points = points+repmat(x_last(1:2)', size(points, 1), 1);
                    set(self.vehicles{i}.vehicle_plot, 'Xdata', [points(1, 1) points(2, 1); points(3, 1) points(4, 1)], 'Ydata', [points(1, 2) points(2, 2); points(3, 2) points(4, 2)]);
                end
                if ~isempty(self.vehicles{i}.future)
                    if i==1
                        set(self.vehicles{i}.future_plot, 'Xdata', self.vehicles{i}.future(1, :), 'Ydata', self.vehicles{i}.future(2, :));
                    end
                end
            end
        end
        
        function capture_future(self, ts)
            for i=1:numel(self.vehicles)
                self.vehicles{i}.future = value(self.vehicles{i}.x(ts));
            end
            self.show();
        end
        
        function capture_past(self, ts)
            if ~isempty(ts)
                for i=1:numel(self.vehicles)
                    self.vehicles{i}.past = [self.vehicles{i}.past value(self.vehicles{i}.x(ts))];
                end
                self.t_last = ts(end);
            end
            self.show();
        end
    end
    
end

