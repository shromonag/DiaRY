%% Object definition for the parse tree

classdef parseTree 
    properties
        % Array of STLnodes
        STLnodes
        % Other constraints
        addCons
        % Additional constraints in MILP
        addConsMILP
    end
    methods
        function tree = parseTree(treeNodes)
            tree.STLnodes = treeNodes;
        end
    end
end