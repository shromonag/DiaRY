function C = max_ge(Fs, F)
    C = [];
    if numel(Fs)>0
        l = length(F);
        for i=1:numel(Fs)
           l = min(l, length(Fs{i}));
        end
        if l>0
           Fmax = Fs{1}(1:l);
           for i=2:numel(Fs)
               Fmax = max(Fmax, Fs{i}(1:l));
           end
           C = Fmax>=F(1:l);
        end
    end
end

