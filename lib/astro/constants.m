classdef constants

    properties (Constant)
        Earth = struct( ...
            ... % Earth Radius [m]
            r = 6378137, ...
            ... % Equatorial radius [m]
            r_eq = 6378137.0, ...
            ... % Polar radius [m]
            r_p = 6356752.3, ...
            ... % Earth gravitational parameter [m^3/s^2]
            mu = 3.986004418e14, ...
            ... % Earth J2 coefficient [-]
            j2 = 1.08263e-3 ...
        );

        julian_day = 86400; % Seconds in a Julian day [s]
    end

end
