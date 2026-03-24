% Close and clear all
clc; clear; close all;

% Import necessary libraries
addpath(genpath('lib'))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TIME SETTINGS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('=============== TIME SETTINGS ===============\n')

ti_jd = 2461123.18064; % Initial time in Julian Date
simulation_time = 7 * 3600; % Simulation time [s]

settings.ti = jd_to_unix(ti_jd); % Initial time [s]
settings.tf = settings.ti + simulation_time; % Final time [s]

[ti_year, ti_month, ti_day, ti_hour, ti_minute, ti_second] = jd_to_calendar(ti_jd);
[tf_year, tf_month, tf_day, tf_hour, tf_minute, tf_second] = jd_to_calendar(unix_to_jd(settings.tf));

fprintf('Initial time: \t%d-%02d-%02d %02d:%02d:%02d\n', ...
    ti_year, ti_month, ti_day, ti_hour, ti_minute, ti_second ...
);
fprintf('Final time:   \t%d-%02d-%02d %02d:%02d:%02d\n', ...
    tf_year, tf_month, tf_day, tf_hour, tf_minute, tf_second ...
);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% S/C SETTINGS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('=============== S/C SETTINGS ===============\n')

settings.num_sats = 3; % Number of satellites of the constellation
settings.max_elevation = 30; % Minimum elevation angle for coverage [deg]

fprintf('Number of satellites: \t%d\n', settings.num_sats)
fprintf('Minimum elevation: \t%.2f deg\n', settings.max_elevation)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WORLD SETTINGS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('=============== WORLD SETTINGS ===============\n')

settings.country = "Switzerland"; % Country to be covered by the constellation.
settings.sample_points = 5e5; % Number of sample points to generate on Earth.

% Extract country geometry from shapefile
countries = readgeotable("../data/ne_50m_admin_0_countries/ne_50m_admin_0_countries.shp");
country = geocode(settings.country, countries);
country_shape = country.Shape;
country_area = area(country_shape);

% Generate sample points
unit_points = fibonacci_sphere(settings.sample_points);

% Convert to spherical coordinates
[az, el] = cart2sph(unit_points(1, :), unit_points(2, :), unit_points(3, :));
geo_points = geopointshape(rad2deg(el), rad2deg(az));

% Filter points inside the country
inside_geo_points = geo_points(isinterior(country_shape, geo_points));
area_per_point = country_area / numel(inside_geo_points);

fprintf('Country: \t\t%s\n', settings.country)
fprintf("Country area: \t\t%.2f km² \n", country_area / 1e6)
fprintf("Points inside country: \t%d\n", numel(inside_geo_points))
fprintf("Area per point: \t%.2f km²\n", area_per_point / 1e6)

settings.points = inside_geo_points; % Points to be covered by the constellation

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBJECTIVE FUNCTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function f = get_objective_function(settings)

    function J = objective_function(t, x)
        sat_states = reshape(x, 6, settings.num_sats);
        points_covered = zeros(numel(settings.points), 1);

        for idx = 1:settings.num_sats
            sat_state = sat_states(:, idx);
            sat_pos = sat_state(1:3);

            sat_points_covered = settings.points;

            % TODO: compute coverage
        end

    end

end
