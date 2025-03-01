function [pg_new, lambda_new] = newton_method_function(N, a, b, pg, ploss, ...
                                ploss_coeff, lambda, pd, pg_min, pg_max, ...
                                error_tolerance)
% NEWTON_METHOD_FUNCTION Implements Newton's method for ELD with losses
%   Solves the economic load dispatch problem using Newton's method
%   
%   Inputs:
%       N - Number of generators
%       a, b - Cost function parameters
%       pg - Current generator outputs
%       ploss - Current power losses
%       ploss_coeff - Loss coefficients
%       lambda - Current lambda value
%       pd - Power demand
%       pg_min, pg_max - Generator limits
%       error_tolerance - Convergence tolerance
%
%   Outputs:
%       pg_new - Updated generator outputs
%       lambda_new - Updated lambda value

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
        
        % Calculate incremental costs for each generator
        incremental_costs = 2 * a .* pg_new + b;
        
        % Calculate constraints and their derivatives
        g_lambda = 0;
        dg_lambda = 0;
        
        for i = 1:N
            % Calculate lambda based coordination equations
            pf_i = pf(i);
            lambda_eq = lambda_new * pf_i;
            
            % Calculate power output for unconstrained generators
            if pg_min(i) < pg_new(i) && pg_new(i) < pg_max(i)
                % Unconstrained generator
                g_lambda = g_lambda + pg_new(i);
                dg_lambda = dg_lambda + pf_i / (2 * a(i));
            elseif incremental_costs(i) * pf_i > lambda_new && pg_new(i) == pg_min(i)
                % Generator at minimum
                g_lambda = g_lambda + pg_min(i);
            elseif incremental_costs(i) * pf_i < lambda_new && pg_new(i) == pg_max(i)
                % Generator at maximum
                g_lambda = g_lambda + pg_max(i);
            end
        end
        
        % Power balance constraint
        g_lambda = g_lambda - pd - sum(ploss);
        
        % Check convergence
        if abs(g_lambda) < error_tolerance
            convergence = true;
            fprintf('Newton method converged after %d iterations\n', iteration);
            break;
        end
        
        % Update lambda using Newton's method
        if dg_lambda ~= 0
            lambda_new = lambda_new - g_lambda / dg_lambda;
        else
            fprintf('Warning: Zero derivative in Newton method\n');
            lambda_new = lambda_new * 1.05; % Adjust lambda by 5%
        end
        
        % Update generator outputs based on new lambda
        for i = 1:N
            pf_i = pf(i);
            lambda_eq = lambda_new / pf_i;
            
            % Calculate new power output for generator i
            pg_new_i = (lambda_eq - b(i)) / (2 * a(i));
            
            % Apply generator limits
            pg_new(i) = max(pg_min(i), min(pg_max(i), pg_new_i));
        end
        
        % Debug output every 10 iterations
        if mod(iteration, 10) == 0
            fprintf('  Newton iteration %d: lambda=%.4f, error=%.6f\n', ...
                   iteration, lambda_new, g_lambda);
        end
    end
    
    % Check if Newton method failed to converge
    if iteration >= max_iterations
        fprintf('Warning: Newton method did not converge within %d iterations\n', max_iterations);
    end
end

% Vraj did it