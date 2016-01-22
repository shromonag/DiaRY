%% Collect maximal slacks from the user for the predicates

function maxSlacks = MaximalSlacks(DiagnosedPredicates)
    fprintf('The following predicates can be modified : \n');
    for i = 1 : length(DiagnosedPredicates(1,:))
        fprintf('%d. Predicate node %d of STL %d\n',i, DiagnosedPredicates(2,i), DiagnosedPredicates(1,i));
    end
    prompt = ['Enter an array of size ' num2str(length(DiagnosedPredicates(1,:))) ' assigning maximal slacks to the predicates. If a predicate is not restricted then assign -1. \n'];
    maxSlacks = input(prompt);
end