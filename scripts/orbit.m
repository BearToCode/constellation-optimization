% Propagate a simple orbit.

% Close and clear all
clc; clear; close all;

% Import necessary libraries
addpath(genpath('../lib'))

initial_state = kep2eci([6760e3, 0.00154, deg2rad(97.5643), deg2rad(182.719), deg2rad(275.0914), deg2rad(85.03242)]', constants.Earth.mu);
% initial_state = kep2eci([7126513.44232183, 0.000277379314357706, 0.888570586940683, 0.422335229587534, ...
%                              2.43199323527529, 3.39754329659587]', constants.Earth.mu);

ti_jd = 2461123.18064; % Initial time in Julian Date
simulation_time = 7 * 3600; % Simulation time [s]

ti = jd2unix(ti_jd); % Initial time [s]
tf = ti + simulation_time; % Final time [s]

f = eom(@(t, x) ...
    point_mass_acceleration(x(1:3), constants.Earth.mu) + ...
    j2_acceleration(x(1:3), constants.Earth.mu, constants.Earth.r, constants.Earth.j2) ...
);
[t, x] = ode78(f, [ti, tf], initial_state, odeset(RelTol = 1e-6, AbsTol = 1e-8));

x_kep = eci2kep(x', constants.Earth.mu);
x_cor = eci2geo(x', t);

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
plot(t, x_kep(1, :), LineWidth = 2);
xlabel('Time [s]');
ylabel('$a$ [m]', Interpreter = 'latex');
grid on;
subplot(3, 2, 2);
plot(t, x_kep(2, :), LineWidth = 2);
xlabel('Time [s]');
ylabel('$e$ [-]', Interpreter = 'latex');
grid on;
subplot(3, 2, 3);
plot(t, x_kep(3, :), LineWidth = 2);
xlabel('Time [s]');
ylabel('$i$ [rad]', Interpreter = 'latex');
grid on;
subplot(3, 2, 4);
plot(t, x_kep(4, :), LineWidth = 2);
xlabel('Time [s]');
ylabel('$\Omega$ [rad]', Interpreter = 'latex');
grid on;
subplot(3, 2, 5);
plot(t, x_kep(5, :), LineWidth = 2);
xlabel('Time [s]');
ylabel('$\omega$ [rad]', Interpreter = 'latex');
grid on;
subplot(3, 2, 6);
plot(t, x_kep(6, :), LineWidth = 2);
xlabel('Time [s]');
ylabel('$\theta$ [rad]', Interpreter = 'latex');
grid on;

% Plot the ground track
figure;
worldmap('World');
load coastlines
plotm(coastlat, coastlon, 'k', LineWidth = 2);
plotm(rad2deg(x_cor(1, :)), rad2deg(x_cor(2, :)), 'r', LineWidth = 2);
