function C = min_ge(Ts, T)
    C = [];
    for i=1:numel(Ts)
        l = min(length(T), length(Ts{i}));
        if l>0
            C = [C, Ts{i}(1:l)>=T(1:l)];
        end
    end
end
