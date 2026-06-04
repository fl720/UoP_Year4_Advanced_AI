%% =========================================================
%  MAIN.M  –  Neural Network for Osteoporotic Fracture
%             Classification (M33176 Coursework 1)
%
%  Run this file to execute the full pipeline:
%    1. Load & pre-process data
%    2. Split data (stratified 70/15/15)
%    3. Train neural network (class weights to handle imbalance)
%    4. Evaluate performance (confusion matrix, ROC, AUC, F1)
%
%  Class imbalance (500:100) is handled via inverse-frequency class
%  weights inside train_network.m – no synthetic data generated.
%
%  All sub-tasks are in separate function files for clarity.
% =========================================================
clc; clear; close all;
rng(42);   % fix random seed – reproducible results

%% ── 1. LOAD & PRE-PROCESS ───────────────────────────────
fprintf('=== Step 1: Loading and pre-processing data ===\n');
[X, y] = load_and_preprocess('M33176_1_CW_REF_DEF_AppendixA Osteoporosis Dataset.xlsx');
fprintf('    Features: %d x %d   |  Class 0: %d  Class 1: %d\n', ...
    size(X,1), size(X,2), sum(y==0), sum(y==1));

%% ── 2. SPLIT DATA ───────────────────────────────────────
fprintf('\n=== Step 2: Splitting data (70/15/15 stratified) ===\n');
[X_train, y_train, X_val, y_val, X_test, y_test] = ...
    split_data(X, y, 0.7, 0.15);
fprintf('    Train: %d  |  Val: %d  |  Test: %d\n', ...
    size(X_train,1), size(X_val,1), size(X_test,1));
fprintf('    Train – Class 0: %d  Class 1: %d\n', ...
    sum(y_train==0), sum(y_train==1));

%% ── 3. TRAIN NEURAL NETWORK ─────────────────────────────
fprintf('\n=== Step 3: Training neural network ===\n');
net = train_network(X_train, y_train, X_val, y_val);

%% ── 4. EVALUATE ─────────────────────────────────────────
fprintf('\n=== Step 4: Evaluating on test set ===\n');
evaluate_network(net, X_test, y_test, 'Test Set');

fprintf('\n=== Pipeline complete. ===\n');