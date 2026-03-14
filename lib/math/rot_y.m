function M = rot_y(theta)
    % rot_y: returns the rotation matrix for a rotation about the y-axis by an angle theta.
    %
    % Input:
    %   theta: the angle of rotation in radians
    %
    % Output:
    %   M: the 3x3 rotation matrix

    M = [cos(theta), 0, sin(theta);
         0, 1, 0;
         -sin(theta), 0, cos(theta)];
end
