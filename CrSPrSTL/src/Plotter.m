classdef Plotter < handle
    % Class: Plotter: 
    % properties: s, fig, past-ts, future_ts
    % methods: add_signal:     add a signal to be plotted
    %          capture_past:   plotting past values
    %          capture_future: plotting future values
    %          create_figure:  create a figure to plot all signals
    %          show:           plotting
    
    properties
        s
        fig
        past_ts
        future_ts
    end
    
    methods
        function self = Plotter()
            self.s = {};
            self.past_ts = [];
            self.future_ts = [];
        end
        
        function add_signal(self, name, signal)
            sig = struct;
            sig.name = name;
            sig.length = length(signal.generator());
            sig.signal = signal;
            sig.past_values = [];
            sig.future_values = [];
            self.s{end+1} = sig;
            self.fig = [];
        end
        
        function capture_past(self, ts)
            if nargin>=2
                for i = 1:length(self.s)
                    self.s{i}.past_values = [self.s{i}.past_values value(self.s{i}.signal(ts))];
                end
                self.past_ts = [self.past_ts ts];
            end
            self.show();
        end
        
        function capture_future(self, ts)
            if nargin>=2
                for i = 1:length(self.s)
                    self.s{i}.future_values = value(self.s{i}.signal(ts));
                end
                self.future_ts = ts;
            end
            self.show();
        end
        
        function create_figure(self)
            past_style = {'LineWidth', 2};
            future_style = {'--g'};
            axis_style = {'Fontsize', 12};
            self.fig = figure;
            xlabel('time');
            num_plots = 0;
            cur_plot = 1;
            for i = 1:length(self.s)
                num_plots = num_plots + self.s{i}.length;
            end
            for i = 1:length(self.s)
                for j = 1:self.s{i}.length
                    subplot(num_plots, 1, cur_plot);
                    hold on; grid on;
                    self.s{i}.future_plot(j) = plot(0, 0, future_style{:});
                    self.s{i}.past_plot(j) = plot(0, 0, past_style{:});
                    if self.s{i}.length==1
                        ylabel([self.s{i}.name '(t)']);
                    else
                        ylabel([self.s{i}.name '(t, ' num2str(j) ')']);
                    end
                    cur_plot = cur_plot + 1;
                    set(gca, axis_style{:});
                end
            end
        end
        
        function show(self)
            if isempty(self.fig)
                self.create_figure();
            end
            for i = 1:length(self.s)
                for j = 1:self.s{i}.length
                    if isempty(self.s{i}.future_values)
                        future_values = [];
                    else
                        future_values = self.s{i}.future_values(j, :);
                    end
                    set(self.s{i}.future_plot(j), 'Xdata', self.future_ts, 'Ydata', future_values);
                    if isempty(self.s{i}.past_values)
                        past_values = [];
                    else
                        past_values = self.s{i}.past_values(j, :);
                    end
                    set(self.s{i}.past_plot(j), 'Xdata', self.past_ts, 'Ydata', past_values);
                end
            end
        end
        
    end
    
end

