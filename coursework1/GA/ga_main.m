%% =========================================================
%  GA_MAIN.M  –  Genetic Algorithm for Global Optimisation
%               of the Shekel Family of Functions (M33176 CW1)
%
%  Runs the full GA pipeline:
%    1. Define Shekel fitness function parameters
%    2. Configure GA options (population, operators, stopping)
%    3. Run GA solver
%    4. Report and visualise results
%
%  Requires: Matlab Global Optimization Toolbox
% =========================================================
clc; clear; close all;
rng(42);   % fix random seed for reproducibility

%% ── 1. SHEKEL FUNCTION SETUP ─────────────────────────────
m = 10;    % number of local minima  (5 = Shekel-5, 7, or 10)
           % m=10 is the hardest version – most local optima to escape

[A, c] = shekel_params(m);
fprintf('=== Shekel-%d  (4-dimensional, %d local minima) ===\n', m, m);

% Wrap into a function handle for ga()
fitnessFcn = @(x) shekel_fitness(x, A, c);

%% ── 2. PROBLEM BOUNDS ────────────────────────────────────
n_vars = 4;
lb = -15 * ones(1, n_vars);   % search domain per Appendix B: -15 ≤ x_i ≤ 20
ub =  20 * ones(1, n_vars);

%% ── 3. CONFIGURE GA ──────────────────────────────────────
fprintf('\n=== Configuring GA options ===\n');
options = ga_options(n_vars);

%% ── 4. RUN GA ────────────────────────────────────────────
fprintf('\n=== Running GA solver ===\n');
[x_best, f_best, exitflag, output] = ...
    ga(fitnessFcn, n_vars, [], [], [], [], lb, ub, [], options);

%% ── 5. REPORT & VISUALISE ────────────────────────────────
report_results(x_best, f_best, exitflag, output, m);
visualise_ga(m, lb, ub, fitnessFcn);