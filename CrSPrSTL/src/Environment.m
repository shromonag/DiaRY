classdef Environment < handle
    %ENVIRONMENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        names
        systems
        movie
    end
    
    methods
        function self = Environment(system)
            if nargin>=1
                self.names = {''};
                self.systems = system;
            else
                self.names = {};
                self.systems = [];
            end
        end
        
        function dt = get_dt(self)
            dt = self.systems(1).dt;
        end
        
        function add_system(self, system, name)
            self.systems = [self.systems system];
            if nargin>=3
                self.names{end+1} = name;
            else
                self.names{end+1} = '';
            end
        end
        
        function plotter = get_plotter(self)
            function result = merge_name(signal, name)
                if isempty(name)
                    result = signal;
                else
                    result = [name ' ' signal];
                end
            end
            plotter = Plotter();
            for i = 1:numel(self.systems)
                plotter.add_signal(merge_name('x', self.names{i}), self.systems(i).x);
                plotter.add_signal(merge_name('u', self.names{i}), self.systems(i).u);
                plotter.add_signal(merge_name('y', self.names{i}), self.systems(i).y);
            end
        end
        
        function run_open_loop(self, t1, t2)
            dt = self.get_dt();
            for i = 1:numel(self.systems)
                self.systems(i).run_open_loop(t1, t2);
            end
            plotter = self.get_plotter();
            plotter.capture_future(t1:dt:t2);
        end
        
        function save_movie(self, filename, rate)
            video = VideoWriter(filename, 'Uncompressed AVI');
            video.FrameRate = rate;
            open(video);
            writeVideo(video, self.movie);
            close(video);
        end
        
        function run_closed_loop(self, L, t1, t2)
            dt = self.get_dt();
            plotter = self.get_plotter();
            for i = 1:numel(self.systems)
                self.systems(i).initialize(t1);
            end
            for t = t1:dt:t2
                startTime = clock;
                fprintf('Start Time %f : %f \n', startTime(5), startTime(6));
                for i = 1:numel(self.systems)
                    self.systems(i).find_control(L, t);
                end
                endTime = clock;
                fprintf('Start Time %f : %f \n', endTime(5), endTime(6));
                plotter.capture_past(t);
                plotter.capture_future(t:dt:t+L*dt);
                drawnow;
                if t==t1
                    if ~isempty(plotter.fig)
                        self.movie = getframe(plotter.fig);
                    end
                else
                    if ~isempty(plotter.fig)
                        self.movie(end+1) = getframe(plotter.fig);
                    end
                end
                for i = 1:numel(self.systems)
                    self.systems(i).advance(t);
                end
            end
        end
    end
    
end

