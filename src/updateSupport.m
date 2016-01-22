%% This function computes the support of the nodes

function STLparseTrees = updateSupport(STLparseTrees)
    for i  = 1 : length(STLparseTrees)
        j = length(STLparseTrees(i).STLnodes);
        while j ~= 0
            childNodes = STLparseTrees(i).STLnodes(j).childNodes;
            if childNodes ~= -1
                for k = 1 : length(childNodes)
                    if strcmp(STLparseTrees(i).STLnodes(j).nodeType, 'until')
                        STLparseTrees(i).STLnodes(childNodes(k)+1).support = STLparseTrees(i).STLnodes(j).support + [0 STLparseTrees(i).STLnodes(j).STLinterval(2)]; 
                    else
                        STLparseTrees(i).STLnodes(childNodes(k)+1).support = STLparseTrees(i).STLnodes(j).support + STLparseTrees(i).STLnodes(j).STLinterval; 
                    end
                    if length(STLparseTrees(i).STLnodes(childNodes(k)+1).consBreakUp) >= 1 && STLparseTrees(i).STLnodes(childNodes(k)+1).consBreakUp(end).t ~= 0
                        if STLparseTrees(i).STLnodes(childNodes(k)+1).support(1) > STLparseTrees(i).STLnodes(childNodes(k)+1).consBreakUp(end).t 
                            STLparseTrees(i).STLnodes(childNodes(k)+1).support(1) = STLparseTrees(i).STLnodes(childNodes(k)+1).consBreakUp(end).t;
                        end
                        if STLparseTrees(i).STLnodes(childNodes(k)+1).support(2) > STLparseTrees(i).STLnodes(childNodes(k)+1).consBreakUp(end).t
                            STLparseTrees(i).STLnodes(childNodes(k)+1).support(2) = STLparseTrees(i).STLnodes(childNodes(k)+1).consBreakUp(end).t;
                        end
                    end
                end
            end
            j = j - 1;
        end
    end
        
        
end