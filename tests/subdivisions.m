% Subdivides the unit sphere into quasi-equal polygons.

% Close and clear all
clc; clear; close all;

triangles = icosahedron();
triangles = subdivide(triangles, 3);

triangles_count = size(triangles, 2) / 3;
points = arrayfun(@(idx) triangle_midpoint(triangles(:, (idx - 1) * 3 + 1:idx * 3)), 1:triangles_count, UniformOutput = false);

disp("Number of points: " + num2str(length(points)));

% Plot all the points
figure;
scatter3(cellfun(@(p) p(1), points), cellfun(@(p) p(2), points), cellfun(@(p) p(3), points), LineWidth = 2);
xlabel('x');
ylabel('y');
zlabel('z');
grid on;
axis equal;
