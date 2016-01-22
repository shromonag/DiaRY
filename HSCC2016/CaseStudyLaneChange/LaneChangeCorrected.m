%% Feasible lane change case study

pathToController = './GurobiModels/LaneChange.lp';
isAuto = 1;
autoInfo = [2 0 1 1];
diagMode = 1;

dt = 0.15;
sys = Vehicle(dt, 0.5);
sys1 = Vehicle(dt, 0.5);
sys2 = Vehicle(dt, 0.5);
sys3 = Vehicle(dt, 0.5);
[x, u, y] = sys.signals();
env = VehicleEnvironment(sys);
env.add_system(sys1);
env.add_system(sys2);
env.add_system(sys3);
env.add_road(Road([0.2 -2], [0.2 2], 0.4, 'right'));
env.add_road(Road([-0.2 -2], [-0.2 2], 0.4, 'left'));


theta_0 = -pi/2;
sys.add_constraint(DiagP('x(0)==[0.2; -.7; pi/2; 0.5]'));
sys.add_constraint(DiagP('u(0)==0'));
sys.add_constraint(always(DiagP('abs(u(t, 1))<=2')));
sys.add_constraint(always(DiagP('abs(u(t, 2))<=3.5')));
sys.add_constraint(always(DiagP('abs(x(t, 4))<=1.53')));
sys.add_dyn_constraint(env.obey_lights(sys));
sys.add_dyn_constraint(env.remain_inside_roads(sys));
sys.add_dyn_constraint(env.avoid_crash(sys));

sys.set_objective('abs(x(t, 1)+0.2)+abs(x(t, 2)-10)+abs(u(t, 1))*0.01');

[x, u, y] = sys1.signals();
sys1.add_constraint(DiagP('x(0)==[-0.2; 1.5; pi/2; 0.5]'));
sys1.add_constraint(always(DiagP('u(t)==[0; -0.25]'))); % If set to zero, feasible

[x, u, y] = sys2.signals();
sys2.add_constraint(DiagP('x(0)==[-0.2; -1.5; pi/2; 0.5]')); % If set to zero, feasible
sys2.add_constraint(always(DiagP('u(t)==[0; 1]')));

[x, u, y] = sys3.signals();
sys3.add_constraint(DiagP('x(0)==[0.2; 1.5; pi/2; 0]'));
sys3.add_constraint(always(DiagP('u(t)==0')));

if diagMode == 1
    diagObject = DiagEnv(env, pathToController, isAuto, autoInfo);
    diagObject.Diagrun_closed_loop(10, 0, 2);
else
    env.run_closed_loop(10, 0, 2);
end

fprintf('done ...\n');