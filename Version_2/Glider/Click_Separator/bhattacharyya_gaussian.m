function DB = bhattacharyya_gaussian(mu1, Sigma1, mu2, Sigma2)
    % mu1, mu2: 2x1 mean vectors
    % Sigma1, Sigma2: 2x2 covariance matrices

    mu1 = mu1(:);  % ensure column
    mu2 = mu2(:);

    Sigma = 0.5 * (Sigma1 + Sigma2);

    diffMu = mu2 - mu1;

    term1 = 0.125 * (diffMu') / Sigma * diffMu;  % 1/8 * (mu2-mu1)' * inv(Sigma) * (mu2-mu1)
    term2 = 0.5 * log(det(Sigma) / sqrt(det(Sigma1) * det(Sigma2)));

    DB = term1 + term2;
end
