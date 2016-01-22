function [diagObject, status_u, status_w] = DiagSTLC_compute_input_adv(diagObject, controller, adversary)

iter=0;
status_w = [];

[diagObject, status_u] = diagCompute_input(diagObject,controller);
cont = (iter<diagObject.BluSTLsys.max_react_iter)&&(status_u==0);
while (cont)
    [diagObject.BluSTLsys, status_w] = compute_disturbance(diagObject.BluSTLsys,adversary);
    if status_w==0 % we found a bad disturbance 
        cont=1;
    elseif status_w==1; % control is good 
        cont=0;
    elseif status_w==-1; % some issue with compute_disturbance
        cont=0;
    end
        
    iter= iter+1;
    cont = cont&&(iter<diagObject.BluSTLsys.max_react_iter);
    [diagObject, status_u] = diagCompute_input(diagObject,controller);
    if status_u ~= 0
        if diagObject.debugAdv == 1
            fprintf('Update all the adversarial control variable limits to : \n');
            for i = 1 : diagObject.BluSTLsys.nw
                fprintf('w(%d) = [%f, %f]', i, diagObject.w_min(i), diagObject.w_max(i));
            end
        end
        break;
    end
end
end