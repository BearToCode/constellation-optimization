function r = geodetic_radius(coords)
    % geodetic_radius: calculates the geodetic radius from co-rotating spherical coordinates.
    %
    %  Inputs:
    %   coords: a 2x1 vector containing the co-rotating spherical coordinates
    %       [latitude, longitude]'
    %
    %  Output:
    %   r: the geodetic radius above the reference ellipsoid

    lat = coords(1);

    r = sqrt(constants.Earth.r_eq ^ 2 * cos(lat) ^ 2 + constants.Earth.r_p ^ 2 * sin(lat) ^ 2);
end
