function report_results(x_best, f_best, exitflag, output, m)
%REPORT_RESULTS  Print a formatted summary of the GA run to the console.
%
%  INPUT
%    x_best    – [1 x 4] best solution found
%    f_best    – scalar best fitness value
%    exitflag  – integer exit condition from ga()
%    output    – struct with run statistics from ga()
%    m         – Shekel variant (5, 7, or 10)
% =========================================================

    % Known global minima for reference (Dixon & Szegő, 1978)
    known = struct('m5', -10.1532, 'm7', -10.4029, 'm10', -10.5364);
    ref_field = sprintf('m%d', m);
    f_ref = known.(ref_field);

    gap = abs((f_best - f_ref) / f_ref) * 100;   % % gap from known optimum

    % Exit flag meanings
    exit_msgs = {
        1, 'Average cumulative change in fitness < TolFun';
        3, 'Fitness value limit reached';
        4, 'Max stall generations reached';
        5, 'Max generations reached';
       -1, 'Stopped by output or plot function';
       -2, 'No feasible point found'
    };
    exit_str = 'Unknown';
    for k = 1:size(exit_msgs,1)
        if exitflag == exit_msgs{k,1}
            exit_str = exit_msgs{k,2};
            break;
        end
    end

    fprintf('\n══════════════════════════════════════════════\n');
    fprintf('  GA Results – Shekel-%d\n', m);
    fprintf('══════════════════════════════════════════════\n');
    fprintf('  Best fitness found : %.6f\n', f_best);
    fprintf('  Known global min   : %.6f\n', f_ref);
    fprintf('  Gap from optimum   : %.4f%%\n', gap);
    fprintf('\n  Best solution x*:\n');
    fprintf('    x = [%.6f, %.6f, %.6f, %.6f]\n', ...
            x_best(1), x_best(2), x_best(3), x_best(4));
    fprintf('  (True optimum near [4, 4, 4, 4])\n');
    fprintf('\n  Generations run    : %d\n', output.generations);
    fprintf('  Function evals     : %d\n', output.funccount);
    fprintf('  Exit reason        : %s (flag=%d)\n', exit_str, exitflag);
    fprintf('══════════════════════════════════════════════\n');
end