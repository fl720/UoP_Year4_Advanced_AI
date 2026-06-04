function [A, c] = shekel_params(m)
%SHEKEL_PARAMS  Return the standard Dixon-Szegő / NIST parameters for
%               the Shekel family of benchmark functions.
%
%  The Shekel function is defined as:
%
%    f(x) = -sum_{i=1}^{m}  1 / ( sum_{j=1}^{4} (x_j - a_ij)^2 + c_i )
%
%  where:
%    x  – 4-dimensional input vector, x_j ∈ [0, 10]
%    A  – [10 x 4] matrix of peak centre positions
%    c  – [10 x 1] vector of peak widths (smaller c → sharper peak)
%    m  – number of active peaks  (5, 7, or 10 → Shekel-5/7/10)
%
%  The global minimum is near x* ≈ [4, 4, 4, 4]:
%    Shekel-5  : f(x*) ≈ -10.1532
%    Shekel-7  : f(x*) ≈ -10.4029
%    Shekel-10 : f(x*) ≈ -10.5364
%
%  Reference: Dixon & Szegő (1978), Towards a Global Optimisation, Vol. 2.
%             Also listed in Molga & Smutnicki (2005) test functions.
%
%  INPUT
%    m  – integer: 5, 7, or 10
%
%  OUTPUT
%    A  – [m x 4] peak centres (first m rows of the full 10-row matrix)
%    c  – [m x 1] peak widths  (first m elements of the full vector)
% =========================================================

    if ~ismember(m, [5 7 10])
        error('shekel_params: m must be 5, 7, or 10. Got %d.', m);
    end

    % Full 10-row parameter matrix A (peak centres)
    A_full = [4.0  4.0  4.0  4.0;
              1.0  1.0  1.0  1.0;
              8.0  8.0  8.0  8.0;
              6.0  6.0  6.0  6.0;
              3.0  7.0  3.0  7.0;
              2.0  9.0  2.0  9.0;
              5.0  5.0  3.0  3.0;
              8.0  1.0  8.0  1.0;
              6.0  2.0  6.0  2.0;
              7.0  3.6  7.0  3.6];

    % Full 10-element width vector c (×0.1 per standard convention)
    c_full = [0.1; 0.2; 0.2; 0.4; 0.4;
              0.6; 0.3; 0.7; 0.5; 0.5];

    % Return first m rows/elements
    A = A_full(1:m, :);
    c = c_full(1:m);
end