% Close and clear all
clc; clear; close all;

% Import necessary libraries
addpath(genpath('lib'))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TIME SETTINGS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('================== TIME SETTINGS =================\n')

ti_jd = 2461123.18064; % Initial time in Julian Date
simulation_time = 7 * 3600; % Simulation time [s]

settings.ti = jd_to_unix(ti_jd); % Initial time [s]
settings.tf = settings.ti + simulation_time; % Final time [s]

[ti_year, ti_month, ti_day, ti_hour, ti_minute, ti_second] = jd_to_calendar(ti_jd);
[tf_year, tf_month, tf_day, tf_hour, tf_minute, tf_second] = jd_to_calendar(unix_to_jd(settings.tf));

fprintf('Initial time: \t\t%d-%02d-%02d %02d:%02d:%02d\n', ...
    ti_year, ti_month, ti_day, ti_hour, ti_minute, ti_second ...
);
fprintf('Final time:   \t\t%d-%02d-%02d %02d:%02d:%02d\n', ...
    tf_year, tf_month, tf_day, tf_hour, tf_minute, tf_second ...
);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% S/C SETTINGS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('================== S/C SETTINGS ==================\n')

settings.num_sats = 3; % Number of satellites of the constellation
settings.min_elevation = deg2rad(30); % Minimum elevation angle for coverage [rad]

fprintf('Number of satellites: \t%d\n', settings.num_sats)
fprintf('Minimum elevation: \t%.2f deg\n', rad2deg(settings.min_elevation))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WORLD SETTINGS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('================= WORLD SETTINGS =================\n')

settings.country = "Switzerland"; % Country to be covered by the constellation.
settings.sample_points = 2e5; % Number of sample points to generate on Earth.

% Extract country geometry from shapefile
countries = readgeotable("./data/ne_50m_admin_0_countries/ne_50m_admin_0_countries.shp");
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
% INTEGRATION SETTINGS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('============== INTEGRATION SETTINGS ==============\n')

settings.integrator = @ode78;
settings.relative_tolerance = 1e-6;
settings.absolute_tolerance = 1e-8;

fprintf('Integrator: \t\t%s\n', func2str(settings.integrator))
fprintf('Relative tolerance: \t%.2e\n', settings.relative_tolerance)
fprintf('Absolute tolerance: \t%.2e\n', settings.absolute_tolerance)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBJECTIVE FUNCTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

f = get_objective_function(settings);

initial_state = kep_to_car([6860e3, 0.00054, deg2rad(97.5643), deg2rad(182.719), deg2rad(275.0914), deg2rad(85.03242)]', constants.Earth.mu);

y0 = [initial_state; initial_state; initial_state];
cost = f(y0);

function f = get_objective_function(settings)

    function score = compute_coverage_score(t, y)
        sat_states = reshape(y, 6, settings.num_sats);
        points_covered = zeros(numel(settings.points), 1);

        points = settings.points;
        min_elevation = settings.min_elevation;

        for idx = 1:settings.num_sats
            sat_state = sat_states(:, idx);
            sat_pos = sat_state(1:3);

            sat_points_covered = zeros(numel(points), 1);

            for p = 1:numel(points)
                point_car = cor_to_car([deg2rad(points(p).Latitude), ...
                                            deg2rad(points(p).Longitude), ...
                                            constants.Earth.r]', t);
                sat_points_covered(p) = point_is_visible(sat_pos, point_car, min_elevation);
            end

            points_covered = sat_points_covered | points_covered;
        end

        score = sum(points_covered);

    end

    % EOM for a single satellite
    f_sat = eom(@(t, x) ...
        point_mass_acceleration(x(1:3), constants.Earth.mu) + ...
        j2_acceleration(x(1:3), constants.Earth.mu, constants.Earth.r, constants.Earth.j2) ...
    );

    % EOM for the constellation.
    % The state y has shape (6 * num_sats, 1) and contains the Cartesian state of each satellite
    function y_dot = constellation_eom(t, y)
        y_dot = zeros(size(y));

        for idx = 1:settings.num_sats
            indices = (idx - 1) * 6 + (1:6);
            y_dot(indices) = f_sat(t, y(indices));
        end

    end

    function cost = objective_function(y0)
        % Integrate the constellation EOM
        [t, y] = settings.integrator(@constellation_eom, ...
            [settings.ti, settings.tf], ...
            y0, ...
            odeset(RelTol = settings.relative_tolerance, AbsTol = settings.absolute_tolerance) ...
        );

        coverage_over_time = arrayfun(@(i) compute_coverage_score(t(i), y(i, :)'), 1:length(t));
        stairs(t, coverage_over_time);

        max_coverage = (settings.tf - settings.ti) * numel(settings.sample_points);
        % Integrate the coverage over time and subtract from the maximum possible coverage to get the cost
        cost = max_coverage - trapz(t, coverage_over_time);
    end

    f = @objective_function;
end
