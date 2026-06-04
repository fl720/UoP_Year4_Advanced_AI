function f = shekel_fitness(x, A, c)
%SHEKEL_FITNESS  Evaluate the Shekel function at point x.
%
%  The Shekel function has multiple local minima (one per row of A).
%  GA minimises f, so we return the negative sum directly – the global
%  minimum of f corresponds to the deepest (most negative) valley.
%
%  f(x) = -sum_{i=1}^{m}  1 / ( ||x - a_i||^2 + c_i )
%
%  INPUT
%    x  – [1 x 4] or [4 x 1] candidate solution
%    A  – [m x 4] peak centres  (from shekel_params)
%    c  – [m x 1] peak widths   (from shekel_params)
%
%  OUTPUT
%    f  – scalar fitness value (negative; GA minimises this)
% =========================================================

    x = x(:)';       % ensure row vector [1 x 4]
    m = size(A, 1);

    f = 0;
    for i = 1:m
        diff_sq = sum((x - A(i,:)).^2);   % squared Euclidean distance
        f = f - 1 / (diff_sq + c(i));
    end
    % f is negative; the global minimum ≈ -10.54 (Shekel-10)
end