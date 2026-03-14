function acceleration = j2_acceleration(position, mu, R, J2)
    % j2_acceleration: calculates the acceleration of a point mass under the influence of a central body with a J2 perturbation.
    %
    % Inputs:
    %   position: a 3x1 vector containing the position of the point in the ECR frame.
    %             However, in this case, ECI yields the same results.
    %   mu: the gravitational parameter of the central body
    %   R: the equatorial radius of the central body
    %   J2: the second zonal harmonic coefficient of the central body
    %
    % Output:
    %   acceleration: a 3x1 vector containing the acceleration of the point mass

    r = norm(position);
    f =- (1.5 * J2 * mu * R ^ 2) / r ^ 5;

    acceleration = f * position .* [
                                    1 - (5 * position(3) ^ 2) / r ^ 2;
                                    1 - (5 * position(3) ^ 2) / r ^ 2;
                                    3 - (5 * position(3) ^ 2) / r ^ 2
                                    ];
end
