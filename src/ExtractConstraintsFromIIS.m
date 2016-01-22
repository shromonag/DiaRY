%% This function extracts the constraints from an IIS 

function constraintNumbers = ExtractConstraintsFromIIS(infeasModel)
    constraintNames = infeasModel.constrnames;
    constraintNumbers = [];
    for i = 1 : length(constraintNames)
        name = constraintNames{i};
        constraintNumbers = [constraintNumbers str2num(name(2:end))];
    end
end
