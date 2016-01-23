classdef VehicleEnvironment < Environment
    
    properties
        roads
        intersections
        obstacles
    end
    
    methods
        function self = VehicleEnvironment(varargin)
            self@Environment(varargin{:});
            self.roads = [];
            self.intersections = [];
            self.obstacles = [];
        end
        function add_road(self, road)
            self.roads = [self.roads road];
        end
        function add_intersection(self, intersection)
            self.intersections = [self.intersections intersection];
        end
        function add_obstacle(self, obstacle)
            self.obstacles = [self.obstacles obstacle];
        end
        function result = avoid_crash_probabilistic(self, vehicle, v_std, prob)
            n = standard_normal();
            function C = dyn_constraint(~, t0)
                C = AndPredicate();
                for i=2:numel(self.systems)
                    last_x = self.systems(i).history.x(:, end);
                    x = last_x(1:2);
                    theta = last_x(3);
                    v = last_x(4)+n*v_std;
                    a = [cos(theta); sin(theta)]*v;
                    C = C & ( ...
                        Pr(@(t, dt) vehicle.x(t, 1)-(x(1)+a(1)*(t-t0))>=0.4)>=prob | ...
                        Pr(@(t, dt) vehicle.x(t, 1)-(x(1)+a(1)*(t-t0))<=-0.4)>=prob | ...
                        Pr(@(t, dt) vehicle.x(t, 2)-(x(2)+a(2)*(t-t0))>=0.4)>=prob | ...
                        Pr(@(t, dt) vehicle.x(t, 2)-(x(2)+a(2)*(t-t0))<=-0.4)>=prob ...
                    );
                end
                C = always(C, 2*vehicle.dt, inf);% | always(P(@(t, dt) abs(vehicle.x(t, 4))<=0.01), 1*vehicle.dt, inf);
            end
            result = @dyn_constraint;
        end
        
        function result = avoid_crash(self, vehicle)
            function C = dyn_constraint(~, t0)
                C = AndPredicate();
                for i=2:numel(self.systems)
                    last_x = self.systems(i).history.x(:, end);
                    x = last_x(1:2);
                    theta = last_x(3);
                    v = last_x(4);
                    a = [cos(theta); sin(theta)]*v;
                    C = C & ~P(@(t, dt) abs(vehicle.x(t, 1:2)-(x+a*(t-t0)))<=0.3);
                end
                C = always(C, 0*vehicle.dt, inf);
            end
            result = @dyn_constraint;
        end
        function result = obey_lights(self, vehicle)
            function C = dyn_constraint(~, t)
                C = AndPredicate();
                for i = 1:numel(self.intersections)
                    if ~self.intersections(i).f(t)
                        C = C & ~P(@(t, dt) self.intersections(i).A*vehicle.x(t, 1:2)<=self.intersections(i).b);
                    end
                end
                C = always(C, 2*vehicle.dt, inf);
            end
            result = @dyn_constraint;
        end
        function result = remain_inside_roads(self, vehicle)
            x = vehicle.x;
            size = vehicle.size*0.3;
            function C = dyn_constraint(x0)
                theta_0 = x0(3);
                preds = {};
                for i=1:numel(self.intersections)
                    A = self.intersections(i).A;
                    b = self.intersections(i).b;
                    preds{end+1} = P(@(t, dt) A*x(t, 1:2)<=b); %#ok<AGROW>
                end
                for i=1:numel(self.roads)
                    p = self.roads(i).p;
                    q = self.roads(i).q;
                    w1 = -self.roads(i).width/2.;
                    if self.roads(i).left
                        w1 = w1+size;
                    end
                    w2 = self.roads(i).width/2.;
                    if self.roads(i).right
                        w2 = w2-size;
                    end
                    l = norm(q-p);
                    b = (q-p)/l;
                    a = [0 1; -1 0]*b;
                    theta = atan2(b(2), b(1));
                    theta = theta+floor((theta-theta_0+pi)/(2*pi))*(2*pi);
                    pred = P(@(t, dt) dot(x(t, 1:2)-p, b)>=0 & dot(x(t, 1:2)-q, b)<=l & dot(x(t, 1:2)-p, a)>=w1 & dot(x(t, 1:2)-p, a)<=w2 & abs(x(t, 3)-theta)<=pi/2);
                    preds{end+1} = pred; %#ok<AGROW>
                end
                C = always(or(preds{:}), vehicle.dt*4, inf);
            end
            result = @dyn_constraint;
        end
        function plotter = get_plotter(self)
            plotter = VehiclePlotter(self.get_dt());
            for i = 1:numel(self.systems)
                if isa(self.systems(i), 'Vehicle')
                    plotter.add_vehicle(self.systems(i));
                end
            end
            for i = 1:numel(self.roads)
                plotter.add_road(self.roads(i));
            end
            for i = 1:numel(self.intersections)
                plotter.add_intersection(self.intersections(i));
            end
            for i = 1:numel(self.obstacles)
                plotter.add_obstacle(self.obstacles(i));
            end
        end
    end
    
end
