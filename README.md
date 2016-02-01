# DiaRY: Diagnosis and Repair for sYnthesis

This MATLAB package contains the implementation of the algorithms described
in the paper "Diagnosis and Repair for Synthesis from Signal Temporal Logic", Ghosh et al, HSCC 2016. This file describes the contents of the package, and provides instruction regarding its use.

## Installation
This code was written for MATLAB R2014b. Earlier versions may be sufficient, but not tested. The code should run on any OS with MATLAB installed, although it was tested on MATLAB R2014b on Yosemite.

In addition to MATLAB R2014b, the toolbox requires the following:

1. [YALMIP](http://users.isy.liu.se/johanl/yalmip/pmwiki.php): YALMIP is a modelling language for advanced modeling and solution of convex and nonconvex optimization problems.  It is implemented as a free toolbox for MATLAB by Johan Löfberg. Certain Yalmip files were modified for our purpose. The updated files are included in our package under 'src/YalmipFiles'. Our code has been tested with Release 20150204, we suggest using the same release to reproduce our results.

2. [Gurobi Optimizer](http://www.gurobi.com/): An optimization solver for LP, QP, QCP, MIP, provided for free for academic use. 

For trying out the examples in the folder 'TestCases', you need to additionally install:

3. [BluSTL](https://github.com/vraman/BluSTL.git): BluSTL (pronounced "blue steel") is a MATLAB toolkit for automatically generating hybrid controllers from specifications written in Signal Temporal Logic.

## Running the TestCases
The matlab root folder should be set to the '/src'. The path to 'BluSTL/src' must be added to the MATLAB environment. 

Run addpaths.m in the root directory to include the necessary paths for the files required for running the examples.

To run the examples in ‘TestCases’, we provide README.txt with details of the files and the results expected under the directory ‘TestCases’.

We use external synthesis tools for running our examples. We have used BluSTL for running examples 1,2, and 3. The Aircraft Electric Power System has been created by us an example and can be found under ‘Examples/EPSexample’.