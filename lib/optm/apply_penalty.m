function f = apply_penalty(f_unconstrained, g, p)
    % apply_penalty: Applies a penalty to the unconstrained cost function based on the constraint violations.
    %
    % Inputs:
    %   f_unconstrained: The original unconstrained cost function (function handle).
    %   g: The constraint function (function handle) that returns a vector of constraint violations
    %   p: The penalty parameter (scalar) that determines the weight of the penalty term.
    %
    % Output:
    %   f: The new cost function with the penalty applied (function handle).

    f = @(y) f_unconstrained(y) + p * sum(max(0, g(y))) ^ 2;
end
