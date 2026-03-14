function M = rot_z(theta)
    % rot_z: calculates the rotation matrix for a rotation about the z-axis.
    %
    % Inputs:
    %   theta: the angle of rotation in radians
    %
    % Output:
    %   M: the 3x3 rotation matrix

    M = [cos(theta) -sin(theta) 0;
         sin(theta) cos(theta) 0;
         0 0 1];
end
