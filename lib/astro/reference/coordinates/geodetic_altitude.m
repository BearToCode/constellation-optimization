function alt = geodetic_altitude(cor)
    % geodetic_altitude: calculates the geodetic altitude from co-rotating spherical coordinates.
    %
    %  Inputs:
    %   cor: a 3x1 vector containing the co-rotating spherical coordinates
    %       [latitude, longitude, radius]'
    %
    %  Output:
    %   alt: the geodetic altitude above the reference ellipsoid

    lat = cor(1);
    r = cor(3);

    alt = r - sqrt(constants.Earth.r_eq ^ 2 * cos(lat) ^ 2 + constants.Earth.r_p ^ 2 * sin(lat) ^ 2);
end
