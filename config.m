function settings = config()

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TIME SETTINGS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fprintf('================== TIME SETTINGS =================\n')

    ti_jd = 2461123.18064; % Initial time in Julian Date
    simulation_time = 7 * 3600; % Simulation time [s]

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

end
