%% This function prints out the feedback

function status = feedbackSTLparseTrees(STLparseTrees, t, L)
    Timing = {};
    for i = 1 : length(STLparseTrees)
        fprintf('Predicate Changes for STL %d \n', i);
        Timing = {};
        for j = 1 : length(STLparseTrees(i).STLnodes)
            if strcmp(STLparseTrees(i).STLnodes(j).nodeType, 'phi')
                fprintf('Slack for Predicate node %d : %f\n', j, STLparseTrees(i).STLnodes(j).slackPred);                   
            elseif strcmp(STLparseTrees(i).STLnodes(j).nodeType, 'always') || strcmp(STLparseTrees(i).STLnodes(j).nodeType, 'eventually') || strcmp(STLparseTrees(i).STLnodes(j).nodeType, 'until')
                if STLparseTrees(i).STLnodes(j).sigma(2) - STLparseTrees(i).STLnodes(j).sigma(1) <= 0
                    Timing = {};
                    break;
                elseif STLparseTrees(i).STLnodes(j).sigma(2) ~= STLparseTrees(i).STLnodes(j).STLinterval(2) || STLparseTrees(i).STLnodes(j).sigma(1) ~= STLparseTrees(i).STLnodes(j).STLinterval(1)
                    Timing{end+1} = [j STLparseTrees(i).STLnodes(j).sigma];
                end
            end
        end
        fprintf('---------------------------------------------------------------------\n');
        if length(Timing) == 0
            fprintf('No intervals changes possible\n');
        else
            fprintf('Interval Changes for STL %d \n', i);
            for k = 1 : length(Timing)
                if strcmp(STLparseTrees(i).STLnodes(Timing{k}(1)).nodeType, 'always')
                    if Timing{k}(3) < L
                        fprintf('Interval change for Always node %d = [%f, %f]\n', Timing{k}(1), (Timing{k}(2)-1)*t, (Timing{k}(3)-1)*t);
                    else
                        fprintf('Interval change for Always node %d = [%f, %f]\n', Timing{k}(1), (Timing{k}(2)-1)*t, inf);
                    end
                elseif strcmp(STLparseTrees(i).STLnodes(Timing{k}(1)).nodeType, 'eventually')
                    if Timing{k}(3) < L
                        fprintf('Interval change for Eventually node %d = [%f, %f]\n', Timing{k}(1), (Timing{k}(2)-1)*t, (Timing{k}(3)-1)*t);
                    else
                        fprintf('Interval change for Always node %d = [%f, %f]\n', Timing{k}(1), (Timing{k}(2)-1)*t, inf);
                    end
                elseif strcmp(STLparseTrees(i).STLnodes(Timing{k}(1)).nodeType, 'until')
                    if Timing{k}{3} < L
                        fprintf('Interval change for Until node %d = [%f, %f]\n', Timing{k}(1), (Timing{k}(2)-1)*t, (Timing{k}(3)-1)*t);
                    else
                        fprintf('Interval change for Until node %d = [%f, %f]\n', Timing{k}(1), (Timing{k}(2)+1)*t, inf);
                    end
                end
            end
        end
        fprintf('---------------------------------------------------------------------\n');
    end
    
    fprintf('Since the values returned maybe in floating point, always include a small epsilon while correcting the predicate or interval\n');
end