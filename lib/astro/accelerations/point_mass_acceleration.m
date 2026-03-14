function acceleration = point_mass_acceleration(position, mu)
    % point_mass_acceleration: calculates the acceleration of a point mass under the influence of a central body.
    %
    % Inputs:
    %   position: a 3x1 vector containing the position of the point
    %   mu: the gravitational parameter of the central body
    %
    % Output:
    %   acceleration: a 3x1 vector containing the acceleration of the point mass

    r = norm(position);

    acceleration = -mu / r ^ 3 * position;
end
