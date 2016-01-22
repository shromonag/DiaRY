%% Diagnonsis and Repair Object

classdef DiagRepairObject
	properties
		% STL parse Trees
		STLparseTrees
		% Path to controller
		pathToController
		% Are the predicates binary
		isBin
		% Take input from user
		isAuto
		% Automatic Info
		autoInfo
	end
	methods
		function DRobject = DiagRepairObject(STLparseTrees, pathToController, isBin, isAuto, autoInfo)
			DRobject.STLparseTrees = STLparseTrees;
			DRobject.pathToController = pathToController;
			DRobject.isBin = isBin;
			DRobject.isAuto = isAuto;
			DRobject.autoInfo = autoInfo;
		end
	end
end