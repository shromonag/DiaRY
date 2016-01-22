%% This function finds a set of diagnosed predicates

function [DiagnosedPredicates, updatedGurobiModel, allConsNum] = DiagnoseMILP(pathToController, STLparseTrees, isBin)
    param.outputflag = 1;
    gurobiModel = gurobi_read(pathToController);
    soln = gurobi(gurobiModel,param);
    
    fileID = fopen('./InterfaceFiles/pathToController.txt', 'w');
    fprintf(fileID,'%s', char(pathToController));
    fclose(fileID);
    
    IISpath = './InfeasibleModels/controllerIIS.ilp';
    updatedController = './GurobiModels/updatedController.lp';
    gurobiModel.obj = zeros(length(gurobiModel.obj(:,1)),1);
    gurobi_write(gurobiModel, updatedController);
    
    DiagnosedPredicates = [];
    allConsNum = [];
    
    while strcmp(soln.status, 'OPTIMAL') == 0
        [status, result] = unix('python ./PythonFiles/IIScompute.py');
        infeasModel = gurobi_read(IISpath);
        %params.resultfile = './InfeasibleModels/contIIS.ilp';
        %iis = gurobi_iis(gurobiModel, params);
        constraintNumbers = ExtractConstraintsFromIIS(infeasModel);
        allConsNum = [allConsNum constraintNumbers];
        STLnodesFailing = ExtractFailingSTLnodes(constraintNumbers, STLparseTrees);
        STLnodesFailing = removeDuplicates(STLparseTrees, STLnodesFailing);
        for i = 1 : length(STLnodesFailing(1,:))
            if strcmp(STLparseTrees(STLnodesFailing(1,i)).STLnodes(STLnodesFailing(2,i)).nodeType, 'phi')
                % STL number, predicate node number, predicate fail time,
                % failing constraint
                DiagnosedPredicates = [DiagnosedPredicates STLnodesFailing(:,i)];
            end
        end
        UpdateMILP(STLparseTrees, STLnodesFailing);
        updatedGurobiModel = gurobi_read(updatedController);
        if isBin == 1
            updatedGurobiModel.obj = zeros(length(updatedGurobiModel.obj(:,1)),1);
        end
        gurobi_write(updatedGurobiModel, updatedController);
        soln = gurobi(updatedGurobiModel, param);
    end
end