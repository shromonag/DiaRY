%% Unconstrained Repair
% Just solve the updated GurobiModel
% Locate the non-zero slacks that have been added :

function slackedConstraints = unconstrainedRepair(updatedGurobiModel, soln)
    slackLocs = [];
    for i = 1 : length(updatedGurobiModel.varnames)
        if updatedGurobiModel.varnames{i}(1) == 's'
            slackLocs = [slackLocs i];
        end
    end
    nonZeroSlacks = find(soln.x(slackLocs) > 1e-4);
    
    % Collect the values of the slacks
    slackedConstraints = [];
    for i = 1 : length(nonZeroSlacks)
        consNum = str2num(updatedGurobiModel.varnames{slackLocs(nonZeroSlacks(i))}(2:end-1));
        if updatedGurobiModel.varnames{slackLocs(nonZeroSlacks(i))}(end) == 'p'
            if length(slackedConstraints) > 0 && length(find(slackedConstraints(1,:) == consNum)) > 0
                loc = find(slackedConstraints(1,:) == consNum);
                slackedConstraints(2,loc) = slackedConstraints(2,loc) + soln.x(slackLocs(nonZeroSlacks(i)));
            else
                slackedConstraints = [slackedConstraints [consNum; soln.x(slackLocs(nonZeroSlacks(i)))]];
            end
        else
            if length(slackedConstraints) > 0 && length(find(slackedConstraints(1,:) == consNum)) > 0
                loc = find(slackedConstraints(1,:) == consNum);
                slackedConstraints(2,loc) = slackedConstraints(2,loc) - soln.x(slackLocs(nonZeroSlacks(i)));
            else
                slackedConstraints = [slackedConstraints [consNum; -soln.x(slackLocs(nonZeroSlacks(i)))]];
            end
        end
    end
end