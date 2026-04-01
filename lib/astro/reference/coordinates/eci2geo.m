function r_geo = eci2geo(r_eci, unix)
    % eci2geo: converts ECI coordinates to geographic coordinates.
    %
    %  Inputs:
    %   r_eci: ECI coordinates [x, y, z]'
    %   unix: Unix timestamp (seconds since January 1, 1970)
    %
    %  Outputs:
    %   r_geo: a 3x1 vector containing the geographic coordinates
    %       [latitude, longitude, radius]'

    r_geo = ecef2geo(eci2ecef(r_eci, unix), unix);
end
