%% This function updates the model with values form the adversary

function status = writeConstraintsFile(varNames, varVals)
    fileID = fopen('./InterfaceFiles/UpdateMILPwithCons.txt', 'w');
    fprintf(fileID, '%d %d\n', [varNames; varVals]);
    fclose(fileID);

    [status, result] = unix('python ./PythonFiles/UpdateMILPwithCons.py');
end