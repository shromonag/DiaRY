%% This function performs a binary search to find the best adversary

function DiagSys = FixAdversaryInterval(DiagSys, beginEpsilon, minEpsilon)

    backUpSys = DiagSys.BluSTLsys;
    [backUpSys, status_u] = compute_input(backUpSys,backUpSys.controller);
    stop = 0;
    
    t = findingFailingTime(DiagSys.pathToController, DiagSys.STLparseTrees, DiagSys.BluSTLsys.nw);
    ulChanged = [];
    
    if status_u ~= 0
        epsilon = beginEpsilon;
        for i = 1 : DiagSys.BluSTLsys.nw
            [wMin, wMax, ul] = pruneSpace(DiagSys.w_min(i), DiagSys.w_max(i), backUpSys.model_data.Wbad(i,:), epsilon, t{i});
            DiagSys.w_min(i) = wMin;
            DiagSys.w_max(i) = wMax;
            ulChanged = [ulChanged ul];
        end
        
        status_w = [];
        con = 1;
        while (con)
            backUpSys.adversary = diagGet_adversary(DiagSys);
            [backUpSys, status_w] = compute_disturbance(backUpSys,backUpSys.adversary);
            if status_w==0 % we found a bad disturbance 
                cont=1;
            elseif status_w==1; % control is good 
                cont=0;
            elseif status_w==-1; % some issue with compute_disturbance
                cont=0;
            end

            status_u = 1;
            if cont == 1
                [backUpSys, status_u] = compute_input(backUpSys,backUpSys.controller);
                if status_u == 0 && abs(epsilon - minEpsilon) < 0.0001
                    stop = 1;
                end
            end
            epsilon = max(epsilon/2, minEpsilon);
            if (cont == 0 || status_u == 0) && stop == 0
                for i = 1 : DiagSys.BluSTLsys.nw
                    if ulChanged(i) == 1
                        DiagSys.w_max(i) = DiagSys.w_max(i) + epsilon;
                    else
                        DiagSys.w_min(i) = DiagSys.w_min(i) - epsilon;
                    end
                end
            elseif stop == 0
                ulChanged = [];
                for i = 1 : DiagSys.BluSTLsys.nw
                    [wMin, wMax, ul] = pruneSpace(DiagSys.w_min(i), DiagSys.w_max(i), backUpSys.model_data.Wbad(i,:), epsilon, t{i});
                    DiagSys.w_min(i) = wMin;
                    DiagSys.w_max(i) = wMax;
                    ulChanged = [ulChanged ul];
                end
            end
            
            if status_u && abs(epsilon - minEpsilon) > 0.0001
                con = 1;
            else
                con = 0;
            end
        end            
    end
    for i = 1 : DiagSys.BluSTLsys.nw
        w_min = DiagSys.w_min(i);
        w_max = DiagSys.w_max(i);
        w_min = ceil(w_min * 100);
        w_min = w_min/100;
        w_max = floor(w_max * 100);
        w_max = w_max/100;   
        DiagSys.w_min(i) = w_min;
        DiagSys.w_max(i) = w_max;
    end
end