%% This function implements the adversary problem

function [EPSmodel, status] = EPSadversary(EPSmodel, kMin, kMax, createProb)
    if createProb == 1
        % Declaring optimization variables for the MILP
        G           = binvar(EPSmodel.noGen, EPSmodel.trajLength, 'full');
        Cint        = binvar(EPSmodel.noCon, EPSmodel.trajLength, 'full');
        C           = binvar(EPSmodel.noCon, EPSmodel.trajLength, 'full');
        B           = binvar(EPSmodel.noBus, EPSmodel.trajLength, 'full');
        k           = intvar(1);
    
        % Constraints
        constraints = [];
    
        % Collecting constraints
        [genCons, genParseTree]        = generatorConstraints(EPSmodel, G);
        [genconCons, genconParseTrees] = generatorcontactorConstraint(EPSmodel, G, C, round(EPSmodel.genToconDelay/EPSmodel.samplingTime));
        [kCons, kconParseTrees]        = kConstraints(EPSmodel, k, kMin, kMax);
        [parCons, parconParseTrees]    = parallelConstraints(EPSmodel, Cint, C);

        constraints   = [genCons genconCons kCons parCons];
        STLparseTrees = [genParseTree genconParseTrees kconParseTrees parconParseTrees];

        constraints = [constraints contactorDynamics(EPSmodel, Cint, C, k, round(EPSmodel.contactorDelay/EPSmodel.samplingTime))];

        for i = 1 : EPSmodel.trajLength
            if i > 1
                for j = 1 : EPSmodel.noGen
                    constraints = [constraints implies(not(G(j,i-1)), not(G(j,i)))];
              
                    constraints = [constraints implies(and(G(j,i-1), Cint(j,i-1), G(j,i)), Cint(j,i))];
                    constraints = [constraints implies(and(not(G(j,i-1)), not(Cint(j,i-1)), not(G(j,i))), not(Cint(j,i)))];
              
                    constraints = [constraints implies(and(G(j,i-1), Cint(j,i-1), C(j,i-1), Cint(j,i), G(j,i)), C(j,i))];
                    constraints = [constraints implies(and(not(G(j,i-1)), not(Cint(j,i-1)), not(C(j,i-1)), not(Cint(j,i)), not(G(j,i))), not(C(j,i)))];
                end
            end
    
            % Specific to this architecture
      
            % Bus powering on
            constraints = [constraints B(1,i) == or(and(G(1,i), C(1,i)), and(G(2,i), C(2,i), C(3,i)))];
            constraints = [constraints B(2,i) == or(and(G(1,i), C(1,i), C(3,i)), and(G(2,i), C(2,i)))];
     
            % Controlling the intent of contactor 3
            cint3 = binvar(1, 1, 'full');
            constraints = [constraints cint3 == and(or(G(1,i),Cint(1,i), C(1,i)), or(G(2,i), Cint(2,i), C(2,i)))];
            constraints = [constraints Cint(3,i) == not(cint3)];
     
            % Controlling the state of contactor 3
            if i > 1
               constraints = [constraints implies(and(C(3,i-1), Cint(3,i)), C(3,i))];
               constraints = [constraints implies(and(not(C(3,i-1)), not(Cint(3,i))), not(C(3,i)))];
            end
        end
    EPSmodel.adversaryConstraints = constraints;
    EPSmodel.k = k;
    EPSmodel.Cint = Cint;
    EPSmodel.C = C;
    EPSmodel.B = B;
    EPSmodel.G = G;
    end
    
    % Setting the generator, and cint values
    k    = EPSmodel.k;
    Cint = EPSmodel.Cint;
    C    = EPSmodel.C;
    B    = EPSmodel.B;
    G    = EPSmodel.G;
    constraints = EPSmodel.adversaryConstraints;
    constraints = [constraints kMin <= k <= kMax];
    constraints = [constraints G == EPSmodel.GenCont];
    constraints = [constraints Cint(1:2,:) == EPSmodel.CintCont(1:2,:)];
    % Objective
    objective = sum(sum(B)) - EPSmodel.noBus * EPSmodel.trajLength;

    options = sdpsettings('solver', 'gurobi', 'verbose', 1, 'savesolveroutput', 1, 'savesolverinput', 1);
    solution = optimize(constraints, objective, options);
    
    EPSmodel.GenAdv  = value(G);
    EPSmodel.CintAdv = value(Cint);
    EPSmodel.ConAdv  = value(C) ;
    EPSmodel.BusAdv  = value(B);
    
    EPSmodel.kAdv = value(k);
    EPSmodel.bAdv = findLongestZeros(EPSmodel.BusAdv);
    
    if EPSmodel.bAdv > round(EPSmodel.busDelay/EPSmodel.samplingTime) - 1
        status = 'fail';
    else
        status = 'success';
    end
end