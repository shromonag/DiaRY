%% This function collects constraints for the contactor dynamics

function dynCons = contactorDynamics(EPSmodel, Cint, C, k, kMax)
    dynCons = [];
    for i = 0 : kMax
        for j = 1 : EPSmodel.trajLength - i
            for r = 1 : EPSmodel.noCon
                dynCons = [dynCons implies(k == i, C(r,j+i) == Cint(r,j))];
            end
        end
    end
end