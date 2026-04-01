function r_eci = geo2eci(r_geo, unix)
    % geo2eci: converts geographic coordinates to ECI coordinates.
    %
    %  Inputs:
    %   r_geo: geographic coordinates in the form of a 3x1 vector
    %       [latitude, longitude, radius]'
    %   unix: Unix timestamp (seconds since January 1, 1970)
    %
    %  Outputs:
    %   r_eci: a 3x1 vector containing the ECI coordinates
    %       [x, y, z]'

    r_eci = ecef2eci(geo2ecef(r_geo), unix);

end
