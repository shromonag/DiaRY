classdef Signal < handle
    % class: Signal: We define a function of time using Signal
    % properties: generator, dt, map 
    % methods: subsref: used for indexing of time x(1), x(2), ...
    
    properties
        generator
        dt
        map
    end
    
    methods
        function self = Signal(dt, varargin)
            if numel(varargin)==1
                if (isnumeric(varargin{1}))
                    self.generator = @() sdpvar(varargin{1}, 1);
                else
                    self.generator = varargin{1};
                end
            else
                self.generator = @() sdpvar(varargin{:});
            end
            self.dt = dt;
            self.map = containers.Map('KeyType', 'int64', 'ValueType', 'any');
        end
        function result = subsref(self, S)
            if ~isequal(S.type, '()')
                result = builtin('subsref', self, S);
            elseif ~ischar(S.subs{1})
                inds = S.subs{1};

                further_indexing = 0;
                if numel(S.subs)>1
                    S.subs = S.subs(2:end);
                    further_indexing = 1;
                end

                result = [];
                for i = 1:numel(inds)
                    ind = round(inds(i)/self.dt);
                    if ~self.map.isKey(ind)
                        self.map(ind) = self.generator();
                    end
                    x = self.map(ind);
                    if (further_indexing)
                        x = subsref(x, S);
                    end
                    result = [result, x]; %#ok<AGROW>
                end
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
