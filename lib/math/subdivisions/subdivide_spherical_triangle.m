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

    safe_acos = @(x) acos(max(-1, min(1, x)));
    safe_asin = @(x) asin(max(-1, min(1, x)));

    sides = [v3, v2, v1, v3, v2, v1];
    get_side = @(idx) sides(:, (idx - 1) * 2 + (1:2));
    get_side_angle = @(side) safe_acos(dot(side(:, 1), side(:, 2)));

    sides_angles = arrayfun(@(idx) get_side_angle(get_side(idx)), 1:3);

    [~, max_side_angle_idx] = max(sides_angles);
    largest_side = get_side(max_side_angle_idx);
    va = triangle(:, max_side_angle_idx);
    vb = largest_side(:, 1);
    vc = largest_side(:, 2);

    % Calculate all dihedral angles
    a = safe_acos(dot(vc, vb));
    b = safe_acos(dot(va, vc));
    c = safe_acos(dot(va, vb));

    A = safe_acos((cos(a) - cos(b) * cos(c)) / (sin(b) * sin(c)));
    B = safe_acos((cos(b) - cos(c) * cos(a)) / (sin(c) * sin(a)));
    C = safe_acos((cos(c) - cos(a) * cos(b)) / (sin(a) * sin(b)));

    % Procedure from the paper
    D = (A + C + pi - B) / 2;
    x = atan2(cos(D) + cos(B), sin(B) * cos(c) - sin(D));

    if x <= 0
        x = x + pi;
    end

    z = safe_asin((sin(x) * sin(c)) / sin(D - x));
    z = max(0, min(a, z)); % clamp z to valid arc range as a safeguard

    vd = 1 / sin(a) * (vc * sin(z) + vb * sin(a - z));
    vd = vd / norm(vd);

    split_triangles = [va, vb, vd, va, vc, vd];
end
