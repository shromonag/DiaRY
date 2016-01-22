%% Function generating constraints for the requirement on generators

% G_[0, inf] ((g1) || ... || (g_n))

function [genConstrs, STLparseTree] = generatorConstraints(EPSmodel, G)
    genConstrs = [];
    STLnodes   = [];
    
    % 'phi' nodes
    g = binvar(EPSmodel.noGen, EPSmodel.trajLength, 'full');
    for i = 1 : EPSmodel.noGen
        phiNode             = STLnode('phi', i - 1);
        phiNode.childNodes  = -1;
        phiNode.STLinterval = [0 0];
        
        consBreakUp = [];

        for j = 1 : EPSmodel.trajLength
            init        = length(genConstrs);
            genConstrs  = [genConstrs, g(i,j) == G(i,j)];
            consBreakUp = [consBreakUp setsCons(j, length(genConstrs) - init)];
        end
        
        phiNode.consBreakUp = consBreakUp;
        STLnodes            = [STLnodes phiNode];
    end
    
    % 'or' node
    o                  = binvar(1, EPSmodel.trajLength, 'full');
    orNode             = STLnode('or', length(STLnodes));
    orNode.childNodes  = [0 : length(STLnodes) - 1];
    orNode.STLinterval = [0 0];
    
    consBreakUp = [];
    
    for i = 1 : EPSmodel.trajLength
        init        = length(genConstrs);
        genConstrs  = [genConstrs, o(i) == or(g(:,i))];
        consBreakUp = [consBreakUp setsCons(i, length(genConstrs) - init)];
    end
    
    orNode.consBreakUp = consBreakUp;
    STLnodes           = [STLnodes orNode];
        
    % 'G' node
    alwNode             = STLnode('always', length(STLnodes));
    alwNode.childNodes  = length(STLnodes) - 1;
    alwNode.STLinterval = [1 EPSmodel.trajLength];
    
    consBreakUp = [];
    
    init        = length(genConstrs);
    genConstrs  = [genConstrs, and(o(alwNode.STLinterval(1) : alwNode.STLinterval(2))) == 1];
    consBreakUp = [consBreakUp setsCons(1, length(genConstrs) - init)];
    
    alwNode.consBreakUp = consBreakUp;
    STLnodes            = [STLnodes alwNode];
    
    STLparseTree = parseTree(STLnodes);
    
end
