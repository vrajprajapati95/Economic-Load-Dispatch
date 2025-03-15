function [pg_final_calculated, lambda_final_calculated] = newton_method_function(pd, lambda, N, a, b, pg_min, pg_max, ploss_coeff, pg, ploss, pf)
    % Initialize variables
    error_tolerance = 0.0001;
    max_iterations = 50;
    
    % Start with current values
    pg_final_calculated = pg;
    lambda_final_calculated = lambda;
    
    for iter = 1:max_iterations
        % Calculate updated loss and penalty factors based on current generation
        ploss_current = zeros(1, N);
        pf_current = zeros(1, N);
        for j = 1:N
            pf_current(j) = 1/(1-(2*pg_final_calculated(j)*ploss_coeff(j)));
            ploss_current(j) = (pg_final_calculated(j)^2)*ploss_coeff(j);
        end
        
        % Build gradient vector (mismatch equations)
        gradient_vector = zeros(N+1, 1);
        for j = 1:N
            gradient_vector(j) = (2*a(j)*pg_final_calculated(j)) + b(j) - (lambda_final_calculated/pf_current(j));
        end
        gradient_vector(N+1) = pd + sum(ploss_current) - sum(pg_final_calculated);
        
        % Check convergence on both optimality conditions and power balance
        if max(abs(gradient_vector(1:N))) < error_tolerance && abs(gradient_vector(N+1)) < error_tolerance
            break;
        end
        
        % Build Jacobian matrix
        jacobian_matrix = zeros(N+1, N+1);
        for k = 1:N
            % Diagonal elements for generators
            jacobian_matrix(k, k) = 2*a(k);
            
            % Lambda column
            jacobian_matrix(k, N+1) = -1/pf_current(k);
            
            % Power balance row - include the effect of losses
            dloss_dpg = 2*ploss_coeff(k)*pg_final_calculated(k);
            jacobian_matrix(N+1, k) = dloss_dpg - 1;
        end
        jacobian_matrix(N+1, N+1) = 0;
        
        % Solve for correction vector using \operator (more stable than inv())
        correction_vector = -jacobian_matrix \ gradient_vector;
        
        % Apply corrections with damping factor to improve convergence
        damping = 1.0;  % Can be reduced if convergence is difficult
        
        % Update lambda first
        lambda_final_calculated = lambda_final_calculated + damping * correction_vector(N+1);
        
        % Then update generator outputs with constraints
        for l = 1:N
            % Update with damping
            pg_final_calculated(l) = pg_final_calculated(l) + damping * correction_vector(l);
            
            % Enforce generator limits
            if pg_final_calculated(l) < pg_min(l)
                pg_final_calculated(l) = pg_min(l);
            elseif pg_final_calculated(l) > pg_max(l)
                pg_final_calculated(l) = pg_max(l);
            end
        end
        
        % If we've reached max iterations, try to enforce power balance directly
        if iter == max_iterations
            % Calculate current losses
            total_losses = 0;
            for j = 1:N
                total_losses = total_losses + (pg_final_calculated(j)^2)*ploss_coeff(j);
            end
            
            % Calculate required generation
            required_generation = pd + total_losses;
            current_generation = sum(pg_final_calculated);
            
            % Adjust generation if needed and possible
            if abs(required_generation - current_generation) > error_tolerance
                shortage = required_generation - current_generation;
                
                % Find generators that can be adjusted
                adjustable_gens = [];
                for j = 1:N
                    if shortage > 0 && pg_final_calculated(j) < pg_max(j)
                        adjustable_gens = [adjustable_gens j];
                    elseif shortage < 0 && pg_final_calculated(j) > pg_min(j)
                        adjustable_gens = [adjustable_gens j];
                    end
                end
                
                % Distribute the shortage among adjustable generators
                if ~isempty(adjustable_gens)
                    adjustment = shortage / length(adjustable_gens);
                    for j = adjustable_gens
                        pg_final_calculated(j) = pg_final_calculated(j) + adjustment;
                        
                        % Re-check limits after adjustment
                        if pg_final_calculated(j) < pg_min(j)
                            pg_final_calculated(j) = pg_min(j);
                        elseif pg_final_calculated(j) > pg_max(j)
                            pg_final_calculated(j) = pg_max(j);
                        end
                    end
                end
            end
        end
    end
end