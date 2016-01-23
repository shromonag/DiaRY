classdef Dynamics < handle 
    % class: Dynamics
    % properties: f,g,x,u,t: xdot = f(x(t),u(t)), y = g(x(t),u(t))
    % methods: Dynamics: define symbols for variables in the dynamics.
    %          set_f
    %          set_g
    %          symbols:
    %          linear_approximation: Define a linearized symbolic dynamics
    %                                using Jacobian of the real dynamics.
    %          local_dynamics: Define the local dynamics as stl predicates,
    %                          which can be called at every time step.
    properties
        f
        g
        x
        u
        t
    end
    
    methods
        function self = Dynamics(nx, nu)
            if nargin < 1
                nx = 1;
            end
            if nargin < 2
                nu = 1;
            end
            self.x = sym('x', [nx, 1]);
            self.u = sym('u', [nu, 1]);
            self.t = sym('t');
        end
        function [x, u, t] = symbols(self)
            x = self.x;
            u = self.u;
            t = self.t;
        end
        function set_f(self, f)
            self.f = f;
        end
        function set_g(self, g)
            self.g = g;
        end
        function [f0, A, Bu, g0, C, Du] = linear_approximation(self, x, u, t)
            function result = eval_it(s)
                result = double(subs(subs(subs(s, self.x, x), self.u, u), self.t, t));
            end
            if isempty(self.f)
                A = [];
                Bu = [];
                f0 = [];
            else
                A = eval_it(jacobian(self.f, self.x));
                Bu = eval_it(jacobian(self.f, self.u));
                f0 = eval_it(self.f);
            end
            if isempty(self.g)
                C = [];
                Du = [];
                g0 = [];
            else
                C = eval_it(jacobian(self.g, self.x));
                Du = eval_it(jacobian(self.g, self.u));
                g0 = eval_it(self.g);
            end
        end
        function result = x_next(self, dt, x0, u0, t0)
            [f0, A, Bu, g0, C, Du] = self.linear_approximation(x0, u0, t0);
            sysc = ss(A, [Bu f0], C, [Du g0]);
            sysd = c2d(sysc, dt);
            result = x0+sysd.B*[u0-u0; 1];
        end
        function dynamics = local_dynamics(self, dt, x0, u0, t0, x, u, y)
            if any(isnan(x0))
                x0 = zeros(size(x0));
            end
            if any(isnan(u0))
                u0 = zeros(size(u0));
            end
            if isnan(t0)
                t0 = 0.;
            end
            [f0, A, Bu, g0, C, Du] = self.linear_approximation(x0, u0, t0);
            sysc = ss(A, [Bu f0], C, [Du g0]);
            sysd = c2d(sysc, dt);
            p1 = P(@(t, dt) x(t+dt)==x0+sysd.A*(x(t)-x0)+sysd.B*[u(t)-u0; 1]);
            if ~isempty(g0)
                p2 = P(@(t, dt) y(t)==g0+sysd.C*(x(t)-x0)+sysd.D*[u(t)-u0; 1]);
                dynamics = p1&p2;
            else
                dynamics = p1;
            end
        end
    end
end

