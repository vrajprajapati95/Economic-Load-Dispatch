function [pg_new, lambda_new] = newton_method_function(N, a, b, pg, ploss, ...
    ploss_coeff, lambda, pd, pg_min, pg_max, ...
    error_tolerance)
    
    % Initialize
    max_iterations = 100;
    convergence = false;
    iteration = 0;
    
    % Current generator outputs and lambda
    pg_new = pg;
    lambda_new = lambda;
    
    % Newton's method iterations
    while ~convergence && iteration < max_iterations
        iteration = iteration + 1;
        
        % Calculate penalty factors
        pf = 1 ./ (1 - 2 * pg_new .* ploss_coeff);
        
        % Calculate total losses based on current generation
        ploss_sum = 0;
        for i = 1:N
            ploss_sum = ploss_sum + ploss_coeff(i) * (pg_new(i)^2);
        end
        
        % Calculate power balance constraint: sum(pg) - sum(ploss) - pd = 0
        g_lambda = sum(pg_new) - ploss_sum - pd;
        dg_lambda = 0;
        
        % Calculate derivative of constraint with respect to lambda
        for i = 1:N
            % Only include generators not at limits in derivative calculation
            if pg_min(i) < pg_new(i) && pg_new(i) < pg_max(i)
                dg_lambda = dg_lambda + pf(i) / (2 * a(i));
            end
        end
        
        % Check convergence - based on power balance
        if abs(g_lambda) < error_tolerance
            convergence = true;
            fprintf('Newton method converged after %d iterations\n', iteration);
            break;
        end
        
        % Update lambda using Newton's method
        if abs(dg_lambda) > 1e-6 % Avoid division by very small numbers
            lambda_new = lambda_new - g_lambda / dg_lambda;
        else
            fprintf('Warning: Near-zero derivative in Newton method\n');
            % Adjust lambda based on power balance direction
            if g_lambda > 0
                lambda_new = lambda_new * 1.05; % Increase lambda to reduce generation
            else
                lambda_new = lambda_new * 0.95; % Decrease lambda to increase generation
            end
        end
        
        % Keep lambda positive
        lambda_new = max(0.1, lambda_new);
        
        % Update generator outputs based on new lambda
        for i = 1:N
            % Calculate new generation level using lambda and penalty factor
            pg_new_i = (lambda_new / pf(i) - b(i)) / (2 * a(i));
            
            % Apply generator limits
            pg_new(i) = max(pg_min(i), min(pg_max(i), pg_new_i));
        end
        
        % Debug output every 10 iterations
        if mod(iteration, 10) == 0
            fprintf(' Newton iteration %d: lambda=%.4f, error=%.6f\n', ...
                iteration, lambda_new, g_lambda);
        end
    end
    
    % Check if Newton method failed to converge
    if iteration >= max_iterations
        fprintf('Warning: Newton method did not converge within %d iterations\n', max_iterations);
    end
end