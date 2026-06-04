function options = ga_options(n_vars)
%GA_OPTIONS  Construct and return an optimoptions object for Matlab's ga().
%
%  All GA hyper-parameters are set here in one place so they are easy
%  to find, change, and document for the report.
%
%  KEY DESIGN DECISIONS (explained for report writing)
%  ────────────────────────────────────────────────────
%  Population size = 150
%    Larger than the default (50) to maintain genetic diversity and
%    reduce premature convergence risk on a multimodal landscape.
%
%  Selection = Tournament (TournamentSize = 4)
%    Provides controllable selection pressure: larger tournaments →
%    higher pressure. Size=4 keeps a moderate pressure that does not
%    cause premature convergence while still driving improvement.
%    Alternative tried: stochastic uniform (roulette-like) – more
%    exploratory but slower convergence.
%
%  Crossover = Scattered (uniform)  rate = 0.85
%    Randomly assigns each gene from either parent, giving high
%    recombination diversity. Rate=0.85 means 85% of offspring come
%    from crossover; 15% from mutation alone.
%
%  Mutation = Adaptive Feasible (default for bounded problems)
%    Automatically adjusts mutation step size based on success rate,
%    balancing exploration early in the run and exploitation later.
%    This keeps selection pressure roughly constant throughout the run.
%
%  Elite count = 5  (≈ 3% of population)
%    Guarantees the best solutions survive each generation (elitism),
%    preventing regression. Too high → reduces diversity.
%
%  Max generations = 500, stall limit = 100
%    Generous budget; early stopping via stall prevents wasted effort
%    once the population has converged.
%
%  PlotFcns: gaplotbestf + gaplotmean + custom std plot
%    Required by the coursework: visualise best, mean, and std of
%    fitness per generation.
%
%  INPUT
%    n_vars  – number of decision variables (4 for Shekel)
%
%  OUTPUT
%    options – optimoptions object ready to pass to ga()
% =========================================================

    pop_size    = 150;
    elite_count = 5;            % number of elite individuals preserved

    % Build options sequentially to allow inline section comments
    options = optimoptions('ga');

    % Population
    options.PopulationSize         = pop_size;
    options.PopulationType         = 'doubleVector';
    options.InitialPopulationRange = [-15*ones(1,n_vars); 20*ones(1,n_vars)];

    % Selection – Tournament (size=4): moderate, controllable pressure
    options.SelectionFcn           = {@selectiontournament, 4};

    % Crossover – Scattered at rate 0.85: high recombination diversity
    options.CrossoverFcn           = 'crossoverscattered';
    options.CrossoverFraction      = 0.85;

    % Mutation – Adaptive Feasible: auto-scales step size each generation
    options.MutationFcn            = 'mutationadaptfeasible';

    % Elitism – preserve top 5 individuals each generation
    options.EliteCount             = elite_count;

    % Stopping criteria
    options.MaxGenerations         = 500;
    options.MaxStallGenerations    = 100;  % stop if no improvement for 100 gen
    options.FunctionTolerance      = 1e-8;

    % Display and plotting
    options.Display                = 'iter';
    options.PlotFcn                = {@gaplotbestf, @gaplotscores, @ga_plot_std};
    options.OutputFcn              = @ga_output_logger;

    % Print summary for verification
    fprintf('  Population size  : %d\n', pop_size);
    fprintf('  Elite count      : %d\n', elite_count);
    fprintf('  Selection        : Tournament (size=4)\n');
    fprintf('  Crossover        : Scattered  (rate=%.2f)\n', 0.85);
    fprintf('  Mutation         : Adaptive Feasible\n');
    fprintf('  Max generations  : 500  (stall limit: 100)\n');
end