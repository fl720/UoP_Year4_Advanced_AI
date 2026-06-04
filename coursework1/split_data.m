function [X_tr, y_tr, X_val, y_val, X_te, y_te] = ...
         split_data(X, y, train_ratio, val_ratio)
%SPLIT_DATA  Stratified split into train / validation / test subsets.
%
%  Stratified means each subset preserves the class ratio of the full
%  dataset, preventing a subset from being dominated by one class.
%
%  INPUT
%    X, y          – balanced feature matrix and label vector
%    train_ratio   – fraction for training  (e.g. 0.70)
%    val_ratio     – fraction for validation (e.g. 0.15)
%                   test_ratio is inferred as 1 - train - val
%
%  OUTPUT
%    X_tr / y_tr   – training set
%    X_val / y_val – validation set
%    X_te  / y_te  – test set
% =========================================================

    classes  = unique(y);
    idx_tr   = [];
    idx_val  = [];
    idx_te   = [];

    for c = classes'
        idx_c = find(y == c);
        n_c   = numel(idx_c);
        idx_c = idx_c(randperm(n_c));   % shuffle within class

        n_tr  = round(n_c * train_ratio);
        n_val = round(n_c * val_ratio);

        idx_tr  = [idx_tr;  idx_c(1 : n_tr)];                       %#ok
        idx_val = [idx_val; idx_c(n_tr+1 : n_tr+n_val)];            %#ok
        idx_te  = [idx_te;  idx_c(n_tr+n_val+1 : end)];             %#ok
    end

    % Final shuffle of each split
    idx_tr  = idx_tr(randperm(numel(idx_tr)));
    idx_val = idx_val(randperm(numel(idx_val)));
    idx_te  = idx_te(randperm(numel(idx_te)));

    X_tr  = X(idx_tr,  :);   y_tr  = y(idx_tr);
    X_val = X(idx_val, :);   y_val = y(idx_val);
    X_te  = X(idx_te,  :);   y_te  = y(idx_te);
end