%% This function prunes the space of the adversarial variables

function [wMin, wMax, ul] = pruneSpace(wMin, wMax, wCand, epsilon, t)
    timeSteps = length(wCand(1,:));
    numCand   = length(wCand(:,1));
    change    = [];
    if length(t) == 0
        return;
    end
    for i = 1 : numCand
        wHmax = max(wCand(i,t));
        wHmin = min(wCand(i,t));
        if wMax - wHmax < wHmin - wMin
            change = [change [wMin; wHmax - epsilon]];
            ul     = 1;
        else
            change = [change [wHmin + epsilon; wMax]];
            ul     = 0;
        end
    end
    range = change(2,:) - change(1,:);

    [maxRange, maxLoc] = max(range);
    
    wMin = change(1, maxLoc);
    wMax = change(2, maxLoc);
    
end