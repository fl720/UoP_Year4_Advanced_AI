function state = ga_plot_std(options, state, flag)
%GA_PLOT_STD  Custom GA plot function: standard deviation of fitness
%             values across the population at each generation.
%
%  Registered via optimoptions 'PlotFcn'. Matlab calls this automatically
%  after each generation with updated state.
%
%  A shrinking std indicates population convergence (loss of diversity).
%  A persistently high std suggests healthy exploration.
%
%  Alongside gaplotbestf and gaplotmean, this satisfies the coursework
%  requirement to visualise best, mean, AND std per generation.
% =========================================================

    persistent ax

    switch flag
        case 'init'
            ax = gca;
            title(ax, 'Std Dev of Fitness (Population Diversity)');
            xlabel(ax, 'Generation');
            ylabel(ax, 'Std Dev of Scores');
            hold(ax, 'on');
            grid(ax, 'on');

        case {'iter', 'interrupt'}
            gen    = state.Generation;
            sd_val = std(state.Score);
            plot(ax, gen, sd_val, 'r.', 'MarkerSize', 6);

        case 'done'
            hold(ax, 'off');
    end
end