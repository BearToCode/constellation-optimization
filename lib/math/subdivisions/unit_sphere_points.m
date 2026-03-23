function points = unit_sphere_points(subdivisions)
    % unit_sphere_points: generate points on the unit sphere by subdividing an icosahedron.
    %
    % Input:
    %   subdivisions: the number of times to subdivide the icosahedron
    %
    % Output:
    %   points: a matrix of size (3, N) containing the coordinates of the points on the unit sphere

    triangles = icosahedron();
    triangles = subdivide(triangles, subdivisions);

    triangles_count = size(triangles, 2) / 3;
    points = arrayfun(@(idx) triangle_midpoint(triangles(:, (idx - 1) * 3 + 1:idx * 3)), 1:triangles_count, UniformOutput = false);
    points = cell2mat(points);
end
