function triangles = subdivide(triangles, iterations)
    % subdivide: subdivides the triangles into smaller triangles, by splitting each triangle into four smaller triangles.
    %
    % Input:
    %   triangles: the vertices of the triangles, as a 3xN matrix, containing along its columns, the unit vectors of the triangles.
    %              Each group of three columns corresponds to a triangle.
    %   iterations: the number of times to subdivide the triangles.
    %
    % Output:
    %   triangles: the vertices of the subdivided triangles, as a 3xM matrix, containing along its columns, the unit vectors of the triangles.
    %              Each group of three columns corresponds to a triangle.

    if iterations == 0
        return
    end

    triangles_count = size(triangles, 2) / 3;
    triangles = cell2mat( ...
        arrayfun(@(idx) subdivide_spherical_triangle(triangles(:, (idx - 1) * 3 + 1:idx * 3)), 1:triangles_count, UniformOutput = false) ...
    );
    triangles = subdivide(triangles, iterations - 1);
end
