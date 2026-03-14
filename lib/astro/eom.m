function x_dot_fun = eom(acc_fun)
    % eom: obtain the equation of motion of motion given the acceleration function.
    %
    % Inputs:
    %   acc_fun: a function handle that takes the current time and state and returns the acceleration
    %
    % Output:
    %   x_dot_fun: a function handle that takes the current state and returns its time derivative

    function x_dot = f(t, x)
        position = x(1:3);
        velocity = x(4:6);

        acceleration = acc_fun(t, position);

        x_dot = [velocity; acceleration];
    end

    x_dot_fun = @f;
end
