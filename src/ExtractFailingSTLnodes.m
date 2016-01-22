%% This function extracts the failing STL nodes after comparing with the IIS
% STL number
% STL node
% Time of failure
% Failing Constraint

function STLnodesFailing = ExtractFailingSTLnodes(constraintNumbers, STLparseTree)
    STLnodesFailing = [];
    for i = 1 : length(constraintNumbers)
        for j = 1 : length(STLparseTree)
            for k = 1 : length(STLparseTree(j).STLnodes)
                for r = 1 : length(STLparseTree(j).STLnodes(k).consBreakUp)
                    loc = find(STLparseTree(j).STLnodes(k).consBreakUp(r).consList(1,:) == constraintNumbers(i));
                    if length(loc) > 0
                        STLnodesFailing = [STLnodesFailing [j; k; STLparseTree(j).STLnodes(k).consBreakUp(r).t; constraintNumbers(i)]];
                        break;
                    end
                end
            end
        end
    end
end