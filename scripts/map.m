% Plot Switzerland using MATLAB Mapping Toolbox.

% Close and clear all
clc; clear; close all;

% Import necessary libraries
addpath(genpath('./lib'))

settings = config();

% Plot the country and the points
figure
newmap()
geoplot(settings.country)
hold on
geoplot(settings.geo_points, 'bo')
savefig("map.png", [4 3])
