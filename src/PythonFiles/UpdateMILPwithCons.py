from gurobipy import *
import numpy as np
import sys

pathToController = './InterfaceFiles/pathToController.txt'
updateCons = './InterfaceFiles/UpdateMILPwithCons.txt'

try:
    with open(pathToController) as f:
        content = f.read().splitlines()
        
    m = read(content[0])
    m.setObjective(0)
    m.update()
    m.write(content[0])
    
    list = []
    
    with open(updateCons) as f:
        listContents = f.read().splitlines()

    for c in listContents:
        k = c.split(' ')
        x = []
        for kprime in k:
            x.append(int(kprime))
        list.append(x)
        
    for l in list:
        expr = LinExpr()
        for i in m.getVars():
            if i.varName != 'Constant':
                if int(i.varName[1:]) == l[0]:
                    var = i
                    expr.add(var)
                    m.addConstr(expr, GRB.EQUAL, l[1])
    
    m.update()
    m.write(content[0])

except GurobiError:
    print('Error reported')
    
    
    
    
    
     