function metrics = evaluate_network(net, X, y, split_name)
%EVALUATE_NETWORK  Compute and visualise all required performance metrics
%                  for a trained patternnet on a given dataset split.
%
%  Metrics produced
%    - Confusion matrix (plotconfusion)
%    - Accuracy, Precision, Recall (Sensitivity), Specificity
%    - F1 score
%    - ROC curve + AUC (plotroc)
%
%  INPUT
%    net         – trained network from train_network()
%    X           – [N x F] feature matrix
%    y           – [N x 1] binary labels (0 / 1)
%    split_name  – string label for figure titles (e.g. 'Test Set')
%
%  OUTPUT
%    metrics – struct with fields: accuracy, precision, recall,
%              specificity, f1, auc
% =========================================================

    %% ── Forward pass ─────────────────────────────────────
    Xin    = X';                          % [F x N]
    probs  = net(Xin);                    % [2 x N] softmax probabilities
    prob1  = probs(2, :)';                % P(class=1)  [N x 1]

    % Threshold = 0.35 (lowered from 0.5) to favour Recall over Precision.
    % Rationale: in fracture screening, a missed fracture (FN) is clinically
    % more costly than a false alarm (FP) that triggers further investigation.
    threshold = 0.35;
    y_pred = double(prob1 >= threshold);

    %% ── Confusion matrix counts ──────────────────────────
    TP = sum((y_pred == 1) & (y == 1));
    TN = sum((y_pred == 0) & (y == 0));
    FP = sum((y_pred == 1) & (y == 0));
    FN = sum((y_pred == 0) & (y == 1));

    %% ── Scalar metrics ───────────────────────────────────
    accuracy    = (TP + TN) / numel(y);
    precision   = safe_div(TP, TP + FP);
    recall      = safe_div(TP, TP + FN);   % sensitivity
    specificity = safe_div(TN, TN + FP);
    f1          = safe_div(2 * precision * recall, precision + recall);

    %% ── ROC curve & AUC ─────────────────────────────────
    [tpr_vec, fpr_vec, ~, auc] = perfcurve(y, prob1, 1);

    %% ── Console report ───────────────────────────────────
    fprintf('\n  ── %s Results ──────────────────────────\n', split_name);
    fprintf('  Accuracy    : %.4f\n', accuracy);
    fprintf('  Precision   : %.4f\n', precision);
    fprintf('  Recall      : %.4f\n', recall);
    fprintf('  Specificity : %.4f\n', specificity);
    fprintf('  F1 Score    : %.4f\n', f1);
    fprintf('  AUC         : %.4f\n', auc);
    fprintf('  TP=%d  TN=%d  FP=%d  FN=%d\n', TP, TN, FP, FN);

    %% ── Figure 1: Confusion Matrix ───────────────────────
    figure('Name', ['Confusion Matrix – ' split_name], 'NumberTitle', 'off');
    T_onehot = to_onehot(y)';                    % [2 x N]
    plotconfusion(T_onehot, probs);
    title(['Confusion Matrix – ' split_name]);

    %% ── Figure 2: ROC Curve ──────────────────────────────
    figure('Name', ['ROC Curve – ' split_name], 'NumberTitle', 'off');
    plot(fpr_vec, tpr_vec, 'b-', 'LineWidth', 2);  hold on;
    plot([0 1],  [0 1],   'k--', 'LineWidth', 1);  hold off;
    xlabel('False Positive Rate');
    ylabel('True Positive Rate (Sensitivity)');
    title(sprintf('ROC Curve – %s   (AUC = %.4f)', split_name, auc));
    legend('NN classifier', 'Random classifier', 'Location', 'southeast');
    grid on;

    %% ── Pack output ──────────────────────────────────────
    metrics.accuracy    = accuracy;
    metrics.precision   = precision;
    metrics.recall      = recall;
    metrics.specificity = specificity;
    metrics.f1          = f1;
    metrics.auc         = auc;
end

% ── Helpers ──────────────────────────────────────────────
function r = safe_div(a, b)
    if b == 0, r = 0; else, r = a / b; end
end

function T = to_onehot(y)
    T = zeros(numel(y), 2);
    T(y == 0, 1) = 1;
    T(y == 1, 2) = 1;
end