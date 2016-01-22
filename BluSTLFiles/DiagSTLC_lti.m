%% This class is an extension of the STLC_lti class of BluSTL with constructs required for diagnosis

classdef DiagSTLC_lti
    % Diagnosis Related additional constructs
    properties
        BluSTLsys
        STLparseTrees
        pathToController
        pathToAdversary
        debugAdv
        w_min
        w_max
        initWref
        diagMode
        isAuto
        autoInfo
    end
    
    % Constructor
    methods
        function DiagObject = DiagSTLC_lti(Sys)
            DiagObject.BluSTLsys = Sys;
        end
        
        function [controller, diagObject] = diagGet_controller(diagObject)
            %STLC_get_controller(diagObject.BluSTLsys);
            diagObject.BluSTLsys.sysd = c2d(diagObject.BluSTLsys.sys, diagObject.BluSTLsys.ts);
            [controller, STLparseTrees] = DiagSTLC_get_controller(diagObject.BluSTLsys, diagObject.debugAdv);
            diagObject.STLparseTrees = STLparseTrees;
        end
        
        function [diagObject, status] = diagCompute_input(diagObject, controller)
            [diagObject, status] = DiagSTLC_compute_input(diagObject, controller, diagObject.debugAdv);
        end
        
        function [diagObject, status_u, status_w] = diagCompute_input_adv(diagObject, controller, adversary)
            [diagObject, status_u, status_w] = DiagSTLC_compute_input_adv(diagObject, controller, adversary);
        end
        
        function adversary = diagGet_adversary(diagObject)
            adversary = DiagSTLC_get_adversary(diagObject.BluSTLsys, diagObject.w_min, diagObject.w_max);
        end
        
        function [diagObject] = diagRun_open_loop(diagObject, controller)
            diagObject = DiagSTLC_run_open_loop(diagObject, controller);
        end
        
        function [diagObject] = diagRun_deterministic(diagObject, controller)
            diagObject = DiagSTLC_run_deterministic(diagObject, controller);
        end
        
        function diagObject = diagRun_open_loop_adv(diagObject, controller, adversary)
            Sys = diagObject.BluSTLsys;
            Sys = Sys.reset_data();
            diagObject.BluSTLsys = Sys;
            [diagObject, status_u, status_w] = diagCompute_input_adv(diagObject, controller, adversary);
            Sys = diagObject.BluSTLsys; 
            if (status_w ~= 1)
                warning('The control input might not be robust.')
            end
            
            if status_u==0
                current_time =0;
                while (current_time < Sys.model_data.time(end)-Sys.ts)
                    out = sprintf('time:%g', current_time );
                    rfprintf(out);
                    Sys = Sys.apply_input();
                    Sys = Sys.update_plot();
                    drawnow;
                    current_time= Sys.system_data.time(end);
                end
                diagObject.BluSTLsys = Sys;
                fprintf('\n');
            end
            
        end
        
        function diagObject = diagRun_adversarial(diagObject, controller, adversary)
            global StopRequest;
            StopRequest=0;
            Sys = diagObject.BluSTLsys;
            Sys = Sys.reset_data();
            rfprintf_reset();
            current_time =0;
            while ((current_time < Sys.time(end)-Sys.L*Sys.ts)&&StopRequest==0)
                out = sprintf('time:%g', current_time );
                rfprintf(out);
                diagObject.BluSTLsys = Sys;
                [diagObject, status_u, status_w] = diagCompute_input_adv(diagObject, controller, adversary);
                Sys = diagObject.BluSTLsys; 
                if status_u~=0
                    rfprintf_reset();
                    StopRequest=1;
                else
                    Sys = Sys.apply_input();
                    Sys = Sys.update_plot();
                    drawnow;
                    current_time= Sys.system_data.time(end);
                end
            end
            diagObject.BluSTLsys = Sys;
            fprintf('\n');
        end
    end
end