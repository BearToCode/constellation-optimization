% Close and clear all
clc; clear; close all;

% Import necessary libraries
addpath(genpath('lib'))

settings = config();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBJECTIVE FUNCTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('=============== OBJECTIVE FUNCTION ===============\n')

% semi-major axis, eccentricity, inclination, RAAN, argument of perigee, mean anomaly, true anomaly
lb = repmat([6578e3, 0, deg2rad(46), 0, 0, 0]', settings.num_sats, 1);
ub = repmat([7178e3, 0.025, deg2rad(180 - 46), deg2rad(360), deg2rad(360), deg2rad(360)]', settings.num_sats, 1);

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
settings.max_altitude = 2000e3; % Maximum altitude [m]

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
    savefig(sprintf('boundedness_%d.png', i), [3 2]),
end

fprintf('Boundedness plots saved.\n')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SIMPLIFIED PROBLEM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create a simplified optimization problem, where just the inclination and RAAN are optimized, while the other variables are fixed to their initial values
fprintf('=============== SIMPLIFIED PROBLEM ===============\n')

f_simplified = @(x) f([y0(1:2); x(1); y0(4); x(2); y0(6)]);

% Set back the number of satellites
settings.num_sats = original_sats;
