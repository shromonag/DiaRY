from gurobipy import *
import numpy as np
import sys

updatedControllerPath = './GurobiModels/updatedController.lp'
changingConts = './InterfaceFiles/ChangingConts.txt'

try:
    m = read(updatedControllerPath)
    
    list = []
    
    with open(changingConts) as f:
        content = f.read().splitlines()

    for c in content:
        k = c.split(' ')
        x = []
        for kprime in k:
            x.append(int(kprime))
        list.append(x)
        
    constrs = m.getConstrs()

    vars = []
    for l in list:
        if l[1] == 1:
            posVar = 's'+str(l[0])+'p'
            negVar = 's'+str(l[0])+'n'
            consPos = Column(1.0, constrs[l[0]])
            consNeg = Column(-1.0, constrs[l[0]])
            if l[2] != 0: 
                vars.append([m.addVar(lb= 0.0, ub = GRB.INFINITY, vtype = GRB.CONTINUOUS, name = posVar, column = consPos), 1.0/l[2]])
                vars.append([m.addVar(lb= 0.0, ub = GRB.INFINITY, vtype = GRB.CONTINUOUS, name = negVar, column = consNeg), 1.0/l[2]])
            
        if l[1] == 2 :
            negVar = 's'+str(l[0])+'n'
            consNeg = Column(-1.0, constrs[l[0]])
            if l[2] != 0:
                vars.append([m.addVar(lb= 0.0, ub = GRB.INFINITY, vtype = GRB.CONTINUOUS, name = negVar, column = consNeg), 1.0/l[2]])
            
        m.update()
        m.setObjective(quicksum(v[0]*v[1] for v in vars))
        m.update()
        m.write(updatedControllerPath)
        
except GurobiError:
    print('Error reported')