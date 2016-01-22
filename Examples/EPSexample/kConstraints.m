%% This function imposes a constraint on the value of 'k'

function [kCons, STLparseTree] = kConstraints(EPSmodel, k, kMin, kMax)
    kCons    = [];
    
    % G_[0,inf] (0 <= k <= 4)
    
    kLimits = intvar(2, EPSmodel.trajLength, 'full');
    a       = binvar(1, EPSmodel.trajLength, 'full');
    g       = binvar(1);
    
    % 'phi' node for 0 <=k
    phiNodell             = STLnode('phi', 0);
    phiNodell.STLinterval = [0 0];
    phiNodell.childNodes  = -1;
        
    consBreakUp = [];
    
    for i = 1 : EPSmodel.trajLength
        init        = length(kCons);
        kCons       = [kCons k - kMin <= kLimits(1,i) <= k - kMin];
        consBreakUp = [consBreakUp setsCons(i, length(kCons) - init)];
    end
    
    phiNodell.consBreakUp = consBreakUp;
        
    % 'phi' node for k <= kMax
    phiNodeul             = STLnode('phi', 1);
    phiNodeul.STLinterval = [0 0];
    phiNodeul.childNodes  = -1;
        
    consBreakUp = [];
    
    for i = 1 : EPSmodel.trajLength
        init        = length(kCons);
        kCons       = [kCons kMax - k <= kLimits(2,i) <= kMax - k];
        consBreakUp = [consBreakUp setsCons(i, length(kCons) - init)];
    end
    
    phiNodeul.consBreakUp = consBreakUp;
    
    % 'and' node
    andNode             = STLnode('and', 2);
    andNode.childNodes  = [0 1];
    andNode.STLinterval = [0 0];
    
    consBreakUp = [];
    
    for i = 1 : EPSmodel.trajLength
        init        = length(kCons);
        kCons       = [kCons a(1,i) == and(kLimits(1,i) >= 0, kLimits(2,i) >= 0)];
        consBreakUp = [consBreakUp setsCons(i, length(kCons) - init)];
    end
    
    andNode.consBreakUp = consBreakUp;
    
    % 'alw' node
    alwNode             = STLnode('always', 3);
    alwNode.STLinterval = [1 EPSmodel.trajLength];
    alwNode.childNodes  = 2;
    
    consBreakUp = [];
    
    init        = length(kCons);
    kCons       = [kCons and(a(alwNode.STLinterval(1) : alwNode.STLinterval(2))) == 1];
    consBreakUp = [consBreakUp setsCons(1, length(kCons) - init)];
    
    alwNode.consBreakUp = consBreakUp;
    
    STLparseTree = parseTree([phiNodell phiNodeul andNode alwNode]);
end