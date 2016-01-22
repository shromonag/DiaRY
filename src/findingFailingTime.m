%% Finding failing times for the 'w'

function t = findingFailingTime(pathToController, STLparseTrees, nw)
    [DiagnosedPredicates, updatedGurobiModel, allConsNum] = DiagnoseMILP(pathToController, STLparseTrees, 0);
    t = {};
    for i = length(STLparseTrees) : -1 : length(STLparseTrees) - nw + 1
        loc = find(DiagnosedPredicates(1,:) == i);
        tnw = [];
        if length(loc) ~= 0
            for j = 1 : length(STLparseTrees(i).STLnodes(1).consBreakUp)
                if find(allConsNum == STLparseTrees(i).STLnodes(1).consBreakUp(j).consList(1))
                    tnw = [tnw STLparseTrees(i).STLnodes(1).consBreakUp(j).t];
                end
            end
        end
        t{end+1} = tnw;
    end
end