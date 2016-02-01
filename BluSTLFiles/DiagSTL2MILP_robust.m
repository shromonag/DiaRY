function [F,P, STLparseTree] = DiagSTL2MILP_robust(phi,k,ts,var,M, nodeID)
% STL2MILP_robust  constructs MILP constraints in YALMIP that compute
%                  the robustness of satisfaction for specification phi
%
% Input: 
%       phi:    an STLformula
%       k:      the length of the trajectory
%       ts:     the interval (in seconds) used for discretizing time
%       var:    a dictionary mapping strings to variables
%       M:   	a large positive constant used for big-M constraints  
%
% Output: 
%       F:  YALMIP constraints
%       P:  a struct containing YALMIP decision variables representing 
%           the quantitative satisfaction of phi over each time step from 
%           1 to k 
%
% :copyright: TBD
% :license: TBD

    if (nargin==4);
        M = 1000;
    end;
        
    F = [];
    P = [];
    STLparseTree = [];
    
    if ischar(phi.interval)
        interval = [str2num(phi.interval)];
    else
        interval = phi.interval;
    end
    
    a = interval(1);
    b = interval(2);
    
    if a == Inf
        a = k*ts;
    end
    if b == Inf
        b = (k-1)*ts;
    end
    
    a = max([0 floor(a/ts)]); 
    b = ceil(b/ts); 
    
    switch (phi.type)
        
        case 'predicate'
            [F,P, STLparseTree] = pred(phi.st,k,var,M, nodeID);
                     
        case 'not'
            [Frest,Prest, STLparseTreerest] = DiagSTL2MILP_robust(phi.phi,k,ts, var,M, nodeID);
            nodeID = length(STLparseTreerest);
            [Fnot, Pnot, STLparseTreenot] = not(Prest, nodeID);
            STLparseTreenot(1).childNodes = [nodeID-1];
            F = [F, Frest, Fnot];
            STLparseTree = [STLparseTree, STLparseTreerest, STLparseTreenot];
            P = Pnot;

        case 'or'
            [Fdis1,Pdis1, STLparseTreedis1] = DiagSTL2MILP_robust(phi.phi1,k,ts, var,M, nodeID);
            nodeIDchild1 = STLparseTreedis1(end).nodeID;
            [Fdis2,Pdis2, STLparseTreedis2] = DiagSTL2MILP_robust(phi.phi2,k,ts, var,M, nodeIDchild1+1);
            nodeIDchild2 = STLparseTreedis2(end).nodeID;
            nodeID = nodeIDchild2+1;
            [For, Por, STLparseTreeor] = or([Pdis1;Pdis2],M, nodeID);
            STLparseTreeor(1).childNodes = [nodeIDchild1 nodeIDchild2];
            F = [F, Fdis1, Fdis2, For];
            STLparseTree = [STLparseTree, STLparseTreedis1, STLparseTreedis2, STLparseTreeor];
            P = Por;

        case 'and'
            [Fcon1,Pcon1, STLparseTreecon1] = DiagSTL2MILP_robust(phi.phi1,k,ts, var,M, nodeID);
            nodeIDchild1 = STLparseTreecon1(end).nodeID;
            [Fcon2,Pcon2, STLparseTreecon2] = DiagSTL2MILP_robust(phi.phi2,k,ts, var,M, nodeIDchild1+1);
            nodeIDchild2 = STLparseTreecon2(end).nodeID;
            nodeID = nodeIDchild2+1;
            [Fand, Pand, STLparseTreeand] = and([Pcon1;Pcon2],M, nodeID);
            STLparseTreeand(1).childNodes = [nodeIDchild1 nodeIDchild2];
            F = [F, Fcon1, Fcon2, Fand];
            STLparseTree = [STLparseTree, STLparseTreecon1, STLparseTreecon2, STLparseTreeand];
            P = Pand;

        case '=>'
            [Fant,Pant, STLparseTreeant] = DiagSTL2MILP_robust(phi.phi1,k, ts,var,M, nodeID);
            nodeIDchildant = STLparseTreeant(end).nodeID;
            [Fcons,Pcons, STLparseTreecons] = DiagSTL2MILP_robust(phi.phi2,k,ts, var,M, nodeIDchildant+1);
            nodeIDchildcons = STLparseTreecons(end).nodeID;
            [Fnotant,Pnotant, STLparseTreenotant] = not(Pant, nodeIDchildcons+1);
            STLparseTreenotant(1).childNodes = [nodeIDchildant];
            nodeIDchildnotant = STLparseTreenotant(end).nodeID;
            [Fimp, Pimp, STLparseTreeimp] = or([Pnotant;Pcons],M, nodeIDchildnotant+1);
            STLparseTreeimp(1).childNodes = [nodeIDchildnotant nodeIDchildcons];
            F = [F, Fant, Fcons, Fnotant, Fimp];
            STLparseTree = [STLparseTree STLparseTreeant STLparseTreecons STLparseTreenotant STLparseTreeimp];
            P = [Pimp,P];
            
        case 'always'
            [Frest,Prest, STLparseTreerest] = DiagSTL2MILP_robust(phi.phi,k, ts, var,M, nodeID);
            nodeID = STLparseTreerest(end).nodeID;
            [Falw, Palw, STLparseTreealw] = always(Prest,a,b,k,M, nodeID+1);
            STLparseTreealw(1).childNodes = [nodeID];
            STLparseTreealw(1).STLinterval = [a+1 b+1];
            F = [F, Frest, Falw];
            STLparseTree = [STLparseTree STLparseTreerest STLparseTreealw];
            P = [Palw, P];

        case 'eventually'
            [Frest,Prest, STLparseTreerest] = DiagSTL2MILP_robust(phi.phi,k, ts, var,M, nodeID);
            nodeID = STLparseTreerest(end).nodeID;
            [Fev, Pev, STLparseTreeev] = eventually(Prest,a,b,k,M, nodeID+1);
            STLparseTreeev(1).childNodes = [nodeID];
            STLparseTreeev(1).STLinterval = [a+1 b+1];
            F = [F, Frest, Fev];
            STLparseTree = [STLparseTree STLparseTreerest STLparseTreeev];
            P = [Pev, P];
          
        case 'until'
            [Fp,Pp, STLparseTreep] = DiagSTL2MILP_robust(phi.phi1,k, ts, var,M, nodeID);
            nodeIDp = STLparseTreep(end).nodeID;
            [Fq,Pq, STLparseTreeq] = DiagSTL2MILP_robust(phi.phi2,k, ts, var,M, nodeIDp+1);
            nodeIDq = STLparseTreeq(end).nodeID;
            [Funtil, Puntil, STLparseTreeuntil] = until(Pp,Pq,a,b,k,M, nodeIDq+1);
            STLparseTreeuntil(1).childNodes = [nodeIDp nodeIDq];
            STLparseTreeuntil(1).STLinterval = [a+1 b+1];
            F = [F, Fp, Fq, Funtil];
            STLparseTree = [STLparseTree STLparseTreep STLparseTreeq STLparseTreeuntil];
            P = Puntil;
    end
