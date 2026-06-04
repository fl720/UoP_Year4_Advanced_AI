function [state, options, optchanged] = ga_output_logger(options, state, flag)
%GA_OUTPUT_LOGGER  Output function that records per-generation statistics
%                  into a persistent struct saved to ga_history.mat.
%
%  Saved fields (one entry per generation):
%    history.gen   – generation number
%    history.best  – best fitness value
%    history.mean  – mean fitness across population
%    history.sd    – std dev of fitness across population
%
%  This lets visualise_ga() re-plot everything after the run without
%  relying on the live plot window.
% =========================================================

    persistent history

    optchanged = false;

    switch flag
        case 'init'
            history.gen  = [];
            history.best = [];
            history.mean = [];
            history.sd   = [];

        case {'iter', 'interrupt'}
            history.gen(end+1)  = state.Generation;
            history.best(end+1) = min(state.Score);
            history.mean(end+1) = mean(state.Score);
            history.sd(end+1)   = std(state.Score);

        case 'done'
            save('ga_history.mat', 'history');
            fprintf('\n    GA history saved to ga_history.mat\n');
    end
end