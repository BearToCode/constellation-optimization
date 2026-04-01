function r_ecef = eci2ecef(r_eci, unix)
    % eci2ecef: converts ECI coordinates to ECEF coordinates.
    %
    %  Inputs:
    %   r_eci: ECI coordinates [x, y, z]'
    %   unix: Unix timestamp (seconds since January 1, 1970)
    %
    %  Outputs:
    %   r_ecef: a 3x1 vector containing the ECEF coordinates
    %       [x, y, z]'

    % If using matrices, use arrayfun to apply the conversion to each column of r_eci and unix.
    if size(r_eci, 2) > 1
        r_ecef = arrayfun(@(i) eci2ecef(r_eci(:, i), unix(i)), 1:size(r_eci, 2), UniformOutput = false);
        r_ecef = cell2mat(r_ecef);
        return
    end

    theta = sidereal_rotation(unix);
    R_z = rot_z(-theta);
    r_eci = r_eci(1:3);
    r_ecef = R_z * r_eci;
end
