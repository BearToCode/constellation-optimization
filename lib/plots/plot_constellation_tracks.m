function fig = plot_constellation_tracks(t, y, settings)
    fig = figure;
    worldmap('World');
    load coastlines;
    plotm(coastlat, coastlon, 'k', LineWidth = 2);

    for idx = 1:settings.num_sats
        indices = (idx - 1) * 6 + (1:6);
        x_cor = eci2geo(y(:, indices)', t);
        plotm(rad2deg(x_cor(1, :)), rad2deg(x_cor(2, :)), LineWidth = 2);
    end

end
