%% Infeasible unprotected left turn case study

pathToController = './GurobiModels/LeftTurn.lp';
isAuto = 1;
autoInfo = [1];
diagMode = 1;

dt = 0.1;
sys = Vehicle(dt, 0.5);
sys1 = Vehicle(dt, 0.5);
sys2 = Vehicle(dt, 0.5);
[x, u, y] = sys.signals();
env = VehicleEnvironment(sys);
env.add_system(sys1);
env.add_system(sys2);
env.add_road(Road([0.2 -2], [0.2 2], 0.4, 'both'));
env.add_road(Road([-0.2 2], [-0.2 -2], 0.4, 'both'));
env.add_road(Road([-2 -0.2], [2 -0.2], 0.4, 'both'));
env.add_road(Road([2 0.2], [-2 0.2], 0.4, 'both'));
env.add_intersection(Intersection([-0.4 -0.4; 0.4 -0.4; 0.4 0.4; -0.4 0.4], @(t) t<=2));


theta_0 = -pi/2;
sys.add_constraint(P('x(0)==[0.2; -.7; pi/2; 0]'));
sys.add_constraint(P('u(0)==0'));
sys.add_constraint(always(P('abs(u(t, 1))<=2')));
sys.add_constraint(always(P('abs(u(t, 2))<=1')));
sys.add_constraint(always(P('abs(x(t, 4))<=1')));
sys.add_dyn_constraint(env.obey_lights(sys));
sys.add_dyn_constraint(env.remain_inside_roads(sys));
sys.add_dyn_constraint(env.avoid_crash(sys));

sys.set_objective('abs(x(t, 1)+10)+abs(x(t, 2)-0.2)+abs(u(t, 1))*0.01');

% Two oncoming vehicles run with constant speed
[x, u, y] = sys1.signals();
sys1.add_constraint(P('x(0)==[-0.2; .7; -pi/2; 0.5]'));
sys1.add_constraint(always(P('u(t)==0')));

[x, u, y] = sys2.signals();
sys2.add_constraint(P('x(0)==[-0.2; 1.5; -pi/2; 0.5]'));
sys2.add_constraint(always(P('u(t)==0')));

if diagMode == 1
    diagObject = DiagEnv(env, pathToController, isAuto, autoInfo);
    diagObject.Diagrun_closed_loop(10, 0, 3);
else
    env.run_closed_loop(10, 0, 3);
end

fprintf('done ...\n');