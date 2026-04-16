function sensitivity_analysis(obj_fun, x0, lb, ub, num_points, grid_size, x_labels)
% SENSITIVITY_ANALYSIS Computes and plots the logarithmic sensitivities
% w.r.t each variable in a single figure grid.
%
%   obj_fun   : Function handle to the objective function
%   x0        : Nominal point around which to perform the analysis
%   lb        : Lower bounds array
%   ub        : Upper bounds array
%   num_points: Number of points to evaluate (default: 100)
%   grid_size : [rows, cols] for the subplot grid (default: computed based on n_vars)
%   x_labels  : Cell array of custom x-axis labels (default: x_1, x_2, etc.)

    if nargin < 5 || isempty(num_points)
        num_points = 100;
    end
    
    n_vars = length(x0);
    
    if nargin < 6 || isempty(grid_size)
        cols = ceil(sqrt(n_vars));
        rows = ceil(n_vars / cols);
        grid_size = [rows, cols];
    end
    
    if nargin < 7 || isempty(x_labels)
        x_labels = cell(1, n_vars);
        for i = 1:n_vars
            x_labels{i} = sprintf('x_{%d}', i);
        end
    end
    
    figure('Name', 'Logarithmic Sensitivity Analysis', 'Position', [100, 100, 1200, 800]);
    tiledlayout(grid_size(1), grid_size(2), 'TileSpacing', 'loose', 'Padding', 'compact');

    for i = 1:n_vars
        % Vary the i-th variable between its lower and upper bounds
        xi_vals = linspace(lb(i), ub(i), num_points);
        f_vals = zeros(1, num_points);
        
        for j = 1:num_points
            x_test = x0;
            x_test(i) = xi_vals(j);
            f_vals(j) = obj_fun(x_test);
        end
        
        % Calculate discrete derivatives
        df_dxi = gradient(f_vals, xi_vals);
        
        % Calculate logarithmic sensitivities: (df/dx_i) * (x_i / f)
        % Using eps to prevent division by zero in f_vals
        log_sens = df_dxi .* (xi_vals ./ (f_vals + eps));
        
        % Plot logarithmic sensitivity
        nexttile(i);
        plot(xi_vals, log_sens, 'LineWidth', 2, 'Color', '#EDB120');
        
        label_str = x_labels{i};
        title(sprintf('Sensitivity of %s %s', 'f', ''));
        xlabel(label_str, 'Interpreter', 'latex');
        ylabel('S', 'Interpreter', 'latex');
        grid on;
    end
end
