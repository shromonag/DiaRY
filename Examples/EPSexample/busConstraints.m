%% Function generating constraints for the requirement on maximum bus switch off

% G_[0,inf] (!b -> E_[0,k](b))

function [busCons, STLparseTrees] = busConstraints(EPSmodel, B, k)
    busCons       = [];
    STLparseTrees = [];
    
    b    = binvar(EPSmodel.noBus, EPSmodel.trajLength, 'full');
    notb = binvar(EPSmodel.noBus, EPSmodel.trajLength, 'full');
    
    for i = 1 : EPSmodel.noBus
        STLnodes = [];
        
        % 'phi' node for !b
        phinbNode             = STLnode('phi', 0);
        phinbNode.STLinterval = [0 0];
        phinbNode.childNodes  = -1;
            
        consBreakUp = [];
        
        for j = 1 : EPSmodel.trajLength
            init = length(busCons);
            busCons = [busCons notb(i,j) == not(B(i,j))];
            consBreakUp = [consBreakUp setsCons(j, length(busCons) - init)];
        end
        
        phinbNode.consBreakUp = consBreakUp;
        
        % 'not' node
        notNode             = STLnode('not', 1);
        notNode.STLinterval = [0 0];
        notNode.childNodes  = 0;
        
        consBreakUp = [];
        
        n = binvar(1, EPSmodel.trajLength, 'full');
        
        for j = 1 : EPSmodel.trajLength
            init = length(busCons);
            busCons = [busCons n(j) == not(notb(i,j))];
            consBreakUp = [consBreakUp setsCons(j, length(busCons) - init)];
        end
        
        notNode.consBreakUp = consBreakUp;
        
        % 'phi' node for b
        phiNode             = STLnode('phi', 2);
        phiNode.STLinterval = [0 0];
        phiNode.childNodes  = -1;
        
        consBreakUp = [];
        for j = 1 : EPSmodel.trajLength
            init = length(busCons);
            busCons = [busCons b(i,j) == B(i,j)];
            consBreakUp = [consBreakUp setsCons(j, length(busCons)-init)];
        end
        
        phiNode.consBreakUp = consBreakUp;
        
        % 'eventually' node
        evenNode             = STLnode('eventually', 3);
        evenNode.STLinterval = [1, k+1];
        evenNode.childNodes  = 2;
        
        e = binvar(1, EPSmodel.trajLength, 'full');
        
        consBreakUp = [];
        for j = 1 : EPSmodel.trajLength
            timePoints  = [j : min(j+k, EPSmodel.trajLength)];
            init        = length(busCons);
            busCons     = [busCons e(j) == or(b(i, timePoints))];
            consBreakUp = [consBreakUp setsCons(j, length(busCons) - init)];
        end
        evenNode.consBreakUp = consBreakUp;
        
        % 'or' node
        orNode             = STLnode('or', 4);
        orNode.STLinterval = [0 0];
        orNode.childNodes  = [1, 3];
        
        o = binvar(1, EPSmodel.trajLength, 'full');
        
        consBreakUp = [];
        
        for j = 1 : EPSmodel.trajLength
            init        = length(busCons);
            busCons     = [busCons o(j) == or(n(j), e(j))];
            consBreakUp = [consBreakUp setsCons(j, length(busCons) - init)];
        end
        
        orNode.consBreakUp = consBreakUp;
        
        % 'G' node
        alwNode             = STLnode('always', 5);
        alwNode.STLinterval = [1 EPSmodel.trajLength];
        alwNode.childNodes  = 4;
        
        consBreakUp = [];
        
        for j = 1 : EPSmodel.trajLength
            init        = length(busCons);
            busCons     = [busCons and(o(1, j:end)) == 1];
            consBreakUp = [consBreakUp setsCons(j, length(busCons) - init)];
        end
        
        alwNode.consBreakUp = consBreakUp;
        
        STLnodes = [STLnodes phinbNode notNode phiNode evenNode orNode alwNode];
        
        STLparseTrees = [STLparseTrees parseTree(STLnodes)];
    end
end