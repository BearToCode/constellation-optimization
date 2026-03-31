function f = constellation_obj_fun(settings)
    % constellation_obj_fun: Returns the objective function for constellation optimization based on the provided settings.
    %
    % Parameters:
    %   settings: A struct containing the settings for the constellation optimization, including:
    %       - num_sats: Number of satellites in the constellation
    %       - min_elevation: Minimum elevation angle for coverage [rad]
    %       - points: A geopointshape containing the points to be covered by the constellation
    %
    % Returns:
    %   f: A function handle that takes the initial state of the constellation and returns the cost based on the coverage over time.

    % Nested function to compute the coverage score at a given time t and constellation state y
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
                point_car = ecef2eci([deg2rad(points(p).Latitude), ...
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

    % Implementation of the objective function
    % y0 is the initial state of the constellation, which has shape (6 * num_sats, 1) and contains the Cartesian state of each satellite
    function cost = impl(y0)
        % Convert the initial state to cartesian
        y0 = reshape(y0, 6, settings.num_sats);
        y0 = kep2eci(y0, constants.Earth.mu);
        y0 = reshape(y0, [], 1);

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

    f = @impl;
end
