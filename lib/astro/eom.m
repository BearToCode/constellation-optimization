function x_dot = eom(t, x, acc_fun)
    % eom: calculates the time derivative of the state vector for a given state and acceleration function.
    %
    % Inputs:
    %   t: the current time
    %   x: a 6x1 vector containing the current state (position and velocity)
    %   acc_fun: a function handle that takes the current time and state and returns the acceleration
    %
    % Output:
    %   x_dot: a 6x1 vector containing the time derivative of the state vector

    position = x(1:3);
    velocity = x(4:6);

    acceleration = acc_fun(t, position);

    x_dot = [velocity; acceleration];
end
