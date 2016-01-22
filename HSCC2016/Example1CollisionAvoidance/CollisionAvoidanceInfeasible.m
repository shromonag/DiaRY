%% Running Example 1 : Collision Avoidance(Infeasible)

clear;
close all;

%% Create the system

%A1 = [1, 1; 0, 1 ]; %[x y]_t = [x y]_{t-1} + [1 1; 0 1][x y]_{t-1} + [0; 1]u_{t-1} 
SC = simple_cars();

%% Controller Initialisation
% Time
SC.time = 0:.2:2; % time for the dynamics
SC.ts=.2; % sampling time for controller
SC.L=5;  % horizon (# of steps)
SC.nb_stages=1; % repeats time

% Input constraints
SC.u_lb=1.5;
SC.u_ub=2.5;

% Disturbance signal
w = 0*SC.time;
w(1:end) = 2;
Wref = w;

SC.Wref = Wref;
SC.w_lb(:) = -1;
SC.w_ub(:) = 1;

% Diagnosis object
DiagSC = DiagSTLC_lti(SC);
DiagSC.initWref = Wref;
DiagSC.w_min = min(Wref + SC.w_lb(:));
DiagSC.w_max = min(Wref + SC.w_ub(:));
DiagSC.diagMode = 1;
DiagSC.isAuto = 1;

%% Initial state
X1 = [-1 0]';
X2 = [-1 0]';
X0 = [X1; X2];
DiagSC.BluSTLsys.x0 = X0;

%% STL formula

DiagSC.BluSTLsys.stl_list = {'alw_[0,inf] (not( (x1(t) > -0.5) and (x1(t) < 0.5) and (x3(t) > -0.5) and (x3(t) < 0.5)))'};

%% Diagnosis related stuff
DiagSC.pathToController = './GurobiModels/testSimpleCars.lp';

%% Running stuff
DiagSC.debugAdv = 0;
fprintf('Computing controller...\n');
if DiagSC.diagMode == 1
    [controller, DiagSC] = diagGet_controller(DiagSC);
else
    controller = get_controller(DiagSC.BluSTLsys);
end
gurobiModel = yalmip2gurobi(controller.model);
gurobi_write(gurobiModel, DiagSC.pathToController);

fprintf('Computing adversary...\n');
if DiagSC.diagMode == 1
    adversary = diagGet_adversary(DiagSC);
else
    adversary = get_adversary(DiagSC.BluSTLsys);
end
DiagSC.BluSTLsys.controller = controller;
DiagSC.BluSTLsys.adversary  = adversary;
fprintf('Running...')

DiagSC.autoInfo = [1];
DiagSC = diagRun_open_loop(DiagSC, controller);
fprintf('\ndone.\n');

