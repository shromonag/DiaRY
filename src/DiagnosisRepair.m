%% Function for the diagnosis and repair 

function drObject = DiagnosisRepair(drObject)
	pathToController = drObject.pathToController;
	STLparseTrees = drObject.STLparseTrees;
	isBin = drObject.isBin;
    param.outputflag = 1;
    updatedController = './GurobiModels/updatedController.lp';
    gurobiModel = gurobi_read(pathToController);
    gurobiModel.obj = zeros(length(gurobiModel.obj(:,1)),1);
    [DiagnosedPredicates, updatedGurobiModel] = DiagnoseMILP(pathToController, STLparseTrees, isBin);
    soln = gurobi(updatedGurobiModel, param); 
    
    %% Repair can be of three different types
    % Repair can be unconstrainted
    % Repair can be weighted
    % Repair can also be constrainted on the maximal slack added
    if drObject.isAuto == 0
        fprintf('Enter to choose the type of repair : \n');
        fprintf('1. Unconstrained repair \n');
        fprintf('2. Weighted repair \n');
        fprintf('3. Constrained with maximal slack \n');
    
        prompt = ['Choice of repair : \n'];
        choice = input(prompt);
    else
        choice = drObject.autoInfo(1);
    end
    
    
    if choice == 1
        %% Unconstrained Repair
        slackConstraints = unconstrainedRepair(updatedGurobiModel, soln);
    
    elseif choice == 2
        %% Weighted constraints
        % The weights are applied directly to the the constraints, more the
        % weight assigned to a predicate, more flexible it is to change
        repeat = 0;
        while repeat == 0
            if drObject.isAuto == 0
                weights = collectWeights(DiagnosedPredicates);
            else
                weights = drObject.autoInfo(2:end);
            end
            DiagnosedPredicates = [DiagnosedPredicates; weights];
            gurobi_write(gurobiModel, updatedController);
            UpdateWeightedMILP(STLparseTrees, DiagnosedPredicates);
            updatedGurobiModel = gurobi_read(updatedController);
            if isBin == 1
                updatedGurobiModel.obj = zeros(length(updatedGurobiModel.obj(:,1)),1);
            end
            gurobi_write(updatedGurobiModel, updatedController);
            soln = gurobi(updatedGurobiModel, param);
            repeat = strcmp(soln.status, 'OPTIMAL'); 
            if repeat == 0
                fprintf('The weights need to be rewritten, maybe you set the weight of something to 0.\n');
                DiagnosedPredicates = DiagnosedPredicates(1:end-1, :);
            end
        end
        slackConstraints = unconstrainedRepair(updatedGurobiModel, soln);
    
    else 
        %% Maximal slack
        % Restrict the maximum amount a predicate can change by
        repeat = 0;
        while repeat == 0
            if drObject.isAuto == 0
                maxSlacks = MaximalSlacks(DiagnosedPredicates);
            else
                maxSlacks = drObject.autoInfo(2:end);
            end
            DiagnosedPredicates = [DiagnosedPredicates; maxSlacks];
            gurobi_write(gurobiModel, updatedController);
            UpdateMaxSlackMILP(STLparseTrees, DiagnosedPredicates);
            updatedGurobiModel = gurobi_read(updatedController);
            soln = gurobi(updatedGurobiModel, param);
            repeat = strcmp(soln.status, 'OPTIMAL'); 
            if repeat == 0
                fprintf('The maximal slacks are too constrained, need more liberal.\n');
                DiagnosedPredicates = DiagnosedPredicates(1:end-1, :);
            end
        end
        slackConstraints = unconstrainedRepair(updatedGurobiModel, soln);
    end
    
    STLparseTrees = updateWithSlacks(slackConstraints, STLparseTrees);
    
    STLparseTrees = updateSupport(STLparseTrees);
    STLparseTrees = updateSigma(STLparseTrees);
    
    drObject.STLparseTrees = STLparseTrees;
 end