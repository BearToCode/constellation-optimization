% Plot Switzerland using MATLAB Mapping Toolbox.

% Close and clear all
clc; clear; close all;

% Import necessary libraries
addpath(genpath('../lib'))

target_country = "Switzerland";

% Extract country geometry from shapefile
countries = readgeotable("../data/ne_50m_admin_0_countries/ne_50m_admin_0_countries.shp");
country = geocode(target_country, countries);
country_shape = country.Shape;
country_area = area(country_shape);

disp("Country area (sq km): " + num2str(country_area / 1e6))

% Generate sample points
unit_points = fibonacci_sphere(5e5);

% Convert to spherical coordinates
[az, el] = cart2sph(unit_points(1, :), unit_points(2, :), unit_points(3, :));
geo_points = geopointshape(rad2deg(el), rad2deg(az));

% Filter points inside the country
inside_geo_points = geo_points(isinterior(country_shape, geo_points));
area_per_point = country_area / numel(inside_geo_points);

disp("Number of points inside the country: " + num2str(numel(inside_geo_points)))
disp("Area per point (sq km): " + num2str(area_per_point / 1e6))

% Plot the country and the points
proj = projcrs(21781);

figure
newmap(proj)
geoplot(country)
hold on
geoplot(inside_geo_points, 'bo')
savefig("switzerland.png", [4 3])
