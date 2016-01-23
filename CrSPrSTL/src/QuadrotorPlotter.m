classdef QuadrotorPlotter < handle
    % Class: Plotter3D: Used for plotting quadrotors future and current
    %                   trajecotry.
    % properties: fig, past_plot, future_plot, surface_plot, surface,
    %              pos_past, pos_future, rot_matrix, x, pos_inds, y, rot_inds
    % methods: QuadrotorPlotter
    %          set_position_signal
    %          set_rotation_signal
    %          create_figure
    %          show
    %          capture_past
    %          capture_future
    properties
        fig
        axis
        quadrotors
        obstacles
        t_last
        dt
%         past_plot
%         future_plot
%         surface_plot
%         obstacle_plot
%         obstacle_verts
%         obstacle_faces
%         classifier_plot
%         classifier_verts
%         classifier_faces
%         sensor
%         obstacle
%         surface
%         pos_past
%         pos_future
%         rot_matrix
%         pos_signal
%         rot_signal
    end
    
    methods
        function self = QuadrotorPlotter(dt)
            self.quadrotors = {};
            self.dt = dt;
            self.obstacles = {};
        end
        function add_quadrotor(self, quadrotor)
            self.quadrotors{end+1} = struct('size', quadrotor.size, 'x', quadrotor.x, 'past', [], 'future', [], 'past_plot', [], 'future_plot', [], 'quadrotor_plot', [], 'sensor', quadrotor.sensor, 'sensor_plot', []);
        end
        function add_obstacle(self, obstacle)
            self.obstacles{end+1} = struct('f', obstacle.f, 'plot', []);
        end
        function create_figure(self)
            past_style = {'LineWidth', 2};
            future_style = {'--g'};
            axis_style = {'Fontsize', 12};
            self.fig = figure;
            hold on;
            axis equal;
            grid on;
            xlabel('x');
            ylabel('y');
            zlabel('z');
            view(3);
            set(gca, axis_style{:});
            set(gca, 'ZDir', 'Reverse');
            self.axis = gca;
            axis([-0.3 2 -0.3 2 -1 0.2]) %#ok<CPROP>
            for i = 1:numel(self.quadrotors)
                self.quadrotors{i}.future_plot = plot3(0, 0, 0, future_style{:});
                self.quadrotors{i}.quadrotor_plot = patch('FaceColor', [0. 0.7 0.], 'FaceAlpha', 0.5);
                self.quadrotors{i}.past_plot = plot3(0, 0, 0, past_style{:});
                self.quadrotors{i}.sensor_plot = patch('Vertices', [], 'Faces', [], 'FaceColor', 'red', 'EdgeColor', 'none', 'FaceAlpha', 0.1);
            end
            for i = 1:numel(self.obstacles)
                self.obstacles{i}.plot = patch('Vertices', [], 'Faces', [], 'FaceColor', 'blue', 'EdgeColor', 'none', 'FaceAlpha', 0.3);
            end
        end
        function show(self)
            if isempty(self.fig)
                self.create_figure();
            end
            for i = 1:numel(self.quadrotors)
                if ~isempty(self.quadrotors{i}.past)
                    if i==1
                        set(self.quadrotors{i}.past_plot, 'Xdata', self.quadrotors{i}.past(1, :), 'Ydata', self.quadrotors{i}.past(2, :), 'Zdata', self.quadrotors{i}.past(3, :));
                    end
                    x_last = self.quadrotors{i}.past(:, end);
                    LinAlg = LinearAlgebra();
                    rot_matrix = LinAlg.zyx_Euler_RotationMat(x_last(7),x_last(8),x_last(9));
                    points = repmat(x_last(1:3), 1, 4)+rot_matrix*([-1 -1 1 1; -1 1 1 -1; 0 0 0 0]*self.quadrotors{i}.size);
                    set(self.quadrotors{i}.quadrotor_plot, 'Xdata', points(1, :), 'Ydata', points(2, :), 'Zdata', points(3, :));
                end
                if ~isempty(self.quadrotors{i}.future)
                    if i==1
                        set(self.quadrotors{i}.future_plot, 'Xdata', self.quadrotors{i}.future(1, :), 'Ydata', self.quadrotors{i}.future(2, :), 'Zdata', self.quadrotors{i}.future(3, :));
                    end
                end
                if ~isempty(self.quadrotors{i}.sensor)
                    X = xlim(self.axis);
                    Y = ylim(self.axis);
                    Z = zlim(self.axis);
                    [X, Y, Z] = meshgrid(linspace(X(1), X(2), 40), linspace(Y(1), Y(2), 40), linspace(Z(1), Z(2), 40));
                    V = X;
                    for j = 1:numel(X)
                        V(j) = self.quadrotors{i}.sensor.classify([X(j); Y(j); Z(j)]);
                    end
                    [faces, verts] = isosurface(X, Y, Z, V);
                    set(self.quadrotors{i}.sensor_plot, 'Faces', faces, 'Vertices', verts);
                end
            end
            if ~isempty(self.t_last)
                for i = 1:numel(self.obstacles)
                    X = xlim(self.axis);
                    Y = ylim(self.axis);
                    Z = zlim(self.axis);
                    [X, Y, Z] = meshgrid(linspace(X(1), X(2), 40), linspace(Y(1), Y(2), 40), linspace(Z(1), Z(2), 40));
                    V = X;
                    for j = 1:numel(X)
                        if self.obstacles{i}.f([X(j); Y(j); Z(j)], self.t_last)
                            V(j) = 1;
                        else
                            V(j) = -1;
                        end
                    end
                    [faces,  verts] = isosurface(X, Y, Z, V);
                    set(self.obstacles{i}.plot, 'Faces', faces, 'Vertices', verts);
                end
            end
