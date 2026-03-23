function points = fibonacci_sphere(n)
    % Generate n approximately equally-spaced points on the unit sphere
    % using the Fibonacci lattice (golden spiral method).
    %
    % Input:
    %   n: the number of points to generate
    %
    % Output:
    %   points: 3 x n matrix of unit vectors

    golden_ratio = (1 + sqrt(5)) / 2;

    i = (0:n - 1)'; % indices 0 … n-1

    theta = acos(1 - 2 * (i + 0.5) / n); % polar angle: uniform in cos(theta)
    phi = 2 * pi * i / golden_ratio; % azimuthal angle: golden ratio steps

    points = [sin(theta) .* cos(phi), ...
                  sin(theta) .* sin(phi), ...
                  cos(theta)]'; % 3 x n
end
