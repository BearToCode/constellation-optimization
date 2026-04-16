% Close and clear all
clc; clear; close all;
% Stop all parallel pools
delete(gcp('nocreate'))

% Import necessary libraries
addpath(genpath('lib'))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONFIGURATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

settings = config();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBJECTIVE FUNCTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('=============== OBJECTIVE FUNCTION ===============\n')

% semi-major axis, eccentricity, inclination, RAAN, argument of perigee, mean anomaly, true anomaly
lb = repmat([6578e3, 0, deg2rad(46), 0, 0, 0]', settings.num_sats, 1);
ub = repmat([7178e3, 0.030, deg2rad(180 - 46), deg2rad(360), deg2rad(360), deg2rad(360)]', settings.num_sats, 1);

% Construct the objective function with the given settings
f = constellation_obj_fun(settings);

% Consider a random initial solution
y0 = [6760e3, 0.00154, deg2rad(97.5643), deg2rad(182.719), deg2rad(275.0914), deg2rad(85.03242)]';

tic
initial_cost = f(repmat(y0, settings.num_sats, 1));
dt = toc;

fprintf('Initial cost: \t\t%d\n', initial_cost)
fprintf('Computation time: \t%.2f s\n', dt)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONSTRAINTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('================== CONSTRAINTS ==================\n')

settings.min_altitude = 200e3; % Minimum altitude [m]
settings.max_altitude = 800e3; % Maximum altitude [m]

fprintf('Minimum altitude: \t%.2f km\n', settings.min_altitude / 1e3)
fprintf('Maximum altitude: \t%.2f km\n', settings.max_altitude / 1e3)

g = constellation_constr(settings);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INITIAL ANALYSIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('================ INITIAL ANALYSIS ================\n')

% Temporarily consider only one satellite
original_sats = settings.num_sats;
settings.num_sats = 1;

n = 100;
f1 = constellation_obj_fun(settings);
g1 = constellation_constr(settings);
domains = zeros(6, n);
costs = zeros(6, n);
constraints1 = zeros(6, n);
constraints2 = zeros(6, n);

cached_path = get_cache_path('boundedness_analysis');

if exist(cached_path, 'file')
    fprintf('Loading cached boundedness analysis from %s...\n', cached_path)
    load(cached_path, 'domains', 'costs', 'constraints1', 'constraints2')
else
    fprintf('Performing boundedness analysis...\n')

    % For each variable, try changing it to its lower and upper bound and plot the cost function value
    parfor i = 1:length(y0)
        y0_temp = y0;

        fi = @(v) f1([y0_temp(1:i - 1); v; y0_temp(i + 1:end)]); %#ok<PFBNS>
        gi = @(v) g1([y0_temp(1:i - 1); v; y0_temp(i + 1:end)]); %#ok<PFBNS>

        domain = linspace(lb(i), ub(i), n);
        cost = arrayfun(fi, domain);

        constraint = arrayfun(gi, domain, UniformOutput = false);
        constraint = cell2mat(constraint);

        domains(i, :) = domain;
        costs(i, :) = cost;
        constraints1(i, :) = constraint(1, :);
        constraints2(i, :) = constraint(2, :);

    end

    save(cached_path, 'domains', 'costs', 'constraints1', 'constraints2')
    fprintf('Boundedness analysis completed and saved to cache.\n')
end

for i = 1:length(y0)
    original_value = y0(i);

    domain = domains(i, :);
    cost = costs(i, :);
    constraint1 = constraints1(i, :);
    constraint2 = constraints2(i, :);

    figure;
    plot(kep_values(domains(i, :), i), costs(i, :), LineWidth = 2);
    xlabel(kep_label(i), Interpreter = "latex")
    ylabel('Cost')
    % Plot constraints on a different y-axis
    yyaxis right;
    plot(kep_values(domains(i, :), i), constraint1, LineWidth = 2);
    hold on;
    plot(kep_values(domains(i, :), i), constraint2, LineWidth = 2);
    ylabel('$g$ constraints', Interpreter = "latex")
    grid on;
    legend('Cost', '$g_1$', '$g_2$', Interpreter = "latex")
    savefig(sprintf('boundedness_%d.png', i), [2 1.5]),
end

fprintf('Boundedness plots saved.\n')

% Plot the constraint surface for semi-major axis and eccentricity
a_domain = linspace(lb(1), ub(1), 100);
e_domain = linspace(lb(2), ub(2), 100);

[A, E] = meshgrid(a_domain, e_domain);
g_values = arrayfun(@(a, e) g1([a; e; y0(3:end)])', A(:), E(:), UniformOutput = false);
g_values = cell2mat(g_values)';
g1_values = reshape(g_values(1, :), size(A, 1), size(A, 2));
g2_values = reshape(g_values(2, :), size(A, 1), size(A, 2));

% Color the 2D area where both constraints are satisfied (g1 <= 0 and g2 <= 0)
satisfied = ((g1_values <= 0) & (g2_values <= 0)) - 0.5;
figure;
contourf(A, E, satisfied, [0 0], LineWidth = 2);
xlabel('Semi-major axis (m)')
ylabel('Eccentricity')
legend('$g = 0$', Interpreter = "latex")
grid on;
savefig('feasible_region.png', [3 2])

fprintf('Feasible region plot saved.\n')

% Set back the number of satellites
settings.num_sats = original_sats;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SIMPLIFIED PROBLEM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create a simplified optimization problem, where just the inclination and RAAN are optimized, while the other variables are fixed to their initial values
fprintf('=============== SIMPLIFIED PROBLEM ===============\n')

% Temporarily consider only one satellite
original_sats = settings.num_sats;
settings.num_sats = 1;

f1 = constellation_obj_fun(settings);
f_simplified = @(x) f1([y0(1:2); x(1); x(2); y0(5:6)]);

% Create a meshgrid of inclination and RAAN values
n = 80;
inc_domain = linspace(lb(3), ub(3), n);
raan_domain = linspace(lb(4), ub(4), n);
[INC, RAAN] = meshgrid(inc_domain, raan_domain);

cost_values = zeros(size(INC));

cached_path = get_cache_path('simplified_cost_values');

if exist(cached_path, 'file')
    fprintf('Loading cached cost values from %s...\n', cached_path)
    load(cached_path, 'cost_values')
else
    fprintf('Evaluating cost function for the simplified problem...\n')

    parfor i = 1:n

        for j = 1:n
            cost_values(i, j) = f_simplified([INC(i, j); RAAN(i, j)]);
        end

    end

    save(cached_path, 'cost_values')
    fprintf('Cost values computed and saved to cache.\n')
end

figure;
surfc(inc_domain, raan_domain, cost_values, EdgeColor = 'none')
xlabel('Inclination (rad)')
ylabel('RAAN (rad)')
zlabel('Cost')
grid on;
view(130, 45)
savefig('simplified_cost_surface.png', [3 2])

% Also make an isoline plot
figure;
contourf(inc_domain, raan_domain, cost_values, 10, LineWidth = 1)
xlabel('Inclination (rad)')
ylabel('RAAN (rad)')
colorbar
grid on;
savefig('simplified_cost_contour.png', [3 2])

% Simplified problem local optimization

% Pick random points in the domain and perform a local optimization (SQP)
rng default % Get reproducible results
n = 5;
points = (rand(2, n) .* (ub(3:4) - lb(3:4)) + lb(3:4))';
local_minima = zeros(n, 2); % Store the local minima and their costs
local_minima_costs = zeros(n, 1);

options = optimoptions('fmincon', Display = 'iter', UseParallel = true, Algorithm = 'sqp', FiniteDifferenceStepSize = 0.1, FiniteDifferenceType = 'central');

for i = 1:size(points, 1)
    x0 = points(i, :);
    x_opt = fmincon(f_simplified, x0, [], [], [], [], lb(3:4), ub(3:4), [], options);
    local_minima(i, :) = x_opt;
    local_minima_costs(i) = f_simplified(x_opt);
end

% Plot the local minima on the cost surface
figure;
surfc(inc_domain, raan_domain, cost_values, EdgeColor = 'none')
hold on;
plot3(local_minima(:, 1), local_minima(:, 2), local_minima_costs, 'ro', MarkerSize = 10, LineWidth = 2)
xlabel('Inclination (rad)')
ylabel('RAAN (rad)')
zlabel('Cost')
grid on;
view(130, 45)
savefig('simplified_cost_surface_local.png', [3 2])

% And on the contour plot
figure;
contourf(inc_domain, raan_domain, cost_values, 10, LineWidth = 1)
hold on;
plot(local_minima(:, 1), local_minima(:, 2), 'ro', MarkerSize = 10, LineWidth = 2)
xlabel('Inclination (rad)')
ylabel('RAAN (rad)')
colorbar
grid on;
savefig('simplified_cost_contour_local.png', [3 2])

% Simplified problem optimization

options = optimoptions('particleswarm', Display = 'iter', SwarmSize = 300, UseParallel = true);
[x_opt, fval] = particleswarm(f_simplified, 2, [lb(3); lb(4)], [ub(3); ub(4)], options);

fprintf('Optimal solution found: inclination = %.4f rad, RAAN = %.4f rad with cost = %.6f\n', x_opt(1), x_opt(2), fval)

% plot the optimal point on the cost surface
figure;
surfc(inc_domain, raan_domain, cost_values, EdgeColor = 'none')
hold on;
plot3(x_opt(1), x_opt(2), fval, 'ro', MarkerSize = 10, LineWidth = 2)
xlabel('Inclination (rad)')
ylabel('RAAN (rad)')
zlabel('Cost')
grid on;
view(130, 45)
savefig('simplified_cost_surface_opt.png', [3 2])

% plot the optimal point on the 2D contour as well
figure;
contourf(inc_domain, raan_domain, cost_values, 10, LineWidth = 1)
hold on;
plot(x_opt(1), x_opt(2), 'ro', MarkerSize = 10, LineWidth = 2)
xlabel('Inclination (rad)')
ylabel('RAAN (rad)')
colorbar
grid on;
savefig('simplified_cost_contour_opt.png', [3 2])

% Propagate and plot the solution
[opt_t, opt_track] = propagate_constellation(kep2eci([y0(1:2); x_opt(1); x_opt(2); y0(5:6)], constants.Earth.mu), settings);
plot_constellation_tracks(opt_t, opt_track, settings);
savefig('simplified_constellation_track.png', [6 4])

% Set back the number of satellites
settings.num_sats = original_sats;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SIMULATED ANNEALING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('=============== SIMULATED ANNEALING ==============\n')

penalty_order = 10;
f_constrained = apply_penalty(f, g, penalty_order);

% Simulated annealing options
sa_options.max_iters = 3000;
sa_options.max_no_improvement_iters = 500;
sa_options.fun_tolerance_ratio = 1e-4;
sa_options.debug = true;

% Run parallel optimizations and pick the best one
n_parallel = 12;
x_opt_parallel = zeros(length(y0) * settings.num_sats, n_parallel);
fval_parallel = zeros(n_parallel, 1);
best_evaluations_parallel = zeros(sa_options.max_iters, n_parallel);

y0_sa = zeros(length(y0) * settings.num_sats, 1);
temperature_sa = zeros(n_parallel, 1);
alpha_sa = zeros(n_parallel, 1);

cached_path = get_cache_path('simulated_annealing_results');

if exist(cached_path, 'file')
    fprintf('Loading cached simulated annealing results from %s...\n', cached_path)
    load(cached_path, 'y0_sa', 'temperature_sa', 'alpha_sa', 'x_opt_parallel', 'fval_parallel', 'best_evaluations_parallel')
else
    fprintf('Running simulated annealing optimizations...\n')

    min_temp = 1e2;
    max_temp = 1e5;
    min_alpha = 0.99;
    max_alpha = 0.999;

    % Choose random initial temperatures and cooling rates for each optimization
    for i = 1:n_parallel
        rng(i) % Set a different seed for each optimization for reproducibility
        y0_sa(:, i) = (rand(length(y0) * settings.num_sats, 1) .* (ub - lb) + lb);
        temperature_sa(i) = 10 .^ (rand() * (log10(max_temp) - log10(min_temp)) + log10(min_temp));
        alpha_sa(i) = rand() * (max_alpha - min_alpha) + min_alpha;

        fprintf('Optimization %d: initial temperature = %.2e, alpha = %.4f\n', i, temperature_sa(i), alpha_sa(i))
    end

    parfor i = 1:n_parallel
        fprintf('Starting optimization %d/%d...\n', i, n_parallel)

        sa_run_options = sa_options;
        sa_run_options.initial_temperature = temperature_sa(i);
        sa_run_options.alpha = alpha_sa(i);

        [x_opt_temp, fval_temp, best_evaluations_temp] = sa(f_constrained, y0_sa(:, i), lb, ub, sa_run_options);
        x_opt_parallel(:, i) = x_opt_temp;
        fval_parallel(i) = fval_temp;
        best_evaluations_parallel(:, i) = best_evaluations_temp;

        fprintf('Optimization %d completed with cost %.6f.\n', i, fval_temp)
    end

    save(cached_path, 'y0_sa', 'temperature_sa', 'alpha_sa', 'x_opt_parallel', 'fval_parallel', 'best_evaluations_parallel')
    fprintf('Simulated annealing optimizations completed and results saved to cache.\n')
end

% Pick the best solution among the parallel runs
[best_fval, best_idx] = min(fval_parallel);
best_x_opt = x_opt_parallel(:, best_idx);
fprintf('Best optimization run: %d with cost %.6f\n', best_idx, best_fval)

% Plot the best evaluations per iteration for each optimization
figure;

for i = 1:n_parallel
    plot(best_evaluations_parallel(:, i), LineWidth = 2)
    hold on
end

xlabel('Iteration')
ylabel('Best Cost')
grid on
ylim([best_fval, best_fval * 1.05])
savefig('optimization_convergence.png', [3 2])

% Plot the constellation track for the best solution
[opt_t, opt_track] = propagate_constellation(kep2eci(reshape(best_x_opt, [], settings.num_sats), constants.Earth.mu), settings);
plot_constellation_tracks(opt_t, opt_track, settings);
savefig('optimized_constellation_track.png', [6 4])
