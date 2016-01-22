%% Updates the reordering order

function updateReordering = UpdatedReordering(mapImpliesF, num)
    updateReordering = [1 : num];
    constraintNums   = [];
    for i = 1 : length(mapImpliesF(1,:))
        constraintNums = [constraintNums repmat(mapImpliesF(1,i),1 , mapImpliesF(2,i))];
    end
    updateReordering(mapImpliesF(1,:)) = [];
    updateReordering                   = [updateReordering constraintNums];
    
end