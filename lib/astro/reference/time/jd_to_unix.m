function unix = jd_to_unix(jd)
    % jd_to_unix: converts Julian Date to Unix time.
    %
    % Inputs:
    %   jd: a scalar value representing the Julian Date
    %
    % Output:
    %   unix: a scalar value representing the Unix time in seconds since January 1, 1970

    unix = (jd - 2440587.5) * constants.JulianDay;
end
