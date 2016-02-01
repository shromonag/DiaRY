%% Object definition for each node of the parse tree

classdef STLnode 
    properties
        % Node number
        nodeID
        % Array of children
        childNodes
        % STL node type
        nodeType
        % Predicate string
        predStr
        % Interval if it is a temporal operator
        STLinterval
        % Support of the node
        support
        % Break up of constraints based on time
        consBreakUp
        % Slack breakup over time
        slackTime
        % Predicate repair 
        slackPred
        % Sigma, interval of zero slack
        sigma
    end
    methods
        function node = STLnode(nodeType, nodeID)
            node.nodeType = nodeType;
            node.nodeID = nodeID;
            node.sigma = [-1 -1];
            node.slackPred = 0;
            node.support = [0 0];
        end
    end
end