classdef Pr
    % Class: Pr: when having Pr(x>4) >= 0.9, the class extracts f: x>4 and
    % threshold thr:0.9
    % methods: greater than, greater than equal to: operator overloading
    
    properties
        f
    end
    
    methods
        function self = Pr(f)
            self.f = f;
        end
        function result = ge(self, thr)
            result = ProbabilisticPredicate(self.f, thr);
        end
        function result = gt(self, thr)
            result = ge(self, thr);
        end
    end
end

