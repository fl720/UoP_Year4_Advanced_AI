function visualise_ga(m, lb, ub, fitnessFcn)
%VISUALISE_GA  Produce publication-quality figures for the GA run.
%
%  Figures produced:
%    Fig 1 – Convergence: best / mean / std per generation (3 subplots)
%    Fig 2 – 2-D slice of the Shekel landscape (x3=x4=4, vary x1 & x2)
%             with the GA solution marked
%
%  Reads ga_history.mat (written by ga_output_logger during the run).
%
%  INPUT
%    m          – Shekel variant (5, 7, or 10)
%    lb, ub     – [1 x 4] lower/upper bounds
%    fitnessFcn – function handle to shekel_fitness
% =========================================================

    %% ── Load history ─────────────────────────────────────
    if ~isfile('ga_history.mat')
        warning('ga_history.mat not found – skipping convergence plots.');
        return;
    end
    load('ga_history.mat', 'history');

    %% ── Fig 1: Convergence plots ─────────────────────────
    figure('Name', sprintf('GA Convergence – Shekel-%d', m), ...
           'NumberTitle', 'off', 'Position', [100 100 900 600]);

    % Subplot 1: Best fitness per generation
    subplot(3,1,1);
    plot(history.gen, history.best, 'b-', 'LineWidth', 1.5);
    xlabel('Generation'); ylabel('Best Fitness');
    title(sprintf('Shekel-%d  –  Best Fitness per Generation', m));
    grid on;

    % Subplot 2: Mean fitness per generation
    subplot(3,1,2);
    plot(history.gen, history.mean, 'g-', 'LineWidth', 1.5);
    xlabel('Generation'); ylabel('Mean Fitness');
    title('Mean Fitness per Generation');
    grid on;

    % Subplot 3: Std dev (population diversity)
    subplot(3,1,3);
    plot(history.gen, history.sd, 'r-', 'LineWidth', 1.5);
    xlabel('Generation'); ylabel('Std Dev of Fitness');
    title('Population Diversity (Std Dev) per Generation');
    grid on;

    sgtitle(sprintf('GA Convergence Summary – Shekel-%d', m), ...
            'FontSize', 13, 'FontWeight', 'bold');

    %% ── Fig 2: 2-D contour + 3-D surface (x3=x4=4 slice) ──
    % Compute grid (shared by both plots)
    res   = 100;    % grid resolution (lower than before for 3D speed)
    xv    = linspace(lb(1), ub(1), res);
    yv    = linspace(lb(2), ub(2), res);
    [Xg, Yg] = meshgrid(xv, yv);
    Zg    = zeros(res, res);

    % Fix x3=4, x4=4 (near known optimum) – standard 2-D slice convention
    for r = 1:res
        for col_idx = 1:res
            pt = [Xg(r,col_idx), Yg(r,col_idx), 4.0, 4.0];
            Zg(r,col_idx) = fitnessFcn(pt);
        end
    end

    % ── Fig 2a: 2-D contour map ───────────────────────────
    figure('Name', sprintf('Shekel-%d Landscape (2-D contour)', m), ...
           'NumberTitle', 'off', 'Position', [200 200 650 520]);
    contourf(Xg, Yg, Zg, 40, 'LineStyle', 'none');
    colorbar; colormap('parula');
    hold on;
    plot(4, 4, 'w*', 'MarkerSize', 14, 'LineWidth', 2, ...
         'DisplayName', 'Global optimum (4,4,4,4)');
    hold off;
    xlabel('x_1'); ylabel('x_2');
    title(sprintf('Shekel-%d Fitness Landscape – 2D Slice  (x_3=x_4=4)', m));
    legend('Location','northeast');
    grid on;

    % ── Fig 2b: 3-D surface (replicating Appendix B style) ──
    figure('Name', sprintf('Shekel-%d Landscape (3-D surface)', m), ...
           'NumberTitle', 'off', 'Position', [250 150 700 560]);
    surf(Xg, Yg, Zg, 'EdgeColor', 'none');
    colormap('jet');           % matches Appendix B colour scheme
    colorbar;
    shading interp;            % smooth colour interpolation
    hold on;
    plot3(4, 4, max(Zg(:))+0.5, 'w*', 'MarkerSize', 14, 'LineWidth', 2, ...
          'DisplayName', 'Global optimum (4,4,4,4)');
    hold off;
    xlabel('x_1'); ylabel('x_2'); zlabel('f(x_1, x_2, 4, 4)');
    title(sprintf('Shekel-%d Fitness Landscape – 3D Surface  (x_3=x_4=4)', m));
    legend('Location', 'northeast');
    view(-45, 35);
    grid on;

    %% ── Fig 3: All m local optima – one subplot per peak ────
    % Each peak i is located at A(i,:) = [a_i1, a_i2, a_i3, a_i4].
    % To reveal peak i in 2D, we fix x3=A(i,3), x4=A(i,4) and vary x1,x2
    % over a local window [a_i1±6, a_i2±6].
    % This shows all m distinct basins that GA must distinguish between.
    [A, c] = shekel_params(m);

    % Layout: 2 rows x 5 cols for m=10; 2x4 for m=7; 1x5 for m=5
    n_cols = ceil(m / 2);
    n_rows = ceil(m / n_cols);
    res2   = 60;   % lower resolution per subplot for speed

    figure('Name', sprintf('Shekel-%d – All %d Local Optima', m, m), ...
           'NumberTitle', 'off', ...
           'Position', [50 50 260*n_cols 220*n_rows]);

    for i = 1:m
        ax_i = subplot(n_rows, n_cols, i);

        % Local window: ±6 around the peak centre, clipped to domain
        x1_lo = max(lb(1), A(i,1) - 6);   x1_hi = min(ub(1), A(i,1) + 6);
        x2_lo = max(lb(2), A(i,2) - 6);   x2_hi = min(ub(2), A(i,2) + 6);

        xv2 = linspace(x1_lo, x1_hi, res2);
        yv2 = linspace(x2_lo, x2_hi, res2);
        [Xp, Yp] = meshgrid(xv2, yv2);
        Zp = zeros(res2, res2);

        % Fix x3 = A(i,3), x4 = A(i,4) – the slice that passes through peak i
        for r2 = 1:res2
            for c2 = 1:res2
                pt = [Xp(r2,c2), Yp(r2,c2), A(i,3), A(i,4)];
                Zp(r2,c2) = fitnessFcn(pt);
            end
        end

        contourf(ax_i, Xp, Yp, Zp, 20, 'LineStyle', 'none');
        colormap(ax_i, 'parula');
        hold(ax_i, 'on');
        % Mark this peak's centre
        plot(ax_i, A(i,1), A(i,2), 'r*', 'MarkerSize', 9, 'LineWidth', 1.5);
        hold(ax_i, 'off');

        % Label: peak index, depth (fitness at centre), and c_i width
        f_centre = fitnessFcn([A(i,1), A(i,2), A(i,3), A(i,4)]);
        title(ax_i, sprintf('Peak %d  f=%.2f  c=%.1f', i, f_centre, c(i)), ...
              'FontSize', 8);
        xlabel(ax_i, 'x_1', 'FontSize', 7);
        ylabel(ax_i, 'x_2', 'FontSize', 7);
        set(ax_i, 'FontSize', 7);
    end

    sgtitle(sprintf('Shekel-%d: All %d Local Optima (each slice fixed at peak x_3,x_4)', m, m), ...
            'FontSize', 11, 'FontWeight', 'bold');
end