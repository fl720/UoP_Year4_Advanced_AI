function net = train_network(X_train, y_train, X_val, y_val)
%TRAIN_NETWORK  Design and train a feedforward NN for binary classification
%               using Matlab's patternnet (Neural Network Toolbox).
%
%  ARCHITECTURE
%    Input  : 25 features (all retained with targeted imputation)
%    Hidden : Layer 1 – 16 neurons (tansig)
%             Layer 2 –  8 neurons (tansig)
%    Output :  2 neurons (softmax → class probabilities)
%
%  NOTE ON ARCHITECTURE CHOICE
%    With only 420 training samples, a smaller network (16-8) is preferred
%    over the original (32-16) to reduce overfitting risk on this small
%    imbalanced dataset. Fewer parameters → less memorisation of majority class.
%
%  CLASS IMBALANCE
%    No oversampling applied. The 5:1 imbalance (350 Healthy : 70 Fracture)
%    is addressed by:
%      (a) Reduced regularisation (0.001) to allow the network to fit minority
%      (b) Increased early stopping patience (max_fail=50) to allow more training
%      (c) Decision threshold adjusted to 0.35 at evaluation time
%
%  INPUT
%    X_train, y_train – [N x F] features and [N x 1] labels
%    X_val,   y_val   – validation features and labels
%
%  OUTPUT
%    net  – trained network object
% =========================================================

    %% ── Network topology ─────────────────────────────────
    hiddenSizes = [16 8];      % smaller network for small dataset
    net = patternnet(hiddenSizes, 'trainscg');

    %% ── Activation functions ─────────────────────────────
    net.layers{1}.transferFcn = 'tansig';
    net.layers{2}.transferFcn = 'tansig';

    %% ── Training parameters ──────────────────────────────
    net.trainParam.epochs     = 1000;  % more budget to learn minority class
    net.trainParam.max_fail   = 50;    % more patience before early stopping
    net.trainParam.showWindow = false;
    net.trainParam.show       = 50;

    % Lower regularisation – high L2 suppresses weights needed for minority class
    net.performParam.regularization = 0.001;

    %% ── Data division (manual splits) ────────────────────
    net.divideFcn  = 'divideind';
    N     = size(X_train, 1);
    N_val = size(X_val,   1);

    net.divideParam.trainInd = 1 : N;
    net.divideParam.valInd   = N+1 : N+N_val;
    net.divideParam.testInd  = [];

    %% ── Combine train + val ──────────────────────────────
    X_all = [X_train; X_val];
    y_all = [y_train; y_val];

    Xin = X_all';
    Tin = to_onehot(y_all)';

    %% ── Train ────────────────────────────────────────────
    fprintf('    Architecture: 25 → 16 → 8 → 2  (trainscg)\n');
    [net, tr] = train(net, Xin, Tin);

    fprintf('    Stopped at epoch %d  (reason: %s)\n', ...
            tr.num_epochs, tr.stop);
    fprintf('    Best val performance: %.4f\n', min(tr.vperf));

    %% ── Plot training curve ──────────────────────────────
    % Shows cross-entropy loss for train and validation sets per epoch.
    % The gap between curves indicates overfitting; early stopping triggers
    % when validation loss stops improving (max_fail consecutive checks).
    figure('Name','Training Curve','NumberTitle','off');
    epochs = 1:numel(tr.perf);
    plot(epochs, tr.perf,  'b-', 'LineWidth', 1.8, 'DisplayName', 'Training loss');
    hold on;
    plot(epochs, tr.vperf, 'r--','LineWidth', 1.8, 'DisplayName', 'Validation loss');
    % Mark the best validation epoch
    [~, best_ep] = min(tr.vperf);
    plot(best_ep, tr.vperf(best_ep), 'ro', 'MarkerSize', 10, ...
         'LineWidth', 2, 'DisplayName', 'Best validation epoch');
    hold off;
    xlabel('Epoch');
    ylabel('Cross-Entropy Loss');
    title('Training and Validation Loss per Epoch');
    legend('Location', 'northeast');
    grid on;

    %% ── Diagnose probability distribution ───────────────
    probs_train = net(X_train');
    p1_train    = probs_train(2, :);
    fprintf('    P(Fracture) on train – min:%.3f  mean:%.3f  max:%.3f\n', ...
            min(p1_train), mean(p1_train), max(p1_train));
    fprintf('    P(Fracture) for actual Fracture samples – mean:%.3f\n', ...
            mean(p1_train(y_train==1)));
    fprintf('    P(Fracture) for actual Healthy  samples – mean:%.3f\n', ...
            mean(p1_train(y_train==0)));

    save('trained_net.mat', 'net', 'tr');
    fprintf('    Model saved to trained_net.mat\n');
end

function T = to_onehot(y)
    T = zeros(numel(y), 2);
    T(y == 0, 1) = 1;
    T(y == 1, 2) = 1;
end