%% This function updated the slacks into the parse trees

function STLparseTrees = updateWithSlacks(slackConstraints, STLparseTrees)
    for i = 1 : length(STLparseTrees)
        for j = 1 : length(STLparseTrees(i).STLnodes)
            if strcmp(STLparseTrees(i).STLnodes(j).nodeType, 'phi')
                for k = 1 : length(STLparseTrees(i).STLnodes(j).consBreakUp)
                    constraintList = STLparseTrees(i).STLnodes(j).consBreakUp(k).consList(1,:);
                    constraintList = [constraintList; zeros(1,length(constraintList))];
                    for r = 1 : length(STLparseTrees(i).STLnodes(j).consBreakUp(k).consList(1,:))
                        for m = 1 : length(constraintList(1,:))
                            loc = find(slackConstraints(1,:) == constraintList(1,m));
                            if length(loc) > 0
                                constraintList(2, m) = slackConstraints(2,loc);
                            end
                        end
                    end
                    conListabs = abs(constraintList(2,:));
                    [val,maxLoc] = max(conListabs);
                    STLparseTrees(i).STLnodes(j).consBreakUp(k).slack = constraintList(2, maxLoc);
                    STLparseTrees(i).STLnodes(j).slackTime = [STLparseTrees(i).STLnodes(j).slackTime [STLparseTrees(i).STLnodes(j).consBreakUp(k).t; STLparseTrees(i).STLnodes(j).consBreakUp(k).slack]];
                end
                absSlacks = abs(STLparseTrees(i).STLnodes(j).slackTime(2,:));
                [val,maxLoc] = max(absSlacks);
                STLparseTrees(i).STLnodes(j).slackPred = STLparseTrees(i).STLnodes(j).slackTime(2,maxLoc);
            end
        end
    end                        
end