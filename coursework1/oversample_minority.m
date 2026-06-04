function [X_out, y_out] = oversample_minority(X, y)
%OVERSAMPLE_MINORITY  Random oversampling with Gaussian noise to balance
%                     a binary classification dataset.
%
%  The dataset has 500 Healthy (0) and 100 Fracture (1) – a 5:1 imbalance.
%  Strategy: duplicate minority class samples with small Gaussian jitter
%  (σ = 0.05 of each feature's std) until classes are equal.
%  This avoids exact duplicates while staying close to real data.
%
%  INPUT
%    X  – [N x F] feature matrix (already normalised)
%    y  – [N x 1] binary labels
%
%  OUTPUT
%    X_out, y_out – balanced dataset (shuffled)
% =========================================================

    classes   = unique(y);
    counts    = arrayfun(@(c) sum(y==c), classes);
    [n_maj, idx_maj] = max(counts);
    [~,     idx_min] = min(counts);
    class_maj = classes(idx_maj);
    class_min = classes(idx_min);
    n_min     = counts(idx_min);
    n_needed  = n_maj - n_min;

    fprintf('    Minority class (%d): %d samples  →  need %d synthetic\n', ...
            class_min, n_min, n_needed);

    % Rows belonging to minority class
    X_min = X(y == class_min, :);

    % Noise level: 5% of each feature's std (≈0.05 after z-score)
    noise_std = 0.05 * std(X_min);

    % Sample with replacement and add jitter
    rng(42);
    idx = randi(n_min, n_needed, 1);
    X_synthetic = X_min(idx, :) + ...
                  randn(n_needed, size(X,2)) .* noise_std;

    y_synthetic = repmat(class_min, n_needed, 1);

    % Combine and shuffle
    X_out = [X; X_synthetic];
    y_out = [y; y_synthetic];

    perm  = randperm(size(X_out, 1));
    X_out = X_out(perm, :);
    y_out = y_out(perm);
end