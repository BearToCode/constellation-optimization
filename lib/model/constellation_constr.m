function g = constellation_constr(settings)
    % constellation_constr: Returns the constraint function for constellation optimization based on the provided settings.
    %
    % Parameters:
    %   settings: A struct containing the settings for the constellation optimization, including:
    %       - num_sats: Number of satellites in the constellation
    %       - h_min: Minimum altitude for the satellites [m]
    %       - h_max: Maximum altitude for the satellites [m]
    %
    % Returns:
    %   g: A function handle that takes the initial state of the constellation and returns the constraint values based on the altitude limits.

    function v = impl(y0)
        v = zeros(settings.num_sats * 2, 1);
        y0 = reshape(y0, 6, settings.num_sats);

        for idx = 1:settings.num_sats
            x_kep = y0(1:6, idx);
            a = x_kep(1);
            e = x_kep(2);
            h_min = a * (1 - e) - constants.Earth.r;
            h_max = a * (1 + e) - constants.Earth.r;

            indices = (1:2) + (idx - 1) * 2;
            v(indices) = [settings.min_altitude - h_min; h_max - settings.max_altitude];
        end

    end

    g = @impl;
end
