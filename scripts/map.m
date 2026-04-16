% Plot Switzerland using MATLAB Mapping Toolbox.

% Close and clear all
clc; clear; close all;

% Import necessary libraries
addpath(genpath('./lib'))

settings = config();

T = geotable2table(settings.countries{1}, ["Lat", "Lon"]);
[country_lat, country_lon] = polyjoin(T.Lat, T.Lon);
[min_lat, max_lat] = bounds(country_lat);
[min_lon, max_lon] = bounds(country_lon);

% Plot the country and the points
figure
newmap()
geoplot(settings.countries{1})
hold on
geoplot(settings.geo_points, 'bo')
% Set the limits of the map to the bounds of the country
geolimits([min_lat - 1, max_lat + 1], [min_lon - 1, max_lon + 1])

savefig("map.png", [4 3])
