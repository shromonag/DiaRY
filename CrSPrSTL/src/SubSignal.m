classdef SubSignal < handle

    properties
        signal
        ind
    end
    
    methods
        function self = SubSignal(signal, ind)
            self.signal = signal;
            self.ind = ind;
        end
        function result = subsref(self, S)
            if ~isequal(S.type, '()')
                result = builtin('subsref', self, S);
            elseif ~ischar(S.subs{1})
                inds = self.ind;
                inds.subs{1} = S.subs{1};
                for i=2:numel(S.subs)
                    x = inds.subs{i};
                    inds.subs{i} = x(S.subs{i});
                end
                result = subsref(self.signal, inds);
            else
                if numel(S.subs)==1
                    result = self;
                else
                    result = SubSignal(self, S);
                end
            end
        end
    end
    
end

