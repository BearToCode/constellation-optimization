function jd = unix2jd(unix_time)
    % unix2jd: converts a Unix timestamp to Julian Date.
    %
    % Inputs:
    %   unix_time: a scalar value representing the Unix timestamp (seconds since January 1, 1970)
    %
    % Output:
    %   jd: the corresponding Julian Date

    jd = unix_time / constants.julian_day + 2440587.5;
end
