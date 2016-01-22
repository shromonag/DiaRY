%% This function defines the object for an EPS(Electric Power System)

classdef EPSmodelObject
    properties
        % EPS component requirments
        % Maximum delay for contactors
        contactorDelay
        % Maximum switch off time for the bus
        busDelay
        % Maximum delay between the generator to the contactor
        genToconDelay
        
        % Number of components
        % Number of generators
        noGen
        % Number of buses
        noBus
        % Number of contactors
        noCon
        
        % Component values
        % Controller values of generator, buses and contactors
        GenCont
        BusCont
        ConCont
        CintCont
        
        % Adversary values of generator, buses and contactor
        GenAdv
        BusAdv
        ConAdv
        CintAdv
        adversaryConstraints
        k
        G
        Cint
        C
        B
			
		% k and b values
		kAdv 
		kCont
		bAdv
		bCont
        
        % Model related values
        % Trajectory Length
        trajLength
        % Sampling Time
        samplingTime
    end
    methods
        function model = EPSmodelObject(varargin)
            model.trajLength        = varargin{1};
            model.samplingTime      = varargin{2};
            model.contactorDelay    = varargin{3};
            model.genToconDelay     = varargin{4};
            model.busDelay          = varargin{5};
            model.noGen             = varargin{6};
            model.noBus             = varargin{7};
            model.noCon             = varargin{8};
        end
    end
end
        
        
        