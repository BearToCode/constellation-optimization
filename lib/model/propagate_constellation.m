function [t, y] = propagate_constellation(y0, settings)
    % propagate_constellation: Propagate the constellation using a simple two-body model for each satellite
    % and compute the coverage score at each time step.
    %
    % Inputs:
    %   - y0: Initial state of the constellation, which has shape (6 * num_sats, 1) and contains the Cartesian state of each satellite
    %   - settings: A struct containing the settings for the simulation.
    %
    % Outputs:
    %   - t: Time vector of the simulation
    %   - y: State vector of the simulation

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

    % Integrate the constellation EOM
    [t, y] = settings.integrator(@constellation_eom, ...
        [settings.ti, settings.tf], ...
        reshape(y0, [], 1), ...
        odeset(RelTol = settings.relative_tolerance, AbsTol = settings.absolute_tolerance) ...
    );
end
