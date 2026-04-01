% Propagate a whole constellation

% Close and clear all
clc; clear; close all;

% Import necessary libraries
addpath(genpath('../lib'))

settings = config();

y0 = [7126513.44232183, 0.000277379314357706, 0.888570586940683, 0.422335229587534, ...
          2.43199323527529, 3.39754329659587, 7086010.06583344, 0.00268399048917818, ...
          0.888082549539405, 6.17737120926006, 6.1214581230032, 1.29801393207423, ...
          7164153.29276969, 0.00486199573835419, 0.863112839082372, 0.907890886875557, 4.31234655475536, 3.97890053651586]';
y0 = reshape(y0, 6, settings.num_sats);

[t, y] = propagate_constellation(kep2eci(y0, constants.Earth.mu), settings);

plot_constellation_tracks(t, y, settings);
