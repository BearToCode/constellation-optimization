classdef constants

    properties (Constant)
        Earth = struct( ...
            ... % Earth Radius [m]
            R = 6378137, ...
            ... % Equatorial radius [m]
            R_eq = 63781366, ...
            ... % Polar radius [m]
            R_p = 63567519, ...
            ... % Earth gravitational parameter [m^3/s^2]
            Mu = 3.986004418e14, ...
            ... % Earth J2 coefficient [-]
            J2 = 1.08263e-3 ...
        );

        JulianDay = 86400; % Seconds in a Julian day [s]
    end

end