%             if ~isempty(self.pos_past)
%                 set(self.past_plot, 'Xdata', self.pos_past(1, :), 'Ydata', self.pos_past(2, :), 'Zdata', self.pos_past(3, :));
%                 c = self.pos_past(:, end);
%                 shape = repmat(c, 1, size(self.surface, 2))+self.rot_matrix*self.surface;
%                 set(self.surface_plot, 'Xdata', shape(1, :), 'Ydata', shape(2, :), 'Zdata', shape(3, :));
%                 set(self.obstacle_plot, 'Faces', self.obstacle_faces, 'Vertices', self.obstacle_verts);
%                 set(self.classifier_plot, 'Faces', self.classifier_faces, 'Vertices', self.classifier_verts);
%             end
%             if ~isempty(self.pos_future)
%                 set(self.future_plot, 'Xdata', self.pos_future(1, :), 'Ydata', self.pos_future(2, :), 'Zdata', self.pos_future(3, :));
%             end
        end
%         function capture_past(self, ts)
%             if ~isempty(ts)
%                 self.pos_past = [self.pos_past value(self.pos_signal(ts))];
%                 LinAlg = LinearAlgebra();
%                 rot = value(self.rot_signal(ts(end)));
%                 self.rot_matrix = LinAlg.zyx_Euler_RotationMat(rot(1),rot(2),rot(3));
%                 X = xlim(self.axis);
%                 Y = ylim(self.axis);
%                 Z = zlim(self.axis);
%                 [X, Y, Z] = meshgrid(linspace(X(1), X(2), 40), linspace(Y(1), Y(2), 40), linspace(Z(1), Z(2), 40));
%                 V = X;
%                 for i = 1:numel(X)
%                     if self.obstacle([X(i); Y(i); Z(i)], ts(end))
%                         V(i) = 1;
%                     else
%                         V(i) = -1;
%                     end
%                 end
%                 [self.obstacle_faces,  self.obstacle_verts] = isosurface(X, Y, Z, V);                
%                 if ~isempty(self.sensor)
%                     V = X;
%                     for i = 1:numel(X)
%                         V(i) = self.sensor.classify([X(i); Y(i); Z(i)]);
%                     end
%                     [self.classifier_faces, self.classifier_verts] = isosurface(X, Y, Z, V);
%                 end
%             end
%             self.show();
%         end
        function capture_future(self, ts)
            for i=1:numel(self.quadrotors)
                self.quadrotors{i}.future = value(self.quadrotors{i}.x(ts));
            end
            self.show();
        end
        
        function capture_past(self, ts)
            if ~isempty(ts)
                for i=1:numel(self.quadrotors)
                    self.quadrotors{i}.past = [self.quadrotors{i}.past value(self.quadrotors{i}.x(ts))];
                end
                self.t_last = ts(end);
            end
            self.show();
        end
    end
    
end

