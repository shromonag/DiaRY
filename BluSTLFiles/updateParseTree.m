%% Function to update the constraints list in the parse tree

function STLparseTrees = updateParseTree(mapConstraints, reordering, expandedConsMapping, STLparseTrees)
    mapConstraints = mapConstraints+1;
    startSTLnode = mapConstraints(1)+1;
    for i = 1 : length(STLparseTrees)
        for j = 1 : length(STLparseTrees(i).STLnodes)
            for k = 1 : length(STLparseTrees(i).STLnodes(j).consBreakUp)
                noOfCons = STLparseTrees(i).STLnodes(j).consBreakUp(k).cons;
                consSearch = startSTLnode : startSTLnode + noOfCons - 1;
                insertCons = [];
                for r = 1 : length(consSearch)
                    if (expandedConsMapping(consSearch(r)+1, 2) > 0)
                        insertCons = [insertCons [expandedConsMapping(consSearch(r),4) + 1 : expandedConsMapping(consSearch(r)+1, 4)]];
                    end
                end
                consSearch = [consSearch insertCons];
                consList = [];
                for r = 1 : length(consSearch)
                    consList = [consList find(reordering(1,:) == consSearch(r))-1];
                end
                STLparseTrees(i).STLnodes(j).consBreakUp(k).consList = [consList; reordering(2,consList+1)];
                startSTLnode = startSTLnode + noOfCons;
            end
        end
        insertCons = [];
        consSearch = startSTLnode : startSTLnode + STLparseTrees(i).addCons - 1;
        for k = 1 : length(consSearch)
            if (expandedConsMapping(consSearch(k)+1, 2) > 0)
                insertCons = [insertCons [expandedConsMapping(consSearch(k),4) + 1 : expandedConsMapping(consSearch(k)+1, 4)]];
            end
        end
        consSearch = [consSearch insertCons];
        consList = [];
        for k = 1 : length(consSearch)
            consList = [consList find(reordering(1,:) == consSearch(k))-1];
        end
        STLparseTrees(i).addConsMILP = [consList; reordering(2,consList+1)];
        
    end
end