end

function [F,z, predNode] = pred(st,k,var,M, nodeID)
    % Enforce constraints based on predicates 
    % 
    % var is the variable dictionary    
        
    fnames = fieldnames(var);
    predNode = STLnode('phi', nodeID);
    predNode.predStr = st;
    constrSet = [];
    for ifield= 1:numel(fnames)
        eval([ fnames{ifield} '= var.' fnames{ifield} ';']); 
    end          
        
    st = regexprep(st,'\[t\]','\(t\)'); % Breach compatibility ?
    if strfind( st, '<')
        tokens = regexp(st, '(.+)\s*<\s*(.+)','tokens');
        st = ['-(' tokens{1}{1} '- (' tokens{1}{2} '))']; 
    end
    if strfind(st, '>')
        tokens = regexp(st, '(.+)\s*>\s*(.+)','tokens');
        st= [ '(' tokens{1}{1} ')-(' tokens{1}{2} ')' ];
    end
         
    F = [];
    
    zAll = [];
    for l=1:k
        t_st = st;
        t_st = regexprep(t_st,'t\)',[num2str(l) '\)']);
        %zl = sdpvar(size(eval(t_st),1),size(eval(t_st),2)); % is that
        % necessary ??
        try 
            zl = eval(t_st);
        end
        zAll = [zAll,zl];
    end
    
    % take the and over all dimension for multi-dimensional signals
    z = sdpvar(1,k);
    for i=1:k
        [Fnew, z(:,i)] = and(zAll(:,i),M, 0);
        F = [F, Fnew];
        constrSet = [constrSet setsCons(i, length(Fnew))];
    end
    predNode.consBreakUp = constrSet; 
    predNode.STLinterval = [0 0];
    predNode.childNodes = [-1];
    STLparseTree = [predNode];
end

% BOOLEAN OPERATIONS

function [F,P, STLparseTree] = and(p_list,M, nodeID)
    andNode = STLnode('and', nodeID);
    [F,P, constrSet] = min_r(p_list,M);
    andNode.consBreakUp = constrSet;
    andNode.STLinterval = [0 0];
    STLparseTree = [andNode];
end


function [F,P, STLparseTree] = or(p_list,M, nodeID)
     orNode = STLnode('or', nodeID);
     [F,P, constrSet] = max_r(p_list,M);
     orNode.consBreakUp = constrSet;
     orNode.STLinterval = [0 0];
     STLparseTree = [orNode];
