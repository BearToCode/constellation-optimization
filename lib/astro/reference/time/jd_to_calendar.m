function [year, month, day, hour, minute, second] = jd_to_calendar(jd)
    % jd_to_calendar: converts a Julian Date to a calendar date and time.
    %
    % Inputs:
    %   jd: the Julian Date to be converted
    %
    % Outputs:
    %   year: the year of the calendar date
    %   month: the month of the calendar date
    %   day: the day of the calendar date
    %   hour: the hour of the calendar time
    %   minute: the minute of the calendar time
    %   second: the second of the calendar time

    jd0 = jd + 0.5;
    L1 = floor(jd0 + 68569);
    L2 = floor((4 * L1) / 146097);
    L3 = L1 - floor((146097 * L2 + 3) / 4);
    L4 = floor((4000 * (L3 + 1)) / 1461001);
    L5 = L3 - floor((1461 * L4) / 4) + 31;
    L6 = floor((80 * L5) / 2447);
    day = L5 - floor((2447 * L6) / 80);
    L7 = floor(L6 / 11);
    month = L6 + 2 - 12 * L7;
    year = 100 * (L2 - 49) + L4 + L7;
    dayFraction = jd0 - floor(jd0);
    hour = floor(dayFraction * 24);
    minute = floor((dayFraction * 24 - hour) * 60);
    second = floor( ...
        ((dayFraction * 24 - hour) * 60 - minute) * 60 ...
    );
end
