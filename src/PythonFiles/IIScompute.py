from gurobipy import *
import numpy as np
import sys

IISpath = './InfeasibleModels/controllerIIS.ilp'
controllerPath = './GurobiModels/updatedController.lp'

try:
    m = read(controllerPath)
    m.computeIIS()
    m.write(IISpath)
    
except GurobiError:
    print('Error reported')