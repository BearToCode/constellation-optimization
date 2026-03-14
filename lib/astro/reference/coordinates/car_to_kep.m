function kep = car_to_kep(car, mu)
    % car_to_kep: converts Cartesian state vectors to Keplerian orbital elements.
    %
    %  Inputs:
    %   car: a 6x1 vector containing the Cartesian state (position and velocity)
    %   mu: the gravitational parameter of the central body
    %
    % Output:
    %   kep: a 6x1 vector containing the Keplerian orbital elements
    %       [a e i RAAN arg_perigee true_anomaly]'

    r = car(1:3);
    v = car(4:6);

    r_norm = norm(r);
    v_norm = norm(v);

    a = (2 / r_norm - v_norm ^ 2 / mu) ^ (-1);
    h = cross(r, v);
    e = cross(v, h) / mu - r / r_norm;
    i = acos(h(3) / norm(h));

    % Node vector
    N = cross([0 0 1]', h) / norm(cross([0 0 1]', h));
    % RAAN
    O = (N(2) >= 0) * acos(N(1)) + (N(2) < 0) * (2 * pi - acos(N(1)));
    % Argument of perigee
    o = (e(3) >= 0) * acos(dot(N, e) / norm(e)) + (e(3) < 0) * (2 * pi - acos(dot(N, e) / norm(e)));

    v_r = dot(r, v) / r_norm;

    % True anomaly
    t = (v_r >= 0) * acos(dot(e, r) / (norm(e) * r_norm)) + (v_r < 0) * (2 * pi - acos(dot(e, r) / (norm(e) * r_norm)));

    kep = [a e i O o t]';
end
