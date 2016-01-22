%% This function performs repair for fixing adversarial variables

function STLparseTrees = DiagnosisRepairAdv(pathToController, STLparseTrees)
    param.outputflag = 1;
    gurobiModel = gurobi_read(pathToController);
    soln = gurobi(gurobiModel,param);
    
    fileID = fopen('./InterfaceFiles/pathToController.txt', 'w');
    fprintf(fileID,'%s', char(pathToController));
    fclose(fileID);
    
    updatedController = './GurobiModels/updatedController.lp';
    gurobiModel.obj = zeros(length(gurobiModel.obj(:,1)),1);
    gurobi_write(gurobiModel, updatedController);
    
    STLnodesFailing = [];
    for i = 1 : length(STLparseTrees)
        for j = 1 : length(STLparseTrees(i).STLnodes)
            for k = 1 : length(STLparseTrees(i).STLnodes(j).consBreakUp)
                STLnodesFailing = [STLnodesFailing [i; j; STLparseTrees(i).STLnodes(j).consBreakUp(k).t; STLparseTrees(i).STLnodes(j).consBreakUp(k).consList(1,1)]];
            end
        end
    end
    
    UpdateMILP(STLparseTrees, STLnodesFailing);
    updatedGurobiModel = gurobi_read(updatedController);
    
    soln = gurobi(updatedGurobiModel, param);
    
    slackConstraints = unconstrainedRepair(updatedGurobiModel, soln);
    STLparseTrees    = updateWithSlacks(slackConstraints, STLparseTrees);
end