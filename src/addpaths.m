%% Adding all the required files

% Add the files necessary to run the tool
addpath('./YalmipFiles/');

% Add the files necessary for running test cases in HSCC2016
addpath(genpath('../BluSTLFiles/'));
addpath(genpath('../CrPrSTLFiles/'));
addpath(genpath('../CrSPrSTL/'));
addpath(genpath('../HSCC2016/'));

mkdir('GurobiModels');
mkdir('InfeasibleModels');
mkdir('InterfaceFiles');