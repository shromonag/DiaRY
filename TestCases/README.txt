This directory includes the testcases.

—————————————————————————————————————
Subdirectory Example1CollisionAvoidance
—————————————————————————————————————

- CollisionAvoidanceInfeasible.m: Defines the system dynamics and requirements. 

Run > CollisionAvoidanceInfeasible
 
Output: 
—————————————————————————————————————————————————————————————————————
Predicate Changes for STL 1 
Slack for Predicate node 1 (X(1,t) > -0.5): -0.260000
Slack for Predicate node 2 (X(1,t) < 0.5): 0.000000
Slack for Predicate node 3 (X(3,t) > -0.5): 0.000000
Slack for Predicate node 4 (X(3,t) < 0.5): -0.070000
—————————————————————————————————————————————————————————————————————
Interval Changes for STL 1 
Interval change for Always node 9 = [0.000000, 0.800000]
—————————————————————————————————————————————————————————————————————

Meaning that the system is found infeasible at time t=1. The tool returns a slack of -0.26 to fix predicate 1. Internally, as we used Yalmip, the predicate is re-written as -X(1,t) + slack < 0.5, and thus repairs the predicate as (x1(t) > -0.24). Similarly, predicate 4 must be repaired as (x3(t) < 0.43). Alternately, it shows the system is feasible if the outermost globally’s interval can be updated to [0, 0.8] instead of [0, inf). The results can also be seen in the command window of MATLAB after the script terminates. 

- CollisionAvoidanceCorrected.m: Introduces the suggested repair and synthesizes the controller. 

Output: 
The script outputs a graph showing the values of the control variable(u1), environment variable(w1) and the state variables(x1, x2, x3, x4) over time, showing that a controller was synthesized for the updated STL.
Since the values returned maybe in floating point, the predicate is repaired by a tolerance = 1e-3
Updated STL: G_[0,inf] (not( (x1(t) > -0.245) and (x1(t) < 0.5) and (x3(t) > -0.5) and (x3(t) < 0.425)))



——————————————————————————————————————————
Subdirectory Example2NonAdversarialRaceEnv
——————————————————————————————————————————

This subdirectory demonstrates the repair procedure on a contract with non-adversarial environment in which the assumptions are prioritized 

- ChangeEnvInfeasible.m: Defines the system dynamics and requirements. The controller is infeasible and a correction is proposed on a predicate in the assumptions. 

Output: 
—————————————————————————————————————————————————————————————————————
Predicate Changes for STL 1 
Slack for Predicate node 1 (X(4,t) > 0.5): -0.060000
Slack for Predicate node 2 (X(2,t) > 0.5): 0.000000
—————————————————————————————————————————————————————————————————————
No intervals changes possible
—————————————————————————————————————————————————————————————————————
Since here we prioritize updating the environment assumption, the repair procedure returns that predicate 1 must be repaired as (x4(t) > 0.56). However, in this case the repair finds that no change in the interval of the globally operator can cause the the system to become feasible. The results can also be seen in the command window of MATLAB after the script terminates. 

- ChangeEnvCorrected.m: Introduces the suggested repair and synthesizes the controller.

Output: 
The script outputs a graph showing the values of the control variable(u1), environment variable(w1) and the state variables(x1, x2, x3, x4) over time, showing that a controller was synthesized for the updated STL.
UpdatedSTL: (x4(t) > 0.56) => G_[0,inf]( (x2(t) > 0.5))

——————————————————————————————————————————
Subdirectory Example2NonAdversarialRaceCon
——————————————————————————————————————————

This subdirectory demonstrates the repair procedure on a contract with non-adversarial environment in which the guarantees are prioritized. Moreover it provides a demonstration of time interval repair

- ChangeConInfeasible.m: Defines the system dynamics and requirements. The controller is infeasible and a correction is proposed on a predicate in the guarantees.

Output: 
—————————————————————————————————————————————————————————————————————
Predicate Changes for STL 1 
Slack for Predicate node 1 (X(4,t) > 0.5): 0.000000
Slack for Predicate node 2 (X(2,t) > 0.5): -0.510000
—————————————————————————————————————————————————————————————————————
Interval Changes for STL 1 
Interval change for Always node 3 = [0.600000, Inf]
—————————————————————————————————————————————————————————————————————
meaning that the proposed repair are changing predicate 2 to (x2(t) > -0.01) or updating the interval of globally to [0.6, Inf). 

- ChangeConCorrectedPred.m: Introduces the suggested predicate repair and synthesizes the controller.

Output: 
The script outputs a graph showing the values of the control variable(u1), environment variable(w1) and the state variables(x1, x2, x3, x4) over time, showing that a controller was synthesized for the updated STL.
UpdatedSTL: (x4(t) > 0.5) => G_[0,inf]( (x2(t) > -0.1))

- ChangeConCorrectedTiming.m: Introduces the suggested time interval repair. 

Output:
The script outputs a graph showing the values of the control variable(u1), environment variable(w1) and the state variables(x1, x2, x3, x4) over time, showing that a controller was synthesized for the updated STL.
UpdatedSTL: (x4(t) > 0.5) => G_[0.61,inf]( (x2(t) > 0.5))

——————————————————————————————————————————
Subdirectory Example3AdversarialRace
——————————————————————————————————————————

This subdirectory demonstrates the repair procedure on a contract with adversarial environment.

- AdversarialRaceInfeasible.m: Defines the system dynamics and requirements.

Output:
Update all the adversarial control variable limits to : 
w(1) = [0.000000, 1.240000]
meaning that the suggested repair is to change the limits of the environment variable w1 to [0,1.24]
 
- AdversarialRaceCorrected.m: Introduces the suggested repair on the bounds on the environment and finds the controller.

Output:
The script outputs a graph showing the values of the control variable(u1), environment variable(w1) and the state variables(x1, x2, x3, x4) over time, showing that a controller was synthesized for the updated STL.
Updated w1 range: [0, 1.24]

——————————————————————————————————————————
Subdirectory CaseStudyEPS
——————————————————————————————————————————
This directory contains a script, CaseStudyEPS.m which calls EPScontroller.m in '/Examples/EPSexample/‘, describing the system dynamics and requirements. 
The output: 
Feedback : 
1. Change k limits to [0.000000 ms, 40.000000 ms]
2. Change b to 160.000000 ms

and the suggested repair is to either change the limits on contactor delay ‘k’ or update the bus delay ‘b’.
The script also outputs the counter strategy generated by the adversary.  



 
  



