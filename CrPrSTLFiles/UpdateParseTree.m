%% This function updated the STL nodes with the constraints mapped to the MILP

function STLnodes = UpdateParseTree(reorderingUpdate, reordering, expandedConstrMapping, STLnodes)
    startCons = 1;
    for i = 1 : length(STLnodes)
        if length(STLnodes(i).consBreakUp) >= 1
            for j = 1 : length(STLnodes(i).consBreakUp(1,:))
                consSearch = startCons : startCons + STLnodes(i).consBreakUp(j).cons - 1;
                insertCons = [];
                for k = 1 : length(consSearch)
                    position = find(reorderingUpdate(2,:) == consSearch(k));
                    begCons = reorderingUpdate(4,position)-reorderingUpdate(3,position)+1;
                    corresCons = begCons : reorderingUpdate(4, position);
                    for r = 1 : length(corresCons)
                        if expandedConstrMapping(corresCons(r)+1, 2) > 0
                            insertCons = [insertCons [expandedConstrMapping(corresCons(r),4) + 1 : expandedConstrMapping(corresCons(r)+1, 4)]];
                        end
                    end
                end
                consSearch = [consSearch insertCons];
                consList = [];
                for r = 1 : length(consSearch)
                    consList = [consList find(reordering(1,:) == consSearch(r))-1];
                end
                STLnodes(i).consBreakUp(j).consList = [consList; reordering(2,consList+1)];
                startCons = startCons + STLnodes(i).consBreakUp(j).cons;
            end
        end
    end
            
end
