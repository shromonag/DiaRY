function [diagObject, params, rob] = DiagSTLC_run_deterministic(diagObject, controller)
% STLC_run_deterministic    runs a receding horizon control problem
%                           for the system described by Sys, using the
%                           provided controller optimizer object, using the
%                           horizon defined by Sys.L
%
% Input:
%       Sys: an STLC_lti instance
%       controller: a YALMIP opmitizer object representing the system's
%                   optimization problem
%
% Output:
%       Sys: modified with additional system_data
%       params: controller data
%
% :copyright: TBD
% :license: TBD

global StopRequest
StopRequest=0;
Sys = diagObject.BluSTLsys;
Sys = Sys.reset_data();
rfprintf_reset();
current_time =0;

while ((current_time < Sys.time(end)-Sys.L*Sys.ts)&&StopRequest==0)
    out = sprintf('time:%g', current_time );
    rfprintf(out);
	diagObject.BluSTLsys = Sys;
    [diagObject, status] = diagCompute_input(diagObject, controller);
    Sys = diagObject.BluSTLsys;
    if status~=0
        rfprintf_reset();
        StopRequest=1;
        break;
    end
    
    Sys = Sys.apply_input();
    Sys = Sys.update_plot();
    drawnow;
    current_time= Sys.system_data.time(end);
end
diagObject.BluSTLsys = Sys;
fprintf('\n');
end

function Stop()
global StopRequest;
StopRequest = true;
end

