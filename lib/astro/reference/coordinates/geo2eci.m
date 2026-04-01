function car = geo2eci(cor, unix)
    % geo2eci: converts geographic coordinates to ECI coordinates.
    %
    %  Inputs:
    %   cor: geographic coordinates in the form of a 3x1 vector
    %       [latitude, longitude, radius]'
    %   unix: Unix timestamp (seconds since January 1, 1970)
    %
    %  Outputs:
    %   car: a 3x1 vector containing the ECI coordinates
    %       [x, y, z]'

    lat = cor(1);
    lng = cor(2);
    r = cor(3);

    theta = sidereal_rotation(unix);
    R_z = rot_z(theta);
    r_ecef = [r * cos(lat) * cos(lng); r * cos(lat) * sin(lng); r * sin(lat)];
    r_eci = R_z * r_ecef;

    car = r_eci;
end
