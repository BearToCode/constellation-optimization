function is_visible = point_is_visible(r_s, r_p, min_elevation)
    % point_is_visible: determines if a point on Earth is visible from a satellite given a minimum elevation angle.
    %
    %  Inputs:
    %   r_s: a 3x1 vector containing the satellite position in ECEF coordinates
    %   r_p: a 3x1 vector containing the point position in ECEF coordinates
    %   min_elevation: the minimum elevation angle in radians
    %
    %  Output:
    %   is_visible: a boolean indicating whether the point is visible from the satellite

    u_p = r_p / norm(r_p);

    r_ps = r_s - r_p;
    u_ps = r_ps / norm(r_ps);

    elevation = pi / 2 - acos(dot(u_ps, u_p));

    is_visible = elevation >= min_elevation;
end
