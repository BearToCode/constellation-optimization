function r_eci = ecef2eci(r_ecef, unix)
    % ecef2eci: converts ECEF coordinates to ECI coordinates.
    %
    %  Inputs:
    %   r_ecef: ECEF coordinates [x, y, z]'
    %   unix: Unix timestamp (seconds since January 1, 1970)
    %
    %  Outputs:
    %   r_eci: a 3x1 vector containing the ECI coordinates
    %       [x, y, z]'

    % If using matrices, use arrayfun to apply the conversion to each column of r_ecef and unix.
    if size(r_ecef, 2) > 1
        r_eci = arrayfun(@(i) ecef2eci(r_ecef(:, i), unix(i)), 1:size(r_ecef, 2), UniformOutput = false);
        r_eci = cell2mat(r_eci);
        return
    end

    theta = sidereal_rotation(unix);
    R_z = rot_z(theta);
    r_eci = R_z' * r_ecef;
end
