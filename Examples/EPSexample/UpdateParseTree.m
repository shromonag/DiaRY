%% This function updates the constraints for each node of the STL parse Tree

function STLparseTrees = UpdateParseTree(updateReordering, reordering, expandedConstrMapping, STLparseTrees)
    startCons = 1;
    for i = 1 : length(STLparseTrees)
        for j = 1 : length(STLparseTrees(i).STLnodes)
            for k = 1 : length(STLparseTrees(i).STLnodes(j).consBreakUp(1,:))
                consSearch = startCons : startCons + STLparseTrees(i).STLnodes(j).consBreakUp(k).cons - 1;
                insertCons = [];
                for r = 1 : length(consSearch)
                    position = find(updateReordering(1,:) == consSearch(r));
                    insertCons = [insertCons position];
                    for m = 1 : length(position)
                        if expandedConstrMapping(position(m)+1, 2) > 0
                            insertCons = [insertCons [expandedConstrMapping(position(m), 4) + 1 : expandedConstrMapping(position(m) + 1, 4)]];
                        end
                    end
                end
                consList = [];
                for r = 1 : length(insertCons)
                    consList = [consList find(reordering(1,:) == insertCons(r))-1];
                end
                STLparseTrees(i).STLnodes(j).consBreakUp(k).consList = [consList; reordering(2,consList+1)];
                startCons = startCons + STLparseTrees(i).STLnodes(j).consBreakUp(k).cons;
            end
        end
    end
end