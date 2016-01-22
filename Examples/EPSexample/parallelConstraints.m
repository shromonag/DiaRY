%% This function find the constraints for non-parallelization

function [parCons, STLparseTrees] = parallelConstraints(EPSmodel, Cint, C)
    parCons       = [];
    STLparseTrees = [];
    
    c    = binvar(EPSmodel.noCon, EPSmodel.trajLength, 'full');
    cint = binvar(EPSmodel.noCon, EPSmodel.trajLength, 'full');
    
    % G_[0,inf] (!and(C...))
    STLnodes = [];
    
    % 'phi' nodes
    for i = 1 : EPSmodel.noCon
        % 'phi' node for c
        phiNode             = STLnode('phi', i-1);
        phiNode.STLinterval = [0 0];
        phiNode.childNodes  = -1;
        
        consBreakUp = [];
        for j = 1 : EPSmodel.trajLength
            init        = length(parCons);
            parCons     = [parCons c(i,j) == C(i,j)];
            consBreakUp = [consBreakUp setsCons(j, length(parCons) - init)];
        end
        phiNode.consBreakUp = consBreakUp;
        
        STLnodes = [STLnodes phiNode];
    end
    
    % 'and' node
    
    a = binvar(1, EPSmodel.trajLength, 'full');
    
    andNode             = STLnode('and', length(STLnodes));
    andNode.childNodes  = [0 : length(STLnodes)-1];
    andNode.STLinterval = [0 0];
    
    consBreakUp = [];
    for i = 1 : EPSmodel.trajLength
        init = length(parCons);
        parCons = [parCons a(i) == and(c(:,i))];
        consBreakUp = [consBreakUp setsCons(i, length(parCons) - init)]; 
    end
    andNode.consBreakUp = consBreakUp;
    
    STLnodes = [STLnodes andNode];
    
    % 'not' node
    
    n = binvar(1, EPSmodel.trajLength, 'full');
    
    notNode             = STLnode('not', length(STLnodes));
    notNode.childNodes  = length(STLnodes) - 1;
    notNode.STLinterval = [0 0];
    
    consBreakUp = [];
    
    for i = 1 : EPSmodel.trajLength
        init = length(parCons);
        parCons = [parCons n(i) == not(a(i))];
        consBreakUp = [consBreakUp setsCons(i, length(parCons) - init)];
    end
    
    notNode.consBreakUp = consBreakUp ;
    
    STLnodes = [STLnodes notNode];
    
    % 'G' node
    alwNode             = STLnode('always', length(STLnodes));
    alwNode.childNodes  = length(STLnodes) - 1;
    alwNode.STLinterval = [1 EPSmodel.trajLength];
    
    consBreakUp = [];
    
    init        = length(parCons);
    parCons     = [parCons and(n(alwNode.STLinterval(1) : alwNode.STLinterval(2))) == 1];
    consBreakUp = [consBreakUp setsCons(1, length(parCons) - init)];
    
    alwNode.consBreakUp = consBreakUp;
    
    STLnodes = [STLnodes alwNode];
    
    STLparseTrees = [STLparseTrees parseTree(STLnodes)];
    
    % G_[0,inf] (!and(Cint...))
    STLnodes = [];
    
    % 'phi' nodes
    for i = 1 : EPSmodel.noCon
        % 'phi' node for c
        phiNode             = STLnode('phi', i-1);
        phiNode.STLinterval = [0 0];
        phiNode.childNodes  = -1;
        
        consBreakUp = [];
        for j = 1 : EPSmodel.trajLength
            init        = length(parCons);
            parCons     = [parCons cint(i,j) == Cint(i,j)];
            consBreakUp = [consBreakUp setsCons(j, length(parCons) - init)];
        end
        phiNode.consBreakUp = consBreakUp;
        
        STLnodes = [STLnodes phiNode];
    end
    
    % 'and' node
    
    a = binvar(1, EPSmodel.trajLength, 'full');
    
    andNode             = STLnode('and', length(STLnodes));
    andNode.childNodes  = [0 : length(STLnodes)-1];
    andNode.STLinterval = [0 0];
    
    consBreakUp = [];
    for i = 1 : EPSmodel.trajLength
        init = length(parCons);
        parCons = [parCons a(i) == and(cint(:,i))];
        consBreakUp = [consBreakUp setsCons(i, length(parCons) - init)]; 
    end
    andNode.consBreakUp = consBreakUp;
    
    STLnodes = [STLnodes andNode];
    
    % 'not' node
    
    n = binvar(1, EPSmodel.trajLength, 'full');
    
    notNode             = STLnode('not', length(STLnodes));
    notNode.childNodes  = length(STLnodes) - 1;
    notNode.STLinterval = [0 0];
    
    consBreakUp = [];
    
    for i = 1 : EPSmodel.trajLength
        init = length(parCons);
        parCons = [parCons n(i) == not(a(i))];
        consBreakUp = [consBreakUp setsCons(i, length(parCons) - init)];
    end
    
    notNode.consBreakUp = consBreakUp ;
    
    STLnodes = [STLnodes notNode];
    
    % 'G' node
    alwNode             = STLnode('always', length(STLnodes));
    alwNode.childNodes  = length(STLnodes) - 1;
    alwNode.STLinterval = [1 EPSmodel.trajLength];
    
    consBreakUp = [];
    
    init        = length(parCons);
    parCons     = [parCons and(n(alwNode.STLinterval(1) : alwNode.STLinterval(2))) == 1];
    consBreakUp = [consBreakUp setsCons(1, length(parCons) - init)];
    
    alwNode.consBreakUp = consBreakUp;
    
    STLnodes = [STLnodes alwNode];
    
    STLparseTrees = [STLparseTrees parseTree(STLnodes)];
    
end