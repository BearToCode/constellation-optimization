function fig = plot_constellation_tracks(t, y, settings)
    % plot_constellation_tracks: plot the ground track of the satellites of the constellation, after
    % having propagated its initial states.
    %
    % Inputs:
    %   t: The vector of time instances the states refer to.
    %   y: Matrix containing the cartesian states of the satellites along its rows.
    %   settings: Settings of the simulation
    %
    % Output:
    %   The generated figure.

    fig = figure;
    worldmap('World');
    load coastlines; %#ok<LOAD>
    plotm(coastlat, coastlon, 'k', LineWidth = 2);
    % Plot country borders
    T = geotable2table(settings.country, ["Lat", "Lon"]);
    [lat, lon] = polyjoin(T.Lat, T.Lon);
    plotm(lat, lon, 'r', LineWidth = 2);

    for idx = 1:settings.num_sats
        indices = (idx - 1) * 6 + (1:6);
        x_cor = eci2geo(y(:, indices)', t);
        plotm(rad2deg(x_cor(1, :)), rad2deg(x_cor(2, :)), LineWidth = 2, LineStyle = '--');
    end

end
