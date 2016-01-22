%% This function creates a list of constraints which are need to be changed along with their weights

function status = UpdateWeightedMILP(STLparseTrees, DiagnosedPredicates)
    constraintsToChange = [];
    for i  = 1 : length(DiagnosedPredicates(1,:))
        constraintsToChangei = [];
        for j = 1 : length(STLparseTrees(DiagnosedPredicates(1,i)).STLnodes(DiagnosedPredicates(2,i)).consBreakUp(1,:))
            constraintsToChangei = [constraintsToChangei STLparseTrees(DiagnosedPredicates(1,i)).STLnodes(DiagnosedPredicates(2,i)).consBreakUp(j).consList];
        end
        constraintsToChangei = [constraintsToChangei ;repmat(DiagnosedPredicates(end,i), 1, length(constraintsToChangei(1,:)))];
        constraintsToChange = [constraintsToChange constraintsToChangei];
    end
    fileID = fopen('./InterfaceFiles/ChangingConts.txt', 'w');
    fprintf(fileID, '%d %d %d\n', constraintsToChange);
    fclose(fileID);
    [status, result] = unix('python ./PythonFiles/UpdateWeightedMILP.py');
end