end


function [F,P, STLparseTree] = not(p_list, nodeID)
    k = size(p_list,2);
    m = size(p_list,1);
    P = sdpvar(1,k);
    F = [P(:) == -p_list(:)];
    notNode = STLnode('not', nodeID);
    notNode.consBreakUp = [setsCons(0, length(F))];
    notNode.STLinterval = [0 0];
    STLparseTree = [notNode];
end


% TEMPORAL OPERATIONS

function [F,P_alw, STLparseTree] = always(P, a,b, k,M, nodeID)
    F = [];
    P_alw = sdpvar(1,k);
    alwNode = STLnode('always', nodeID);
    constrSet = [];
    for i = 1:k
        [ia, ib] = getIndices(i,a,b,k);
        [F0,P0] = and(P(ia:ib)',M, 0);
        initLength = length(F);
        F = [F;F0,P_alw(i)==P0];
        finalLength = length(F);
        constrSet = [constrSet setsCons(i,finalLength - initLength)];
    end
    alwNode.consBreakUp = constrSet;
    alwNode.STLinterval = [a b];
    STLparseTree = [alwNode];
    
end


function [F,P_ev, STLparseTree] = eventually(P, a,b, k,M, nodeID)
    F = [];
    P_ev = sdpvar(1,k);
    evNode = STLnode('eventually', nodeID);
    constrSet = [];
    for i = 1:k
        [ia, ib] = getIndices(i,a,b,k);
        initLength = length(F);
        [F0,P0] = or(P(ia:ib)',M, 0);
        finalLength = length(F);
        F = [F;F0,P_ev(i)==P0];
        constrSet = [constrSet setsCons(i, finalLength-initLength)];
    end
    evNode.consBreakUp = constrSet;
    evNode.STLinterval = [a b];
    STLparseTree = [evNode];
    
end


function [F,P_until, STLparseTree] = until(Pp,Pq,a,b,k,M, nodeID)
    
    F = [];
    P_until = sdpvar(1,k);
    untilNode = STLnode('until', nodeID);
    constrSet = [];
    for i = 1:k
        [ia, ib] = getIndices(i,a,b,k);
        F0 = []; 
        P0 = [];
        for j = ia:ib
            [F1,P1] = until_mins(i,j,Pp,Pq,M);
            F0 = [F0, F1];
            P0 = [P0, P1];
        end
        [F4,P4] = max_r(P0);
        initLength = length(F);
        F = [F;F0,F4,P_until(i)==P4];
        finalLength = length(F);
        constrSet = [constrSet setsCons(i,finalLength-initLength)];
    end
    untilNode.consBreakUp = constrSet;
    untilNode.STLinterval = [a b];
    STLparseTree = [untilNode];
    
end


% UTILITY FUNCTIONS

function [F,P, constrSet] = min_r(p_list,M)
    
    k = size(p_list,2);
    m = size(p_list,1);
    
    constrSet = [];
    P = sdpvar(1,k);
    z = binvar(m,k);
     
    F = [sum(z,1) == ones(1,k)];
    constrSet = [constrSet setsCons(0, length(F))];
    for t=1:k
        initLength = length(F);
        for i=1:m
            F = [F, P(1,t) <= p_list(i,t)];     
            F = [F, p_list(i,t) - (1-z(i,t))*M <= P(t) <= p_list(i,t) + (1-z(i,t))*M];
        end
        finalLength = length(F);
        constrSet = [constrSet setsCons(t, finalLength - initLength)];
    end
    if k == 1
        constrSet = [setsCons(0, length(F))];
    end
end

function [F,P, constrSet] = max_r(p_list,M)

    k = size(p_list,2);
    m = size(p_list,1);
    constrSet = [];
    
    P = sdpvar(1,k);
    z = binvar(m,k);
    
    F = [sum(z,1) == ones(1,k)];
    constrSet = [constrSet setsCons(0, length(F))];
    for t=1:k
        for i=1:m
            initLength = length(F);
            F = [F, P(1,t) >= p_list(i,t)];     
            F = [F, p_list(i,t) - (1-z(i,t))*M <= P(t) <= p_list(i,t) + (1-z(i,t))*M];
            finalLength = length(F);
        end
        constrSet = [constrSet setsCons(t, finalLength - initLength)];
    end
    if k == 1
        constrSet = [0; length(F)];
    end
end

function [F,P] = until_mins(i,j,Pp,Pq,M)
    [F0,P0] = min_r(Pp(i:j)',M);
    [F1,P] = min_r([Pq(j),P0],M);
    F = [F0,F1];
end

function [ia, ib] = getIndices(i,a,b,k)
    ia = min(k,i+a);
    ib = min(k,i+b);
end


    
