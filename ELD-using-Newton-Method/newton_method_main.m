clear all
clc
ELD_Data  % Load the data

% Extract generator parameters
N = size(PG_data, 1);
a = PG_data(:, 1);
b = PG_data(:, 2);
c = PG_data(:, 3);
pg_min = PG_data(:, 4);
pg_max = PG_data(:, 5);
ploss_coeff = PG_data(:, 7);
pd = 975;  % Load demand

% Initialize variables with a feasible starting point
pg = zeros(1, N);
total_min = sum(pg_min);
total_max = sum(pg_max);

if pd < total_min
    error('Demand is less than minimum generation capacity');
elseif pd > total_max
    error('Demand exceeds maximum generation capacity');
else
    % Distribute load proportionally between min and max limits
    for i = 1:N
        pg(i) = pg_min(i) + (pg_max(i) - pg_min(i)) * (pd - total_min) / (total_max - total_min);
    end
end

% Better initial lambda estimate based on average marginal cost
lambda_init = 0;
for i = 1:N
    lambda_init = lambda_init + 2*a(i)*pg(i) + b(i);
end
lambda = lambda_init / N;

error_tolerance = 0.01;  % Tolerance for convergence
max_iterations = 100;  % Maximum iterations

% Initialize loss and penalty factors
ploss = zeros(1, N);
pf = zeros(1, N);

% Calculate initial ploss and pf
for i = 1:N
    pf(i) = 1/(1-(2*pg(i)*ploss_coeff(i)));
    ploss(i) = (pg(i)^2)*ploss_coeff(i);
end

total_ploss = sum(ploss);
fprintf('Initial: Gen: %.2f MW, Demand: %.2f MW, Loss: %.2f MW, Balance: %.2f MW\n', sum(pg), pd, total_ploss, sum(pg) - (pd + total_ploss));

% Main iteration loop
for iter = 1:max_iterations
    % Call Newton method to update pg and lambda
    [pg_new, lambda_new] = newton_method_function(pd, lambda, N, a, b, pg_min, pg_max, ploss_coeff, pg, ploss, pf);
    
    % Calculate new loss and penalty factors
    ploss_new = zeros(1, N);
    pf_new = zeros(1, N);
    for j = 1:N
        pf_new(j) = 1/(1-(2*pg_new(j)*ploss_coeff(j)));
        ploss_new(j) = (pg_new(j)^2)*ploss_coeff(j);
    end
    
    % Calculate changes for convergence check
    total_ploss_new = sum(ploss_new);
    power_balance = sum(pg_new) - (pd + total_ploss_new);
    
    % Print iteration details
    fprintf('Iter %2d: Gen: %.2f MW, Loss: %.2f MW, Balance: %.6f MW, Lambda: %.6f\n', iter, sum(pg_new), total_ploss_new, power_balance, lambda_new);
    
    % Update values for next iteration
    pg = pg_new;
    lambda = lambda_new;
    ploss = ploss_new;
    pf = pf_new;
    
    % Check convergence on power balance
    if abs(power_balance) < error_tolerance
        fprintf('\nConverged after %d iterations!\n', iter);
        break;
    end
    
    % If we're at the last iteration and still not converged, try one final adjustment
    if iter == max_iterations
        fprintf('\nReached maximum iterations. Performing final adjustment...\n');
        
        % Calculate current total loss
        total_ploss = sum(ploss);
        
        % Calculate required total generation
        required_generation = pd + total_ploss;
        
        % Find generators not at their limits
        adjustable_gens = [];
        for i = 1:N
            if pg(i) > pg_min(i) && pg(i) < pg_max(i)
                adjustable_gens = [adjustable_gens i];
            end
        end
        
        if ~isempty(adjustable_gens)
            % Calculate current imbalance
            current_imbalance = sum(pg) - required_generation;
            
            % Distribute the adjustment among available generators
            adjustment_per_gen = current_imbalance / length(adjustable_gens);
            
            for i = adjustable_gens
                pg(i) = pg(i) - adjustment_per_gen;
                
                % Ensure limits are respected
                if pg(i) < pg_min(i)
                    pg(i) = pg_min(i);
                elseif pg(i) > pg_max(i)
                    pg(i) = pg_max(i);
                end
                
                % Update loss for this generator
                ploss(i) = (pg(i)^2) * ploss_coeff(i);
            end
            
            % Recalculate power balance
            total_ploss = sum(ploss);
            power_balance = sum(pg) - (pd + total_ploss);
            
            fprintf('After adjustment: Gen: %.2f MW, Loss: %.2f MW, Balance: %.6f MW\n', sum(pg), total_ploss, power_balance);
        end
    end
end

% Print final results
fprintf('\nFinal Results:\n');
fprintf('Generator\tOutput (MW)\tMin (MW)\tMax (MW)\tMarginal Cost ($/MWh)\n');
for i = 1:N
    fprintf('%d\t\t%.2f\t\t%.2f\t\t%.2f\t\t%.6f\n', i, pg(i), pg_min(i), pg_max(i), 2*a(i)*pg(i) + b(i));
end

fprintf('\nTotal generation: %.2f MW\n', sum(pg));
fprintf('Total demand: %.2f MW\n', pd);
fprintf('Total losses: %.2f MW\n', sum(ploss));
fprintf('Power balance: %.6f MW\n', sum(pg) - (pd + sum(ploss)));
fprintf('Final lambda (system marginal cost): %.6f $/MWh\n', lambda);

% Calculate total cost
total_cost = 0;
for i = 1:N
    gen_cost = a(i)*pg(i)^2 + b(i)*pg(i) + c(i);
    total_cost = total_cost + gen_cost;
    fprintf('Generator %d cost: $%.2f/h\n', i, gen_cost);
end
fprintf('Total system cost: $%.2f/h\n', total_cost);