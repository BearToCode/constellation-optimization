function converted = kep_values(orbit, idx)
    factors = [1/1000, 1, 180 / pi, 180 / pi, 180 / pi, 180 / pi];
    factor = factors(idx);
    converted = orbit * factor;
end
