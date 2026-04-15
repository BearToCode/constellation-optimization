function [x_opt, fval, best_evaluations] = sa(f, x0, lb, ub, options)
    % sa: Solve an optimization problem using Simulated Annealing.
    %
    % Inputs:
    %   f: The cost function of the problem.
    %   x0: The initial guess for the problem solution, as a column vector.
    %   lb: Lower bounds of x, as a column vector.
    %   ub: Upper bounds of x, as a column vector.
    %   options: Simulated Annealing options.
    %      - max_iters: Maximum number of iterations.
    %      - max_no_improvement_iters: The maximum number of iterations after which the
    %                                  algorithm stops, when no better solution has been found.
    %      - initial_temperature: Initial temperature of the algorithm.
    %      - debug: If true, prints debug information during optimization.
    %      - alpha: The cooling rate (between 0 and 1) that determines how quickly the temperature decreases.
    %
    % Outputs:
    %   x_opt: The found solution of the optimization problem.
    %   fval: The function evaluated at the found minimum.
    %   best_evaluations: The best function evaluation found per iteration.

    initial_step_sizes = (ub - lb) * 0.25;

    best_evaluations = zeros(options.max_iters, 1);
    accepted = 0;

    best_x = x0;
    best_eval = f(x0);
    current_x = best_x;
    current_eval = best_eval;

    N = size(x0, 1);
    k = 1;
    no_improvement_iters = 0;

    while k <= options.max_iters && no_improvement_iters < options.max_no_improvement_iters
        temperature = options.initial_temperature * power(options.alpha, k);

        % Generate candidate solution
        perturbation = randn(N, 1) .* initial_step_sizes;
        candidate_x = current_x + perturbation;
        % Clamp the results between bounds
        candidate_x = min(max(candidate_x, lb), ub);
        candidate_eval = f(candidate_x);

        delta = candidate_eval - current_eval;

        if delta < 0 || rand() < exp(-delta / temperature)
            current_x = candidate_x;
            current_eval = candidate_eval;
            accepted = accepted + 1;
        end

        if current_eval < best_eval
            best_x = current_x;
            best_eval = current_eval;

            no_improvement_iters = 0;
        else
            no_improvement_iters = no_improvement_iters + 1;
        end

        best_evaluations(k) = best_eval;

        if options.debug
            acceptance_rate = accepted / k;
            fprintf('Iteration %d: \t Best Evaluation = %.6f \t Stuck = %d \t Acceptance Rate = %.6f\n', k, best_eval, no_improvement_iters, acceptance_rate);
        end

        k = k + 1;
    end

    % Set all remaining best evaluations to the last found best evaluation
    best_evaluations(k:end) = best_eval;

    x_opt = best_x;
    fval = best_eval;
end
