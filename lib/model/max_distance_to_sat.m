function d = max_distance_to_sat(r_sat_geo, min_elevation)
    % max_distance_to_sat: calculates the maximum distance from a satellite to a point on Earth, given the satellite's geodetic coordinates and the minimum elevation angle.
    %
    %  Inputs:
    %   - r_sat_geo: a 3x1 vector containing the satellite's geodetic coordinates [latitude; longitude; altitude]
    %   - min_elevation: the minimum elevation angle for coverage [rad]
    %
    %  Output:
    %   - d: the maximum distance from the satellite to a point on Earth that is still covered by the satellite, given the minimum elevation angle

    r = geodetic_radius(r_sat_geo(1:2));
    h = r_sat_geo(3) - r;
    d = sqrt(r ^ 2 + (r + h) ^ 2 - 2 * r * (r + h) * sin(min_elevation + asin(r / (r + h) * cos(min_elevation))));
end
