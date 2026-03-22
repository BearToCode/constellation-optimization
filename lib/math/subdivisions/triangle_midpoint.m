function point = triangle_midpoint(triangle)
    % triangle_midpoint: calculates the midpoint of a triangle, as the mean of its vertices.
    %
    % Input:
    %   triangle: the triangle, as a 3xN matrix, containing along its columns, the unit vectors
    %              of the triangle.
    % Output:
    %   point: the midpoint of the triangle, as a 3x1 vector.
    point = triangle(:, 1) + triangle(:, 2) + triangle(:, 3);
    % Normalize the point to lie on the unit sphere
    point = point / norm(point);
end
