function split_triangles = subdivide_spherical_triangle(triangle)
    % subdivide_spherical_triangle: subdivide a spherical triangle into two of equal area
    %
    % Input:
    %   triangle: the spherical triangle, as a 3x3 matrix, containing along its columns,
    %             the unit vectors of the triangle.
    %
    % Output:
    %   split_triangles: the resulting triangles, as a 3x6 matrix.
    %
    % Reference: Sanghyun Lee, Daniele Mortari: "Quasi-equal area subdivision algorithm for
    % uniform points on a sphere with application to any geographical data distribution", 2017.

    % Find the largest side the triangle
    v1 = triangle(:, 1);
    v2 = triangle(:, 2);
    v3 = triangle(:, 3);

    % Compute angular lengths of the three edges
    l12 = acos(dot(v1, v2));
    l23 = acos(dot(v2, v3));
    l31 = acos(dot(v3, v1));

    % Bisect the longest edge via slerp at t=0.5
    if l12 >= l23 && l12 >= l31
        mid = slerp(v1, v2, 0.5);
        t1 = [v1, mid, v3];
        t2 = [mid, v2, v3];
    elseif l23 >= l12 && l23 >= l31
        mid = slerp(v2, v3, 0.5);
        t1 = [v1, v2, mid];
        t2 = [v1, mid, v3];
    else
        mid = slerp(v3, v1, 0.5);
        t1 = [v1, v2, mid];
        t2 = [mid, v2, v3];
    end

    split_triangles = [t1, t2];
end

function m = slerp(a, b, t)
    % Spherical linear interpolation between unit vectors a and b
    d = max(-1, min(1, dot(a, b)));
    theta = acos(d);

    if abs(theta) < 1e-9
        m = a;
        return
    end

    m = (sin((1 - t) * theta) * a + sin(t * theta) * b) / sin(theta);
    m = m / norm(m); % renormalize for numerical safety
end
