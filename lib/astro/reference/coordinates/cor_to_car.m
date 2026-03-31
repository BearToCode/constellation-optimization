function car = cor_to_car(cor, unix)
    % cor_to_car: converts co-rotating spherical coordinates to Cartesian coordinates.
    %
    %  Inputs:
    %   cor: Co-rotating coordinates [latitude, longitude, radius]'
    %   unix: Unix timestamp (seconds since January 1, 1970)
    %
    %  Outputs:
    %   car: a 3x1 vector containing the Cartesian coordinates
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
