% Close and clear all
clc; clear; close all;

% Import necessary libraries
addpath(genpath('lib'))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONFIGURATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Define configuration

settings = config();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBJECTIVE FUNCTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Objective function

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

%% Constraints

fprintf('================== CONSTRAINTS ==================\n')

settings.min_altitude = 200e3; % Minimum altitude [m]
settings.max_altitude = 800e3; % Maximum altitude [m]

fprintf('Minimum altitude: \t%.2f km\n', settings.min_altitude / 1e3)
fprintf('Maximum altitude: \t%.2f km\n', settings.max_altitude / 1e3)

g = constellation_constr(settings);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INITIAL ANALYSIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initial analysis

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

for i = 1:length(y0)
    original_value = y0(i);

    domain = domains(i, :);
    cost = costs(i, :);
    constraint1 = constraints1(i, :);
    constraint2 = constraints2(i, :);

    figure;
    plot(kep_values(domains(i, :), i), costs(i, :), 'LineWidth', 2);
    xlabel(kep_label(i), Interpreter = "latex")
    ylabel('Cost')
    % Plot constraints on a different y-axis
    yyaxis right;
    plot(kep_values(domains(i, :), i), constraint1, 'LineWidth', 2);
    hold on;
    plot(kep_values(domains(i, :), i), constraint2, 'LineWidth', 2);
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

%% Simplified problem definition

% Create a simplified optimization problem, where just the inclination and RAAN are optimized, while the other variables are fixed to their initial values
fprintf('=============== SIMPLIFIED PROBLEM ===============\n')

% Temporarily consider only one satellite
original_sats = settings.num_sats;
settings.num_sats = 1;

f1 = constellation_obj_fun(settings);
f_simplified = @(x) f1([y0(1:2); x(1); y0(4); x(2); y0(6)]);

%% Simplified problem analysis

% Create a meshgrid of inclination and RAAN values
n = 80;
inc_domain = linspace(lb(3), ub(3), n);
raan_domain = linspace(lb(4), ub(4), n);
[INC, RAAN] = meshgrid(inc_domain, raan_domain);

cost_values = zeros(size(INC));

fprintf('Evaluating cost function for the simplified problem...\n')

parfor i = 1:n

    for j = 1:n
        cost_values(i, j) = f_simplified([INC(i, j); RAAN(i, j)]);
    end

end

figure;
surfc(inc_domain, raan_domain, cost_values', 'EdgeColor', 'none')
xlabel('Inclination (rad)')
ylabel('RAAN (rad)')
zlabel('Cost')
grid on;
view(130, 45)
savefig('simplified_cost_surface.png', [3 2])

% Also make an isoline plot
figure;
contourf(inc_domain, raan_domain, cost_values', 10, LineWidth = 1)
xlabel('Inclination (rad)')
ylabel('RAAN (rad)')
colorbar
grid on;
savefig('simplified_cost_contour.png', [3 2])

%% Simplified problem optimization

options = optimoptions('particleswarm', Display = 'iter', UseParallel = true);
[x_opt, fval] = particleswarm(f_simplified, 2, [lb(3); lb(4)], [ub(3); ub(4)], options);

% plot the optimal point on the cost surface
figure;
surfc(inc_domain, raan_domain, cost_values', 'EdgeColor', 'none')
hold on;
plot3(x_opt(1), x_opt(2), fval, 'ro', 'MarkerSize', 10, 'LineWidth', 2)
xlabel('Inclination (rad)')
ylabel('RAAN (rad)')
zlabel('Cost')
grid on;
view(130, 45)
savefig('simplified_cost_surface_opt.png', [3 2])

% plot the optimal point on the 2D contour as well
figure;
contourf(inc_domain, raan_domain, cost_values', 10, LineWidth = 1)
hold on;
plot(x_opt(1), x_opt(2), 'ro', 'MarkerSize', 10, 'LineWidth', 2)
xlabel('Inclination (rad)')
ylabel('RAAN (rad)')
colorbar
grid on;
savefig('simplified_cost_contour_opt.png', [3 2])

% Set back the number of satellites
settings.num_sats = original_sats;
