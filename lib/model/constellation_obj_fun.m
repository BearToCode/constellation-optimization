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
    function [score, points_last_visited_time] = compute_coverage_score(t, y, points_last_visited_time)
        sat_states = reshape(y, 6, settings.num_sats);
        points_covered = zeros(numel(settings.points), 1);

        for idx = 1:settings.num_sats
            sat_state = sat_states(:, idx);
            sat_pos_eci = sat_state(1:3);
            sat_pos_ecef = eci2ecef(sat_pos_eci, t);
            sat_pos_geo = ecef2geo(sat_pos_ecef);

            max_distance = max_distance_to_sat(sat_pos_geo, settings.min_elevation);

            indices = rangesearch(settings.kdtree, sat_pos_ecef', max_distance);
            indices = cell2mat(indices);
            % convert indices to logical array
            sat_points_covered = false(numel(settings.points), 1);
            sat_points_covered(indices) = true;

            points_covered = sat_points_covered | points_covered;
        end

        % For each point covered, we add min(settings.revisit_time, t - points_last_visited_time(point)) to the score
        score = 0;

        for i = 1:numel(settings.points)

            if points_covered(i)
                time_since_last_visit = t - points_last_visited_time(i);
                score = score + min(settings.revisit_time, time_since_last_visit);
                points_last_visited_time(i) = t;
            end

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
        [t, y] = propagate_constellation(y0, settings);

        points_last_visited_time = -Inf(numel(settings.points), 1);
        score = 0;

        for i = 1:length(t)
            [instant_score, points_last_visited_time] = compute_coverage_score(t(i), y(i, :)', points_last_visited_time);
            score = score + instant_score;
        end

        max_score = (settings.tf - settings.ti + settings.revisit_time) * numel(settings.geo_points);
        cost = max_score - score; % We want to maximize the score, so we minimize the negative of it
    end

    f = @impl;
end
