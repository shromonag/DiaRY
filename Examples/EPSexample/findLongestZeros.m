%% Finds the longest continuous set of 0's

function maxNum = findLongestZeros(BusVals)
    maxNum = 0;
    num    = 0;
    for i  = 1 : size(BusVals, 1)
        num = 0;
        for j = 1 : size(BusVals, 2)
            if BusVals(i,j) == 0
                num = num + 1;
            else
               maxNum = max(maxNum, num);
               num    = 0;
            end
        end
        maxNum = max(maxNum, num);
    end
end