% Plot Switzerland using MATLAB Mapping Toolbox.

% Close and clear all
clc; clear; close all;

% Import necessary libraries
addpath(genpath('../lib'))

target_country = "Switzerland";
countries = readgeotable("../data/ne_50m_admin_0_countries/ne_50m_admin_0_countries.shp");
country = geocode(target_country, countries);

proj = projcrs(21781);

figure
newmap(proj)
geoplot(country)
