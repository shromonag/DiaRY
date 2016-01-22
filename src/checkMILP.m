model = gurobi_read('./GurobiModels/EPSmodel1.lp');
param.outputflag = 1;
soln = gurobi(model,param);

varNames = [];
for i = 1 : length(model.varnames)
    if model.varnames{i}(1) == 's' && model.varnames{i}(end) == 'p'
        varNames = [varNames -1];
    elseif model.varnames{i}(1) == 's' && model.varnames{i}(end) == 'n'
        varNames = [varNames -1];
    else
        varNames = [varNames str2num(model.varnames{i}(2:end))];
    end
end

Gen1Vals = [];
for i = 1 : 2 : 39
    Gen1Vals = [Gen1Vals soln.x(find(varNames == i-1))];
end

Gen2Vals = [];
for i = 2 : 2 : 40
    Gen2Vals = [Gen2Vals soln.x(find(varNames == i-1))];
end

Cint1Vals = [];
for i = 41 : 3 : 98
    Cint1Vals = [Cint1Vals soln.x(find(varNames == i-1))];
end

Cint2Vals = [];
for i = 42 : 3 : 99
    Cint2Vals = [Cint2Vals soln.x(find(varNames == i-1))];
end

Cint3Vals = [];
for i = 43 : 3 : 100
    Cint3Vals = [Cint3Vals soln.x(find(varNames == i-1))];
end

C1Vals = [];
for i = 101 : 3 : 158
    C1Vals = [C1Vals soln.x(find(varNames == i-1))];
end

C2Vals = [];
for i = 102 : 3 : 159
    C2Vals = [C2Vals soln.x(find(varNames == i-1))];
end

C3Vals = [];
for i = 103 : 3 : 160
    C3Vals = [C3Vals soln.x(find(varNames == i-1))];
end

Bus1Vals = [];
for i = 161 : 2 : 199
    Bus1Vals = [Bus1Vals soln.x(find(varNames == i-1))];
end

Bus2Vals = [];
for i = 162 : 2 : 200
    Bus2Vals = [Bus2Vals soln.x(find(varNames == i-1))];
end

k = soln.x(find(varNames == 200))