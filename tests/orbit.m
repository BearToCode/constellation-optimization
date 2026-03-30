% Propagate a simple orbit.

% Close and clear all
clc; clear; close all;

% Import necessary libraries
addpath(genpath('../lib'))

initial_state = [+6314514.874350373; % Position [m]
                 +3126065.2383962893;
                 -2.0526284983191623;
                 -2584.1416403047383; % Velocity [m/s]
                 +4834.0507909568605;
                 +5113.048157234863];

f = eom(@(t, x) ...
    point_mass_acceleration(x(1:3), constants.Earth.mu) + ...
    j2_acceleration(x(1:3), constants.Earth.mu, constants.Earth.r, constants.Earth.j2) ...
);
[t, x] = ode78(f, [0, 3600 * 4], initial_state, odeset(RelTol = 1e-6, AbsTol = 1e-8));

x_kep = car_to_kep(x, constants.Earth.mu);
x_cor = car_to_cor(x', t);

% Plot the 3d trajectory
figure;
plot3(x(:, 1), x(:, 2), x(:, 3), LineWidth = 2);
xlabel('x [m]');
ylabel('y [m]');
zlabel('z [m]');
grid on;
axis equal;

% Plot the Keplerian elements in 6 subplots
figure;
subplot(3, 2, 1);
plot(t, x_kep(:, 1), LineWidth = 2);
xlabel('Time [s]');
ylabel('$a$ [m]', Interpreter = 'latex');
grid on;
subplot(3, 2, 2);
plot(t, x_kep(:, 2), LineWidth = 2);
xlabel('Time [s]');
ylabel('$e$ [-]', Interpreter = 'latex');
grid on;
subplot(3, 2, 3);
plot(t, x_kep(:, 3), LineWidth = 2);
xlabel('Time [s]');
ylabel('$i$ [rad]', Interpreter = 'latex');
grid on;
subplot(3, 2, 4);
plot(t, x_kep(:, 4), LineWidth = 2);
xlabel('Time [s]');
ylabel('$\Omega$ [rad]', Interpreter = 'latex');
grid on;
subplot(3, 2, 5);
plot(t, x_kep(:, 5), LineWidth = 2);
xlabel('Time [s]');
ylabel('$\omega$ [rad]', Interpreter = 'latex');
grid on;
subplot(3, 2, 6);
plot(t, x_kep(:, 6), LineWidth = 2);
xlabel('Time [s]');
ylabel('$\theta$ [rad]', Interpreter = 'latex');
grid on;

% Plot the ground track
figure;
worldmap('World');
load coastlines
plotm(coastlat, coastlon, 'k', LineWidth = 2);
plotm(rad2deg(x_cor(1, :)), rad2deg(x_cor(2, :)), 'r', LineWidth = 2);
