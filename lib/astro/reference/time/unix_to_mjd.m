function mjd = unix_to_mjd(unix_time)
    % unix_to_mjd: converts a Unix timestamp to Modified Julian Date (MJD).
    %
    % Inputs:
    %   unix_time: a scalar value representing the Unix timestamp (seconds since January 1, 1970)
    %
    % Output:
    %   mjd: the corresponding Modified Julian Date

    mjd = unix_to_jd(unix_time) - 2400000.5;
end
