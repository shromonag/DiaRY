function [m, S] = linearGP(X, y, noise_param)
    % function: LinearGP: Finding the mean and covariance based on a linear
    %                     guassian process and a set of sampling points.
    % input: X, y, nois_param
    % output: m, S: mean and covariance matrix for confidence
    
    sigma_sq = noise_param^2;
    invPriorCov =  eye(size(X, 2));
    if sum(X(:, end) == 1) == length(y)
        invPriorCov(end, end) = 1e-10;
    end
    inv_A = inv((1/sigma_sq)*(X'*X) + invPriorCov);
    m = (1/sigma_sq)*inv_A*X'*y;
    S = inv_A;