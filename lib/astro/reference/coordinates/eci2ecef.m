function cor = eci2ecef(car, unix)
    % eci2ecef: converts ECI coordinates to ECEF coordinates.
    %
    %  Inputs:
    %   car: ECI coordinates [x, y, z]'
    %   unix: Unix timestamp (seconds since January 1, 1970)
    %
    %  Outputs:
    %   cor: a 3x1 vector containing the ECEF coordinates
    %       [x, y, z]'

    % If using matrices, use arrayfun to apply the conversion to each column of car and unix.
    if size(car, 2) > 1
        cor = arrayfun(@(i) eci2ecef(car(:, i), unix(i)), 1:size(car, 2), UniformOutput = false);
        cor = cell2mat(cor);
        return
    end

    theta = sidereal_rotation(unix);
    R_z = rot_z(-theta);
    r_eci = car(1:3);
    r_ecef = R_z * r_eci;

    r_norm = norm(r_ecef);
    r_xy = sqrt(r_ecef(1) ^ 2 + r_ecef(2) ^ 2);
    lng = atan2(r_ecef(2) / r_xy, r_ecef(1) / r_xy);
    lat = asin(r_ecef(3) / r_norm);

    cor = [lat, lng, r_norm]';
end
