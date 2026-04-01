function r_ecef = geo2ecef(r_geo)
    % geo2ecef: converts geographic coordinates to ECEF coordinates.
    %
    %  Inputs:
    %   r_geo: geographic coordinates in the form of a 3x1 vector
    %       [latitude, longitude, radius]'
    %
    %  Outputs:
    %   r_ecef: a 3x1 vector containing the ECEF coordinates
    %       [x, y, z]'

    if size(r_geo, 2) > 1
        r_ecef = arrayfun(@(i) geo2ecef(r_geo(:, i)), 1:size(r_geo, 2), UniformOutput = false);
        r_ecef = cell2mat(r_ecef);
        return
    end

    lat = r_geo(1);
    lng = r_geo(2);
    r = r_geo(3);

    r_ecef = [r * cos(lat) * cos(lng); r * cos(lat) * sin(lng); r * sin(lat)];
end
