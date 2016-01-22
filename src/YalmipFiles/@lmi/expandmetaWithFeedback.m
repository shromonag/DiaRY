function [F, mapF] = expandmetaWithFeedback(F)
mapF = [];
F = flatten(F);
meta = find(is(F,'meta'));
Fnew = [];
for i = meta(:)'
    init = length(Fnew);
    Fnew = [Fnew, feval(F.clauses{i}.data{1},'expand',[],F.clauses{i}.data{2:end})];
    mapF = [mapF [i; length(Fnew) - init]];
end
F.clauses = {F.clauses{setdiff(1:size(F.clauses,2),meta)}};
F.LMIid(meta) = [];
F = [F,Fnew];