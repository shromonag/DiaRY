classdef ConstraintDynamics < handle 
    
    properties
        c
        x
        u
    end
    
    methods
        function self = ConstraintDynamics(x, u, c)
            self.c = c;
            self.x = x;
            self.u = u;
        end


        function result = x_next(self, dt, x0, u0, t0)
            Sum().minimize([t0,t0+dt], dt, AndPredicate(self.c, P('self.x(t0) == x0'), P('self.u(t0) == u0')));
            result = value(self.x(t0+dt));
        end
        
        function dynamics = local_dynamics(self, dt, x0, u0, t0, x, u, y)
            dynamics = self.c;
        end
    end
end

