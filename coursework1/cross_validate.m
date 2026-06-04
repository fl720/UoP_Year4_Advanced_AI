%% =========================================================
%  CROSS_VALIDATE.M  –  5-fold stratified cross-validation
%
%  Complements main.m by giving a more robust estimate of
%  generalisation performance across different data splits.
%  Reports mean ± std for Accuracy, F1, and AUC.
% =========================================================
clc; clear; close all;
rng(42);

%% ── Load and pre-process ─────────────────────────────────
fprintf('Loading data...\n');
[X, y] = load_and_preprocess('M33176_1_CW_REF_DEF_AppendixA Osteoporosis Dataset.xlsx');
[X, y] = oversample_minority(X, y);

%% ── 5-fold stratified cross-validation ──────────────────
K = 5;
cv = cvpartition(y, 'KFold', K, 'Stratify', true);

acc_vec = zeros(K,1);
f1_vec  = zeros(K,1);
auc_vec = zeros(K,1);

for fold = 1:K
    fprintf('\n── Fold %d/%d ──────────────────────────────\n', fold, K);

    % Split indices
    tr_idx  = training(cv, fold);
    te_idx  = test(cv, fold);

    X_tr = X(tr_idx, :);  y_tr = y(tr_idx);
    X_te = X(te_idx, :);  y_te = y(te_idx);

    % Use 15% of training as validation for early stopping
    n_val  = round(0.15 * size(X_tr,1));
    X_val  = X_tr(end-n_val+1:end, :);
    y_val  = y_tr(end-n_val+1:end);
    X_tr   = X_tr(1:end-n_val, :);
    y_tr   = y_tr(1:end-n_val);

    % Train & evaluate
    net = train_network(X_tr, y_tr, X_val, y_val);
    m   = evaluate_network(net, X_te, y_te, sprintf('Fold %d', fold));

    acc_vec(fold) = m.accuracy;
    f1_vec(fold)  = m.f1;
    auc_vec(fold) = m.auc;
end

%% ── Summary ──────────────────────────────────────────────
fprintf('\n══════ Cross-Validation Summary ══════\n');
fprintf('Accuracy  : %.4f ± %.4f\n', mean(acc_vec), std(acc_vec));
fprintf('F1 Score  : %.4f ± %.4f\n', mean(f1_vec),  std(f1_vec));
fprintf('AUC       : %.4f ± %.4f\n', mean(auc_vec), std(auc_vec));