#Diagnosis and Repair for sYnthesis

Shromona Ghosh 2016
##1. Introduction
This MATLAB package contains the implementation of the algorithms described
in the paper "Diagnosis and Repair for Synthesis from Signal Temporal Logic", Ghosh et al, HSCC 2016. This file describes the contents
of the package, and provides instruction regarding its use.

##2. Installation
This code was written for MATLAB R2014b. Earlier versions may be sufficient, but not tested.
In addition to MATLAB R2014b, the toolbox requires the following:
###[Yalmip](http://users.isy.liu.se/johanl/yalmip/pmwiki.php)
YALMIP is a modelling language for advanced modeling and solution of convex and nonconvex optimization problems. 
It is implemented as a free toolbox for MATLAB by Johan Löfberg.

Certain Yalmip files were modified for our purpose. The updated files are included in our package under 'src/YalmipFiles'.
Our code has been tested with Release 20150204.

###[Gurobi Optimizer](http://www.gurobi.com/)
An optimization solver for LP, QP, QCP, MIP, provided for free for academic use.

For trying out the examples in the folder 'HSCC2016', you need to additionally install:
###[BluSTL](https://github.com/vraman/BluSTL.git)
BluSTL (pronounced "blue steel") is a MATLAB toolkit for automatically generating hybrid controllers from specifications written in Signal Temporal Logic.

###[CrPrSTL](https://github.com/dsadigh/CrSPrSTL.git)
CrPrSTL is a Matlab toolbox for Synthesizing safe controllers under Probabilistic Signal Temporal Logic Specificaitons.

##3. Running experiments described in the paper
Add the 'src' folders of BluSTL and CrPrSTL to the matlab path
##4. Directory overview
##5. License

