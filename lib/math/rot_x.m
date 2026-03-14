function M = rot_x(theta)
    % rot_x: returns the rotation matrix for a rotation about the x-axis by an angle theta.
    %
    % Input:
    %   theta: the angle of rotation in radians
    %
    % Output:
    %   M: the 3x3 rotation matrix

    M = [1, 0, 0;
         0, cos(theta), -sin(theta);
         0, sin(theta), cos(theta)];
end
