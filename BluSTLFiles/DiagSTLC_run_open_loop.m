function [diagObject] = DiagSTLC_run_open_loop(diagObject, controller)
% STLC_run_open_loop        runs an open-loop optimal control problem
%                           for the system described by Sys, using the
%                           provided controller optimizer object over the
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
diagObject.BluSTLsys = Sys;
[diagObject, status] = diagCompute_input(diagObject, controller);
Sys = diagObject.BluSTLsys;

if status==0
    current_time =0;
    while (current_time < Sys.model_data.time(end)-Sys.ts)
        out = sprintf('time:%g', current_time );
        rfprintf(out);
        Sys = Sys.apply_input();
        Sys = Sys.update_plot();
        drawnow;
        current_time= Sys.system_data.time(end);
    end
    fprintf('\n');
end

diagObject.BluSTLsys = Sys;

end

function Stop()
global StopRequest;
StopRequest = true;
end

