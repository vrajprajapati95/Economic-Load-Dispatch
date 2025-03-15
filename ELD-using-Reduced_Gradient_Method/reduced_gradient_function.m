function [pg, lambda, ploss_updated] = reduced_gradient_function(alpha, N, error_tolerance, ...
                                               a, b, c, lambda, ploss_coeff, pd, ploss, pf, pg_old, pg_min, pg_max)
    % REDUCED_GRADIENT_FUNCTION - Solves Economic Load Dispatch using Reduced Gradient method
    %
    % This function implements the reduced gradient optimization method to solve
    % the economic load dispatch problem with transmission line losses.
    %
    % Inputs:
    %   alpha - Step size for gradient descent
    %   N - Number of generators
    %   error_tolerance - Convergence tolerance
    %   a, b, c - Cost function coefficients (Cost = a*PG^2 + b*PG + c)
    %   lambda - Initial Lagrange multiplier
    %   ploss_coeff - Transmission loss coefficients
    %   pd - System demand
    %   ploss - Initial transmission losses
    %   pf - Penalty factors
    %   pg_old - Previous generator outputs
    %   pg_min, pg_max - Generator limits
    %
    % Outputs:
    %   pg - Optimized generator outputs
    %   lambda - Updated Lagrange multiplier
    %   ploss_updated - Updated transmission losses
    
    % Initialize variables
    pg = pg_old;
    gradient_vector = zeros(N+1, 1);
    
    % Calculate initial losses based on current generation
    ploss_updated = sum(ploss_coeff .* pg.^2);
    
    % Reduced gradient method iterations
    max_inner_iterations = 100;  % Limit inner iterations
    for iteration = 1:max_inner_iterations
        % Apply generator limits before calculating gradients
        % This ensures all generators are within their feasible regions
        for i = 1:N
            if pg(i) < pg_min(i)
                pg(i) = pg_min(i);
            elseif pg(i) > pg_max(i)
                pg(i) = pg_max(i);
            end
        end
        
        % Recalculate losses after applying limits
        ploss_updated = sum(ploss_coeff .* pg.^2);
        
        % Calculate dependent generator output (PGn)
        % Select a generator to be dependent (can be different from N)
        dependent_gen = N;  % Using the last generator as dependent
        
        % Set the dependent generator to balance power
        pg(dependent_gen) = pd + ploss_updated - sum(pg(1:N)) + pg(dependent_gen);
        
        % Check if dependent generator violates limits and redistribute if necessary
        if pg(dependent_gen) < pg_min(dependent_gen)
            % Handle case where dependent generator is below minimum limit
            deficit = pg_min(dependent_gen) - pg(dependent_gen);
            pg(dependent_gen) = pg_min(dependent_gen);
            
            % Find generators that can increase output
            available_gens = [];
            available_margins = [];
            
            for i = 1:N
                if i ~= dependent_gen && pg(i) < pg_max(i)
                    available_gens = [available_gens; i];
                    available_margins = [available_margins; pg_max(i) - pg(i)];
                end
            end
            
            if ~isempty(available_gens)
                % Distribute deficit based on available margin and incremental cost
                % Sort by incremental cost (cheapest first)
                inc_costs = 2*a(available_gens).*pg(available_gens) + b(available_gens);
                [~, cost_order] = sort(inc_costs);
                
                for idx = 1:length(available_gens)
                    i = available_gens(cost_order(idx));
                    increase = min(deficit, pg_max(i) - pg(i));
                    pg(i) = pg(i) + increase;
                    deficit = deficit - increase;
                    
                    if deficit <= 0.001
                        break;
                    end
                end
            end
            
        elseif pg(dependent_gen) > pg_max(dependent_gen)
            % Handle case where dependent generator is above maximum limit
            excess = pg(dependent_gen) - pg_max(dependent_gen);
            pg(dependent_gen) = pg_max(dependent_gen);
            
            % Find generators that can decrease output
            available_gens = [];
            available_margins = [];
            
            for i = 1:N
                if i ~= dependent_gen && pg(i) > pg_min(i)
                    available_gens = [available_gens; i];
                    available_margins = [available_margins; pg(i) - pg_min(i)];
                end
            end
            
            if ~isempty(available_gens)
                % Distribute excess based on available margin and incremental cost
                % Sort by incremental cost (most expensive first)
                inc_costs = 2*a(available_gens).*pg(available_gens) + b(available_gens);
                [~, cost_order] = sort(inc_costs, 'descend');
                
                for idx = 1:length(available_gens)
                    i = available_gens(cost_order(idx));
                    decrease = min(excess, pg(i) - pg_min(i));
                    pg(i) = pg(i) - decrease;
                    excess = excess - decrease;
                    
                    if excess <= 0.001
                        break;
                    end
                end
            end
        end
        
        % Recalculate losses after redistribution
        ploss_updated = sum(ploss_coeff .* pg.^2);
        
        % Calculate gradients for each generator except the dependent one
        for i = 1:N
            if i == dependent_gen
                gradient_vector(i) = 0;  % Skip dependent generator
                continue;
            end
            
            % Skip generators at their limits
            if pg(i) <= pg_min(i) && gradient_vector(i) > 0
                gradient_vector(i) = 0;
                continue;
            elseif pg(i) >= pg_max(i) && gradient_vector(i) < 0
                gradient_vector(i) = 0;
                continue;
            end
            
            % Calculate marginal costs
            dCost_i = 2*a(i)*pg(i) + b(i);  % Incremental cost of generator i
            dCost_dep = 2*a(dependent_gen)*pg(dependent_gen) + b(dependent_gen);  % Incremental cost of dependent generator
            
            % Calculate loss sensitivities
            dLoss_i = 2*ploss_coeff(i)*pg(i);  % Change in losses due to generator i
            dLoss_dep = 2*ploss_coeff(dependent_gen)*pg(dependent_gen);  % Change in losses due to dependent generator
            
            % Calculate penalty factors
            pf_i = 1/(1 - dLoss_i);
            pf_dep = 1/(1 - dLoss_dep);
            
            % Calculate reduced gradient
            gradient_vector(i) = pf_i * dCost_i - pf_dep * dCost_dep;
        
        
        % Power balance constraint gradient (should be close to zero)
        gradient_vector(N+1) = sum(pg) - (pd + ploss_updated);
        
        % Update generators using gradient descent
        max_gradient = 0;
        for i = 1:N
            if i == dependent_gen
                continue;  % Skip dependent generator
            end
            
            % Only update if not at limits or if gradient pushes away from limit
            if (pg(i) > pg_min(i) && pg(i) < pg_max(i)) || ...
               (pg(i) <= pg_min(i) && gradient_vector(i) < 0) || ...
               (pg(i) >= pg_max(i) && gradient_vector(i) > 0)
                
                step = alpha * gradient_vector(i);
                pg(i) = pg(i) - step;
                
                % Apply limits after update
                if pg(i) < pg_min(i)
                    pg(i) = pg_min(i);
                elseif pg(i) > pg_max(i)
                    pg(i) = pg_max(i);
                end
            end
            
            % Track maximum gradient for convergence check
            max_gradient = max(max_gradient, abs(gradient_vector(i)));
        end
        
        
        % Update lambda (Lagrange multiplier)
        lambda = lambda + alpha * gradient_vector(N+1);
        
        % Recalculate dependent generator and losses
        ploss_updated = sum(ploss_coeff .* pg.^2);
        pg(dependent_gen) = pd + ploss_updated - sum(pg(1:N)) + pg(dependent_gen);
        
        % Apply limits to dependent generator
        if pg(dependent_gen) < pg_min(dependent_gen)
            pg(dependent_gen) = pg_min(dependent_gen);
        elseif pg(dependent_gen) > pg_max(dependent_gen)
            pg(dependent_gen) = pg_max(dependent_gen);
        end
        
        % Check power balance after updates
        power_balance = sum(pg) - (pd + ploss_updated);
        
        % Check convergence
        if max_gradient < error_tolerance && abs(power_balance) < error_tolerance
            break;
        end
    end
    
    % Final recalculation of losses
    ploss_updated = sum(ploss_coeff .* pg.^2);
end

% Vraj did it