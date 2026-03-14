function car = kep_to_car(kep, mu)
    % kep_to_car: converts Keplerian orbital elements to Cartesian state vectors.
    %
    %  Inputs:
    %   kep: a 6x1 vector containing the Keplerian orbital elements
    %       [a e i RAAN arg_perigee true_anomaly]'
    %   mu: the gravitational parameter of the central body
    %
    % Output:
    %   car: a 6x1 vector containing the Cartesian state (position and velocity)

    a = kep(1);
    e = kep(2);
    i = kep(3);
    O = kep(4);
    o = kep(5);
    t = kep(6);

    R_O = rot_z(-O);
    R_i = rot_x(-i);
    R_o = rot_z(-o);

    p = a * (1 - e ^ 2);
    r_norm = p / (1 + e * cos(t));

    r_pf = [r_norm * cos(t); r_norm * sin(t); 0];
    v_pf = [-sqrt(mu / p) * sin(t); sqrt(mu / p) * (e + cos(t)); 0];

    T_eci_pf = R_o * R_i * R_O;
    T_pf_eci = T_eci_pf';

    r = T_pf_eci * r_pf;
    v = T_pf_eci * v_pf;

    car = [r; v];
end
