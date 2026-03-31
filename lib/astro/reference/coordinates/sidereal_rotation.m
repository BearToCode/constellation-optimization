function rotation = sidereal_rotation(unix)
    % sidereal_rotation: computes the sidereal rotation of the Earth at a given Unix timestamp
    %
    %  Inputs:
    %   unix: Unix timestamp (seconds since January 1, 1970)
    %
    %  Outputs:
    %   rotation: sidereal rotation in radians

    jd = unix2jd(unix);
    d = jd - 2451545.0; % Days since J2000
    jd0 = floor(jd - 0.5) + 0.5; % Julian date at previous midnight
    d0 = jd0 - 2451545.0; % Days since J2000 at previous midnight
    h = (jd - jd0) * 24; % Hours since previous midnight
    t = d / 36525; % Centuries since J2000

    % Rotation in hour-angles
    rotation = 6.697375 + 0.065709824279 * d0 + 1.0027379 * h + 0.0000258 * t ^ 2;
    rotation = wrapTo2Pi(rotation * pi / 12); % Convert to radians and wrap to [0, 2*pi]
end
