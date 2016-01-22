%% This function calls the python file that updated the MILP with failing predicates

function status = UpdatedMILP(STLparseTrees, STLnodesFailing)
    constraintsToChange = [];
    for i = 1 : length(STLnodesFailing(1,:))
        if strcmp(STLparseTrees(STLnodesFailing(1,i)).STLnodes(STLnodesFailing(2,i)).nodeType, 'phi')
            for j = 1 : length(STLparseTrees(STLnodesFailing(1,i)).STLnodes(STLnodesFailing(2,i)).consBreakUp(1,:))
                if STLparseTrees(STLnodesFailing(1,i)).STLnodes(STLnodesFailing(2,i)).consBreakUp(j).t > 0
                    constraintsToChange = [constraintsToChange STLparseTrees(STLnodesFailing(1,i)).STLnodes(STLnodesFailing(2,i)).consBreakUp(j).consList];
                end
            end
            
        end
    end
    fileID = fopen('./InterfaceFiles/ChangingConts.txt', 'w');
    fprintf(fileID, '%d %d\n', constraintsToChange);
    fclose(fileID);
    [status, result] = unix('python ./PythonFiles/UpdateMILP.py');
end
