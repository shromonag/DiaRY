%% This script defines the EPS controller problem

addpath('../Examples/EPSexample/');

% Parameter definitions
trajLength      = 20;
samplingTime    = 0.2;
contactorDelay  = 0.8;
busDelay        = 1;
genToconDelay   = 1;
noGen           = 2;
noBus           = 2;
noCon           = 3;

kMin = 0;
kMax = round(contactorDelay/samplingTime);

EPSmodel = EPSmodelObject(trajLength, samplingTime, contactorDelay, genToconDelay, busDelay, noGen, noBus, noCon);

% Declaring optimization variables for the MILP
G           = binvar(noGen, trajLength, 'full');
Cint        = binvar(noCon, trajLength, 'full');
C           = binvar(noCon, trajLength, 'full');
B           = binvar(noBus, trajLength, 'full');
k           = intvar(1);

% Parse Trees, Constraints
STLparseTrees          = [];
constraints            = [];
dynCons                = [];
updatedCons            = [];

% Collecting constraints
[genCons, genParseTree]        = generatorConstraints(EPSmodel, G);
[genconCons, genconParseTrees] = generatorcontactorConstraint(EPSmodel, G, C, round(genToconDelay/samplingTime));
[kCons, kconParseTrees]        = kConstraints(EPSmodel, k, kMin, kMax);
[parCons, parconParseTrees]    = parallelConstraints(EPSmodel, Cint, C);
[busCons, busParseTrees]       = busConstraints(EPSmodel, B, round(busDelay/samplingTime));

constraints   = [genCons genconCons kCons parCons busCons];
STLparseTrees = [genParseTree genconParseTrees kconParseTrees parconParseTrees busParseTrees];

dynCons = [dynCons contactorDynamics(EPSmodel, Cint, C, k, round(contactorDelay/samplingTime))];

for i = 1 : trajLength
    if i > 1
        for j = 1 : EPSmodel.noGen
            dynCons = [dynCons implies(not(G(j,i-1)), not(G(j,i)))];
              
            dynCons = [dynCons implies(and(G(j,i-1), Cint(j,i-1), G(j,i)), Cint(j,i))];
            dynCons = [dynCons implies(and(not(G(j,i-1)), not(Cint(j,i-1)), not(G(j,i))), not(Cint(j,i)))];
              
            dynCons = [dynCons implies(and(G(j,i-1), Cint(j,i-1), C(j,i-1), Cint(j,i), G(j,i)), C(j,i))];
            dynCons = [dynCons implies(and(not(G(j,i-1)), not(Cint(j,i-1)), not(C(j,i-1)), not(Cint(j,i)), not(G(j,i))), not(C(j,i)))];
        end
    end
    
    % Specific to this architecture
      
    % Bus powering on
    dynCons = [dynCons B(1,i) == or(and(G(1,i), C(1,i)), and(G(2,i), C(2,i), C(3,i)))];
    dynCons = [dynCons B(2,i) == or(and(G(1,i), C(1,i), C(3,i)), and(G(2,i), C(2,i)))];
      
    % Controlling the intent of contactor 3
    cint3 = binvar(1, 1, 'full');
    dynCons = [dynCons cint3 == and(or(G(1,i),Cint(1,i), C(1,i)), or(G(2,i), Cint(2,i), C(2,i)))];
    dynCons = [dynCons Cint(3,i) == not(cint3)];
      
    % Controlling the state of contactor 3
    if i > 1
       dynCons = [dynCons implies(and(C(3,i-1), Cint(3,i)), C(3,i))];
       dynCons = [dynCons implies(and(not(C(3,i-1)), not(Cint(3,i))), not(C(3,i)))];
    end
end

% To ensure one of the generator fail
dynCons = [dynCons G(2,5) == 1, G(2,10) == 0];

% Objective
objective = EPSmodel.noBus * EPSmodel.trajLength - sum(sum(B));

options = sdpsettings('solver', 'gurobi', 'verbose', 1, 'savesolveroutput', 1, 'savesolverinput', 1);
[solution, reordering, expandedConstrMapping, mapImpliesF] = optimizeWithFeedback([constraints dynCons], objective, options);

pathToController = './GurobiModels/EPSmodel.lp';
gurobi_write(solution.solverinput.model, pathToController);
fileID = fopen('./InterfaceFiles/pathToController.txt', 'w');
fprintf(fileID,'%s', char(pathToController));
fclose(fileID);

maxGenCount      = EPSmodel.trajLength * EPSmodel.noGen;
EPSmodel.GenCont = value(G);

maxCintCount      = maxGenCount + EPSmodel.trajLength * EPSmodel.noCon;
EPSmodel.CintCont = value(Cint);

maxCCount        = maxCintCount + EPSmodel.trajLength * EPSmodel.noCon;
EPSmodel.ConCont = value(C) ;

maxBusCount      = maxCCount + EPSmodel.trajLength * EPSmodel.noBus;
EPSmodel.BusCont = value(B);

EPSmodel.kCont = value(k);
EPSmodel.bCont = findLongestZeros(EPSmodel.BusCont);

[EPSmodel, status] = EPSadversary(EPSmodel, kMin, kMax, 1);
firstFail = 0;

while strcmp(status, 'fail')
    updatedPhiCons = [k == EPSmodel.kAdv];
	if firstFail == 0 
    	failingb = EPSmodel.bAdv;
		GenVals = EPSmodel.GenAdv;
		CintVals = EPSmodel.CintAdv;
		ConVals = EPSmodel.ConAdv;
		BusVals = EPSmodel.BusAdv;
		firstFail = 1;
	end
		
    for i = 1 : noGen
        updatedCons = [updatedCons G(i,:) == EPSmodel.GenAdv(i,:)];
    end

    options = sdpsettings('solver', 'gurobi', 'verbose', 1, 'savesolveroutput', 1, 'savesolverinput', 1);
    solution = optimize([constraints updatedPhiCons updatedCons dynCons], objective, options);
    if strcmp(solution.solveroutput.result.status, 'OPTIMAL') == 0
        [kMin, kMax] = pruneSpace(kMin, kMax, EPSmodel.kAdv, 1, 1);
    else
        EPSmodel.GenCont  = value(G);
        EPSmodel.CintCont = value(Cint);
        EPSmodel.ConCont  = value(C) ;
        EPSmodel.BusCont  = value(B);
        
        EPSmodel.kCont = value(k);
        EPSmodel.bCont = findLongestZeros(EPSmodel.BusCont);
    end
    [EPSmodel, status] = EPSadversary(EPSmodel, kMin, kMax, 0);
end

fprintf('Feedback : \n');
fprintf('1. Change k limits to [%f ms, %f ms]\n', kMin * samplingTime * 100, kMax * samplingTime * 100);
fprintf('2. Change b to %f ms\n', failingb * samplingTime * 100);
fprintf('Environment counter strategy: \n');
fprintf('Generator 1 state : \n');
GenVals(1,:)
fprintf('Generator 2 state : \n');
GenVals(2,:)
fprintf('Contactor intent 1 state : \n');
CintVals(1,:)
fprintf('Contactor intent 2 state : \n');
CintVals(2,:)	
fprintf('Contactor intent 3 state : \n');
CintVals(3,:)	
fprintf('Contactor 1 state : \n');
ConVals(1,:)
fprintf('Contactor 2 state : \n');
ConVals(2,:)	
fprintf('Contactor 3 state : \n');
ConVals(3,:)
fprintf('Bus 1 state : \n');
BusVals(1,:)
fprintf('Bus 2 state : \n');
BusVals(2,:)
fprintf('done ... \n');