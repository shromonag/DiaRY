%% This function recursively goes through the tree and updates the sigmas

function STLparseTrees = updateSigma(STLparseTrees)
    for i = 1 : length(STLparseTrees)
        for j = 1 : length(STLparseTrees(i).STLnodes)
            if strcmp(STLparseTrees(i).STLnodes(j).nodeType, 'phi') == 1
                loc = find(STLparseTrees(i).STLnodes(j).slackTime(2,:) == 0);
                timeLoc = STLparseTrees(i).STLnodes(j).slackTime(1,loc);
                toDelete = [];
                for k = 1 : length(timeLoc)
                    if timeLoc(k) > STLparseTrees(i).STLnodes(j).support(2) || timeLoc(k) < STLparseTrees(i).STLnodes(j).support(1)
                        toDelete = [toDelete k];
                    end
                end
                timeLoc(toDelete) = [];
                timeLoc = longestInterval(timeLoc);
                if length(STLparseTrees(i).STLnodes(j).slackTime) > 0
                    STLparseTrees(i).STLnodes(j).sigma = [min(timeLoc) max(timeLoc)];                    
                end
            elseif strcmp(STLparseTrees(i).STLnodes(j).nodeType, 'and') == 1 || strcmp(STLparseTrees(i).STLnodes(j).nodeType, 'or') == 1 
                childNodes = STLparseTrees(i).STLnodes(j).childNodes;
                STLparseTrees(i).STLnodes(j).sigma = contained(STLparseTrees(i).STLnodes(childNodes(1)+1).sigma, STLparseTrees(i).STLnodes(childNodes(2)+1).sigma);
            elseif strcmp(STLparseTrees(i).STLnodes(j).nodeType, 'always') == 1 || strcmp(STLparseTrees(i).STLnodes(j).nodeType, 'not') == 1
                childNode = STLparseTrees(i).STLnodes(j).childNodes;
                STLparseTrees(i).STLnodes(j).sigma = STLparseTrees(i).STLnodes(childNode+1).sigma;
            end
        end
    end
end

function interval = contained(interval1, interval2)
    if numel(interval1) == 0 || numel(interval1) == 0
        interval = [];
        return;
    end
    int1lb = interval1(1);
    int1ub = interval1(2);
    
    int2lb = interval2(1);
    int2ub = interval2(2);
    
    if max(int1lb, int2lb) < min(int1ub, int2ub)
        interval = [max(int1lb, int2lb) min(int1ub, int2ub)];
    else
        interval = [-1 -1];
    end
end

function loc = longestInterval(loc)
    i = 1;
    maxCount = 0;
    maxLocStart = 0;
    maxLocEnd = 0;
    
    while i < length(loc) - 1
        count = 0;
        while i+1 <= length(loc) && loc(i+1) == (loc(i) + 1)
            i = i + 1;
            count = count + 1;
        end
        if count > maxCount
            maxCount = count;
            maxLocEnd = loc(i);
            maxLocStart = maxLocEnd - count;
        end
        i = i + 1;
    end
    if length(loc) > 1
        loc = [maxLocStart : maxLocEnd];
    end
end