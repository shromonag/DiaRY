%% This function removes duplicates

function STLnodesFailing = removeDuplicates(STLparseTrees, STLnodesFailing)
    contained = [];
    ToDelete  = [];
    
    for i = 1 : length(STLnodesFailing(1,:))
        if strcmp(STLparseTrees(STLnodesFailing(1,i)).STLnodes(STLnodesFailing(2,i)).nodeType, 'phi')
            if length(contained) > 0
                STLloc = find(contained(1,:) == STLnodesFailing(1,i));
                philoc = find(contained(2,STLloc) == STLnodesFailing(2,i));
            else
                STLloc = [];
                philoc = [];
            end
            if length(STLloc) == 0 || length(philoc) == 0
                contained = [contained [STLnodesFailing(1,i); STLnodesFailing(2,i)]];
            else
                ToDelete = [ToDelete i];
            end
        else
            ToDelete = [ToDelete i];
        end
    end
    STLnodesFailing(:,ToDelete) = [];    
end

