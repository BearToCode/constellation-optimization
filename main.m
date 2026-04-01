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
y0 = [6860e3, 0.00054, deg2rad(97.5643), deg2rad(182.719), deg2rad(275.0914), deg2rad(85.03242)]';

tic
initial_cost = f(repmat(y0, settings.num_sats, 1));
dt = toc;

fprintf('Initial cost: \t\t%d\n', initial_cost)
fprintf('Computation time: \t%.2f s\n', dt)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BOUNDEDNESS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('================== BOUNDEDNESS ===================\n')

% Temporarily consider only one satellite
original_sats = settings.num_sats;
settings.num_sats = 1;

n = 100;
f1 = constellation_obj_fun(settings);
domains = zeros(6, n);
costs = zeros(6, n);

% For each variable, try changing it to its lower and upper bound and plot the cost function value
parfor i = 1:length(y0)
    y0_temp = y0;

    fi = @(v) f1([y0_temp(1:i - 1); v; y0_temp(i + 1:end)]); %#ok<PFBNS>

    domain = linspace(lb(i), ub(i), n);
    cost = arrayfun(fi, domain);

    domains(i, :) = domain;
    costs(i, :) = cost;
end

for i = 1:length(y0)
    original_value = y0(i);

    domain = domains(i, :);
    cost = costs(i, :);

    figure;
    plot(kep_values(domains(i, :), i), costs(i, :), 'LineWidth', 2);
    xlabel(kep_label(i), Interpreter = "latex")
    ylabel('Cost')
    grid on;
    savefig(sprintf('boundedness_%d.png', i), [3 2]),
end

% Set back the number of satellites
settings.num_sats = original_sats;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OPTIMIZATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
