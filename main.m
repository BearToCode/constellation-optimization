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
lb = repmat([6578e3, 0, deg2rad(48), 0, 0, 0]', settings.num_sats, 1);
ub = repmat([7178e3, 0.005, deg2rad(90), deg2rad(360), deg2rad(360), deg2rad(360)]', settings.num_sats, 1);

% Construct the objective function with the given settings
f = constellation_obj_fun(settings);

y0 = repmat([6860e3, 0.00054, deg2rad(97.5643), deg2rad(182.719), deg2rad(275.0914), deg2rad(85.03242)]', settings.num_sats, 1);

tic
initial_cost = f(y0);
dt = toc;

fprintf('Initial cost: \t\t%d\n', initial_cost)
fprintf('Computation time: \t%.2f s\n', dt)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OPTIMIZATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('================== OPTIMIZATION ==================\n')

% Use the genetic algorithm to optimize the constellation
options = optimoptions('ga', ...
    PopulationSize = 100, ...
    MaxGenerations = 50, ...
    Display = 'iter', ...
    UseParallel = true, ...
    FunctionTolerance = 1e-4, ...
    PlotFcn = @gaplotbestf ...
);
tic
[x_opt, fval] = ga(f, numel(y0), [], [], [], [], lb, ub, [], options);
dt = toc;

fprintf('Optimized cost: \t%d\n', fval)
fprintf('Computation time: \t%.2f s\n', dt)

% Propagate the optimized constellation and visualize the results
