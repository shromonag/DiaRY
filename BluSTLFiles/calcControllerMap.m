%% Update the controller RHS values

function vector = calcControllerMap(done, p, X, U, W)
    vector = [done p];
    for i = 1 : length(X(1,:))
        vector = [vector X(:,i)'];
    end
    for i = 1 : length(U(1,:))
        vector = [vector U(:,i)'];
    end
    for i = 1 : length(W(1,:))
        vector = [vector W(:,i)'];
    end
end