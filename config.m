function settings = config()

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TIME SETTINGS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fprintf('================== TIME SETTINGS =================\n')

    ti_jd = 2461123.18064; % Initial time in Julian Date
    simulation_time = 10 * 3600; % Simulation time [s]

    settings.ti = jd2unix(ti_jd); % Initial time [s]
    settings.tf = settings.ti + simulation_time; % Final time [s]

    [ti_year, ti_month, ti_day, ti_hour, ti_minute, ti_second] = jd2calendar(ti_jd);
    [tf_year, tf_month, tf_day, tf_hour, tf_minute, tf_second] = jd2calendar(unix2jd(settings.tf));

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
    settings.revisit_time = 3600; % Maximum allowable gap between coverage events [s]
    settings.revisit_penalty_weight = 1.0; % Weight of the revisit penalty vs. base coverage cost

    fprintf('Number of satellites: \t%d\n', settings.num_sats)
    fprintf('Minimum elevation: \t%.2f deg\n', rad2deg(settings.min_elevation))
    fprintf('Revisit time: \t\t%.2f h\n', settings.revisit_time / 3600)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % WORLD SETTINGS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fprintf('================= WORLD SETTINGS =================\n')

    settings.targets = ["Italy", "South Africa"]; % Country to be covered by the constellation.
    settings.nb_ground_points = 3e5; % Number of sample points to generate on Earth.

    % Extract country geometry from shapefile
    countries = readgeotable("./data/ne_50m_admin_0_countries/ne_50m_admin_0_countries.shp");
    settings.countries = arrayfun(@(country) geocode(country, countries), settings.targets, UniformOutput = false);
    settings.countries_shape = cellfun(@(c) c.Shape, settings.countries, UniformOutput = false);
    settings.countries_area = cellfun(@(c) area(c.Shape), settings.countries, UniformOutput = false);

    % Generate sample points
    ground_points = fibonacci_sphere(settings.nb_ground_points);

    % Convert to spherical coordinates
    [az, el] = cart2sph(ground_points(1, :), ground_points(2, :), ground_points(3, :));
    geo_points = geopointshape(rad2deg(el), rad2deg(az));

    % Filter points inside the country
    inside_geo_points_logical = false(size(geo_points, 1), 1);

    for i = 1:numel(settings.countries_shape)
        inside_geo_points_logical = inside_geo_points_logical | isinterior(settings.countries_shape{i}, geo_points);
    end

    inside_geo_points = geo_points(inside_geo_points_logical);

    for i = 1:numel(settings.countries)
        fprintf('Country: \t\t%s\n', settings.targets{i})
        fprintf("Country area: \t\t%.2f km² \n", settings.countries_area{i} / 1e6)
    end

    total_area = sum(cell2mat(settings.countries_area));
    area_per_point = total_area / sum(inside_geo_points_logical);

    fprintf("Points inside: \t%d\n", sum(inside_geo_points_logical))
    fprintf("Area per point: \t%.2f km²\n", area_per_point / 1e6)

    settings.geo_points = inside_geo_points;
    % Points to be used for coverage evaluation, converted to ECEF coordinates
    settings.points = arrayfun( ...
        @(p) geo2ecef([
                   deg2rad(inside_geo_points(p).Latitude);
                   deg2rad(inside_geo_points(p).Longitude);
                   geodetic_radius([
                     deg2rad(inside_geo_points(p).Latitude);
                     deg2rad(inside_geo_points(p).Longitude)
                     ])
    ]), 1:numel(inside_geo_points), UniformOutput = false);
    settings.points = cell2mat(settings.points);

    settings.kdtree = KDTreeSearcher(settings.points');

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

end
