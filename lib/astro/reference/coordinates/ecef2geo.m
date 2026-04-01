function r_geo = ecef2geo(r_ecef, unix)
    % ecef2geo: converts ECEF coordinates to geographic coordinates.
    %
    %  Inputs:
    %   r_ecef: ECEF coordinates [x, y, z]'
    %   unix: Unix timestamp (seconds since January 1, 1970)
    %
    %  Outputs:
    %   r_geo: a 3x1 vector containing the geographic coordinates
    %       [latitude, longitude, radius]'

    % If using matrices, use arrayfun to apply the conversion to each column of r_ecef and unix.
    if size(r_ecef, 2) > 1
        r_geo = arrayfun(@(i) ecef2geo(r_ecef(:, i), unix(i)), 1:size(r_ecef, 2), UniformOutput = false);
        r_geo = cell2mat(r_geo);
        return
    end

    r_norm = norm(r_ecef);
    r_xy = sqrt(r_ecef(1) ^ 2 + r_ecef(2) ^ 2);
    lng = atan2(r_ecef(2) / r_xy, r_ecef(1) / r_xy);
    lat = asin(r_ecef(3) / r_norm);

    r_geo = [lat, lng, r_norm]';
end
