%% Function generating constraints for the requirement on generator to contactor delay

% G_[0, inf] (!g -> E_[0, m](!c))

function [genconCons, STLparseTrees] = generatorcontactorConstraint(EPSmodel, G, C, m)
    genconCons    = [];
    STLparseTrees = [];
    
    % G_[0, inf] (!g -> E_[0, m](!c))
    
    % 'phi' nodes
    notg = binvar(EPSmodel.noGen, EPSmodel.trajLength, 'full');
    notc = binvar(EPSmodel.noGen, EPSmodel.trajLength, 'full');
    
    for i = 1 : EPSmodel.noGen
        STLnodes = [];
        
        % 'phi' node for !g
        phigNode             = STLnode('phi', 0);
        phigNode.STLinterval = [0 0];
        phigNode.childNodes  = -1;
        
        consBreakUp = [];
        for j = 1 : EPSmodel.trajLength
            init        = length(genconCons);
            genconCons  = [genconCons notg(i,j) == not(G(i,j))];
            consBreakUp = [consBreakUp setsCons(j, length(genconCons) - init)];
        end
        phigNode.consBreakUp = consBreakUp;
        
        % 'not' node
        notNode             = STLnode('not', 1);
        notNode.childNodes  = 0;
        notNode.STLinterval = [0 0];
        
        n = binvar(1, EPSmodel.trajLength, 'full');
        
        consBreakUp = [];
        for j = 1 : EPSmodel.trajLength
            init = length(genconCons);
            genconCons = [genconCons n(j) == not(notg(i, j))];
            consBreakUp = [consBreakUp setsCons(j, length(genconCons) - init)];
        end
        notNode.consBreakUp = consBreakUp;
        
        % 'phi' node for !c
        phiNode             = STLnode('phi', 2);
        phiNode.STLinterval = [0 0];
        phiNode.childNodes  = -1;
        
        consBreakUp = [];
        for j = 1 : EPSmodel.trajLength
            init        = length(genconCons);
            genconCons  = [genconCons notc(i,j) == not(C(i,j))];
            consBreakUp = [consBreakUp setsCons(j, length(genconCons) - init)];
        end
        phiNode.consBreakUp = consBreakUp;
        
        % 'eventually' node
        evenNode             = STLnode('eventually', 3);
        evenNode.STLinterval = [1 m+1];
        evenNode.childNodes  = 2;
 
        e = binvar(1, EPSmodel.trajLength, 'full');
        
        consBreakUp = [];
        for j = 1 : EPSmodel.trajLength
            timePoints  = [j : min(j+m, EPSmodel.trajLength)];
            init        = length(genconCons);
            genconCons  = [genconCons e(j) == or(notc(i, timePoints))];
            consBreakUp = [consBreakUp setsCons(j, length(genconCons) - init)];
        end
        evenNode.consBreakUp = consBreakUp;
        
        % 'or' node
        orNode             = STLnode('or', 4);
        orNode.STLinterval = [0 0];
        orNode.childNodes  = [1, 3];
        
        o = binvar(1, EPSmodel.trajLength, 'full');
        
        consBreakUp = [];
        
        for j = 1 : EPSmodel.trajLength
            init        = length(genconCons);
            genconCons  = [genconCons o(j) == or(n(j), e(j))];
            consBreakUp = [consBreakUp setsCons(j, length(genconCons) - init)];
        end
        
        orNode.consBreakUp = consBreakUp;
        
        % 'G' node
        alwNode             = STLnode('always', 5);
        alwNode.STLinterval = [1 EPSmodel.trajLength];
        alwNode.childNodes  = 4;
        
        consBreakUp = [];
        
        for j = 1 : EPSmodel.trajLength
            init        = length(genconCons);
            genconCons  = [genconCons and(o(1, j:end)) == 1];
            consBreakUp = [consBreakUp setsCons(j, length(genconCons) - init)];
        end
        
        alwNode.consBreakUp = consBreakUp;
        
        STLnodes = [STLnodes phigNode notNode phiNode evenNode orNode alwNode];
        
        STLparseTrees = [STLparseTrees parseTree(STLnodes)];
        
    end
    
    % G_[0, inf] (g -> E_[0, m](c))
    
    % 'phi' nodes
    g = binvar(EPSmodel.noGen, EPSmodel.trajLength, 'full');
    c = binvar(EPSmodel.noGen, EPSmodel.trajLength, 'full');
    
    for i = 1 : EPSmodel.noGen
        STLnodes = [];
        
        % 'phi' node for g
        phigNode             = STLnode('phi', 0);
        phigNode.STLinterval = [0 0];
        phigNode.childNodes  = -1;
        
        consBreakUp = [];
        for j = 1 : EPSmodel.trajLength
            init        = length(genconCons);
            genconCons  = [genconCons g(i,j) == G(i,j)];
            consBreakUp = [consBreakUp setsCons(j, length(genconCons) - init)];
        end
        phigNode.consBreakUp = consBreakUp;
        
        % 'not' node
        notNode             = STLnode('not', 1);
        notNode.childNodes  = 0;
        notNode.STLinterval = [0 0];
        
        n = binvar(1, EPSmodel.trajLength, 'full');
        
        consBreakUp = [];
        for j = 1 : EPSmodel.trajLength
            init = length(genconCons);
            genconCons = [genconCons n(j) == not(g(i, j))];
            consBreakUp = [consBreakUp setsCons(j, length(genconCons) - init)];
        end
        notNode.consBreakUp = consBreakUp;
        
        % 'phi' node for c
        phiNode             = STLnode('phi', 2);
        phiNode.STLinterval = [0 0];
        phiNode.childNodes  = -1;
        
        consBreakUp = [];
        for j = 1 : EPSmodel.trajLength
            init        = length(genconCons);
            genconCons  = [genconCons c(i,j) == C(i,j)];
            consBreakUp = [consBreakUp setsCons(j, length(genconCons) - init)];
        end
        phiNode.consBreakUp = consBreakUp;
        
        % 'eventually' node
        evenNode             = STLnode('eventually', 3);
        evenNode.STLinterval = [1 m+1];
        evenNode.childNodes  = 2;
 
        e = binvar(1, EPSmodel.trajLength, 'full');
        
        consBreakUp = [];
        for j = 1 : EPSmodel.trajLength
            timePoints  = [j : min(j+m, EPSmodel.trajLength)];
            init        = length(genconCons);
            genconCons  = [genconCons e(j) == or(c(i, timePoints))];
            consBreakUp = [consBreakUp setsCons(j, length(genconCons) - init)];
        end
        evenNode.consBreakUp = consBreakUp;
        
        % 'or' node
        orNode             = STLnode('or', 4);
        orNode.STLinterval = [0 0];
        orNode.childNodes  = [1, 3];
        
        o = binvar(1, EPSmodel.trajLength, 'full');
        
        consBreakUp = [];
        
        for j = 1 : EPSmodel.trajLength
            init        = length(genconCons);
            genconCons  = [genconCons o(j) == or(n(j), e(j))];
            consBreakUp = [consBreakUp setsCons(j, length(genconCons) - init)];
        end
        
        orNode.consBreakUp = consBreakUp;
        
        % 'G' node
        alwNode             = STLnode('always', 5);
        alwNode.STLinterval = [1 EPSmodel.trajLength];
        alwNode.childNodes  = 4;
        
        consBreakUp = [];
        
        init        = length(genconCons);
        genconCons  = [genconCons and(o(alwNode.STLinterval(1) : alwNode.STLinterval(2))) == 1];
        consBreakUp = [consBreakUp setsCons(1, length(genconCons) - init)];
        
        
        alwNode.consBreakUp = consBreakUp;
        
        STLnodes = [STLnodes phigNode notNode phiNode evenNode orNode alwNode];
        
        STLparseTrees = [STLparseTrees parseTree(STLnodes)];
        
    end
end