% Economic Load Dispatch with Transmission Line Losses using Reduced Gradient Method
% This MATLAB program solves the Economic Load Dispatch problem with consideration
% of transmission line losses using the Reduced Gradient optimization method.
% Author: Vraj Prajapati
% Date: March 2025
clc; clear all; close all;

% Load ELD data
% Format: [a, b, c, pg_min, pg_max, pgi_guess, ploss_coeff]
% a, b, c = Cost function coefficients for each generator (Cost = a*PG^2 + b*PG + c)
% pg_min, pg_max = Minimum and maximum generation limits
% pgi_guess = Initial generator output guess (not used in this implementation)
% ploss_coeff = B-coefficients for transmission loss calculation
PG_data = [0.004, 5.3, 500, 200, 450, 0, 0.00003;
           0.006, 5.5, 400, 150, 350, 0, 0.00009;
           0.009, 5.8, 200, 100, 225, 0, 0.00012]; % a, b, c, low_limit, high_limit, pgi_guess, ploss_coeff

N = length(PG_data(:,1)); % Number of generators
a = PG_data(:,1);  % Quadratic cost coefficient
b = PG_data(:,2);  % Linear cost coefficient
c = PG_data(:,3);  % Constant cost coefficient
pg_min = PG_data(:,4);  % Minimum generation limit
pg_max = PG_data(:,5);  % Maximum generation limit
ploss_coeff = PG_data(:,7);  % Loss coefficients

pd = 975;  % Demand value in MW

% Initialize parameters
error_tolerance_reduced_gradient = 1e-6;  % Increased precision for gradient convergence
error_tolerance_ploss_diff = 1e-6;        % Increased precision for loss convergence
lambda = 10;  % Initial value of lambda (Lagrange multiplier)
alpha = 0.001;  % Reduced step size for better convergence

% Better initialization - start from feasible solution
% First, check if the demand can be met
total_max_capacity = sum(pg_max);
if total_max_capacity < pd
    error('Error: Maximum generation capacity is less than demand!');
end

% Initialize with generators at their maximum except the last one
% This approach helps to find a feasible starting point
pg = zeros(N, 1);
for i = 1:N-1
    pg(i) = pg_max(i);
end

% Calculate initial losses estimate (rough approximation)
initial_loss_estimate = pd * 0.03; % Assume 3% losses initially
target_gen = pd + initial_loss_estimate;

% Adjust to meet the target generation + estimated losses
% If too much generation, reduce from most expensive generator first
if sum(pg(1:N-1)) > target_gen
    % Sort by marginal cost (descending) to reduce most expensive first
    [~, cost_order] = sort([2*a(1:N-1).*pg_max(1:N-1) + b(1:N-1)], 'descend');
    
    excess = sum(pg(1:N-1)) - target_gen;
    for idx = 1:N-1
        i = cost_order(idx);
        reduction = min(excess, pg(i) - pg_min(i));
        pg(i) = pg(i) - reduction;
        excess = excess - reduction;
        if excess <= 0
            break;
        end
    end
end

% Set the swing generator to balance
pg(N) = pd - sum(pg(1:N-1)); % Initial estimate without losses

% Calculate initial losses and update swing generator
ploss = sum(ploss_coeff .* pg.^2);
pg(N) = pd + ploss - sum(pg(1:N-1)); % Update with losses

% Check if swing generator exceeds limits and redistribute if necessary
if pg(N) < pg_min(N)
    % Need to increase other generators to reduce swing generator load
    deficit = pg_min(N) - pg(N);
    pg(N) = pg_min(N);
    
    % Distribute deficit to other generators based on cost
    [~, cost_order] = sort([2*a(1:N-1).*pg(1:N-1) + b(1:N-1)]);  % Sort by marginal cost (ascending)
    
    for idx = 1:N-1
        i = cost_order(idx);
        increase = min(deficit, pg_max(i) - pg(i));
        pg(i) = pg(i) + increase;
        deficit = deficit - increase;
        if deficit <= 0
            break;
        end
    end
elseif pg(N) > pg_max(N)
    % Need to decrease swing generator by increasing others
    excess = pg(N) - pg_max(N);
    pg(N) = pg_max(N);
    
    % Distribute excess to other generators based on cost
    [~, cost_order] = sort([2*a(1:N-1).*pg(1:N-1) + b(1:N-1)], 'descend');  % Sort by marginal cost (descending)
    
    for idx = 1:N-1
        i = cost_order(idx);
        decrease = min(excess, pg(i) - pg_min(i));
        pg(i) = pg(i) - decrease;
        excess = excess - decrease;
        if excess <= 0
            break;
        end
    end
end

% Recalculate losses after initialization
ploss = sum(ploss_coeff .* pg.^2);

% Initial penalty factors
% Penalty factors account for the effect of losses on incremental costs
pf = 1./(1 - 2*pg.*ploss_coeff);
pg_old = pg;

% Display initial values
fprintf('Initial conditions:\n');
fprintf('Initial pg: [%s]\n', sprintf('%.2f ', pg));
fprintf('Initial penalty factors: [%s]\n', sprintf('%.4f ', pf));
fprintf('Initial ploss: %.4f MW\n', ploss);
fprintf('Initial power balance: %.4f MW\n', sum(pg) - (pd + ploss));

% Main iteration loop
max_iterations = 500;  % Increased max iterations to ensure convergence
for iteration = 1:max_iterations
    fprintf('\n------ Iteration %d ------\n', iteration);
    
    % Call modified reduced gradient function to optimize generator outputs
    [pg, lambda, ploss_new] = reduced_gradient_function(alpha, N, error_tolerance_reduced_gradient, ...
                                          a, b, c, lambda, ploss_coeff, pd, ploss, pf, pg_old, pg_min, pg_max);
    
    % Update penalty factors based on new generation values
    pf_new = 1./(1 - 2*pg.*ploss_coeff);
    
    % Calculate difference in losses to check convergence
    diff_ploss = sum(ploss_new) - sum(ploss);
    
    % Display iteration results
    fprintf('pg: [%s]\n', sprintf('%.2f ', pg));
    fprintf('lambda: %.6f\n', lambda);
    fprintf('ploss: %.4f MW\n', ploss_new);
    fprintf('ploss difference: %.6f MW\n', diff_ploss);
    
    % Check power balance (generation = demand + losses)
    power_balance = sum(pg) - (pd + ploss_new);
    fprintf('Power balance: %.6f MW\n', power_balance);
    
    % Check if any generators violate their limits
    limits_violated = false;
    for i = 1:N
        if pg(i) < pg_min(i) - 0.01 || pg(i) > pg_max(i) + 0.01
            limits_violated = true;
            fprintf('WARNING: Generator %d (%.2f MW) outside limits (%.0f-%.0f)\n', i, pg(i), pg_min(i), pg_max(i));
        end
    end
    
    % Check for convergence using multiple criteria
    is_converged_loss = (abs(diff_ploss) < error_tolerance_ploss_diff);
    is_within_limits = ~limits_violated;
    is_balanced = (abs(power_balance) < 0.1);
    
    if is_converged_loss && is_within_limits && is_balanced
        fprintf('\nConverged after %d iterations!\n', iteration);
        break;
    end
    
    % Update for next iteration
    ploss = ploss_new;
    pf = pf_new;
    pg_old = pg;
    
    % Adaptive step size adjustment to improve convergence
    if iteration > 10
        if abs(diff_ploss) > error_tolerance_ploss_diff*10 || abs(power_balance) > 1
            alpha = alpha * 0.95; % Gradually reduce step size for convergence issues
        elseif iteration > 30 && abs(diff_ploss) < error_tolerance_ploss_diff*100 && abs(power_balance) < 10
            alpha = alpha * 1.05; % Gradually increase step size for slow convergence
            alpha = min(alpha, 0.01); % Cap step size
        end
        fprintf('Current step size: %.8f\n', alpha);
    end
end

if iteration == max_iterations
    fprintf('\nWARNING: Maximum iterations reached. Solution may not have fully converged.\n');
end

% Final adjustment to ensure power balance
% Distribute any remaining imbalance to generators with available capacity
final_balance = pd + ploss - sum(pg);
if abs(final_balance) > 0.1
    fprintf('\nPerforming final balance adjustment of %.4f MW\n', final_balance);
    
    if final_balance > 0
        % Need more generation
        [~, cost_order] = sort([2*a.*pg + b]);  % Sort by marginal cost (ascending)
        
        for idx = 1:N
            i = cost_order(idx);
            if pg(i) < pg_max(i)
                increase = min(final_balance, pg_max(i) - pg(i));
                pg(i) = pg(i) + increase;
                final_balance = final_balance - increase;
                fprintf('Increased G%d by %.4f MW\n', i, increase);
            end
            if final_balance <= 0.1
                break;
            end
        end
    else
        % Need less generation
        [~, cost_order] = sort([2*a.*pg + b], 'descend');  % Sort by marginal cost (descending)
        
        for idx = 1:N
            i = cost_order(idx);
            if pg(i) > pg_min(i)
                decrease = min(-final_balance, pg(i) - pg_min(i));
                pg(i) = pg(i) - decrease;
                final_balance = final_balance + decrease;
                fprintf('Decreased G%d by %.4f MW\n', i, decrease);
            end
            if final_balance >= -0.1
                break;
            end
        end
    end
    
    % Recalculate losses after final adjustment
    ploss = sum(ploss_coeff .* pg.^2);
    power_balance = sum(pg) - (pd + ploss);
    fprintf('Final power balance after adjustment: %.4f MW\n', power_balance);
end

% Final results
fprintf('\n===== Final Results =====\n');
for i = 1:N
    fprintf('Generator %d: %.4f MW (min: %.0f, max: %.0f)\n', i, pg(i), pg_min(i), pg_max(i));
end
fprintf('Total generation: %.4f MW\n', sum(pg));
fprintf('Total demand: %.4f MW\n', pd);
fprintf('Total losses: %.4f MW\n', ploss);
fprintf('Power balance: %.4f MW\n', sum(pg) - (pd + ploss));

% Calculate final cost
total_cost = 0;
for i = 1:N
    gen_cost = a(i)*pg(i)^2 + b(i)*pg(i) + c(i);
    fprintf('Generator %d cost: %.2f $/h (marginal cost: %.4f $/MWh)\n', i, gen_cost, 2*a(i)*pg(i) + b(i));
    total_cost = total_cost + gen_cost;
end
fprintf('Total cost: %.2f $/h\n', total_cost);

% Calculate incremental cost
fprintf('\nIncremental costs at operating point:\n');
for i = 1:N
    fprintf('Generator %d incremental cost: %.4f $/MWh\n', i, (2*a(i)*pg(i) + b(i)) * pf(i));
end

% Plot generation distribution
figure;
bar([pg pg_min pg_max]);
title('Economic Load Dispatch Solution');
xlabel('Generator Number');
ylabel('Power Output (MW)');
legend('Optimal Output', 'Minimum Limit', 'Maximum Limit');
grid on;

% Plot cost curves
figure;
pg_range = cell(N,1);
cost_range = cell(N,1);
marginal_cost = cell(N,1);

for i = 1:N
    pg_range{i} = linspace(pg_min(i), pg_max(i), 100);
    cost_range{i} = a(i)*(pg_range{i}.^2) + b(i)*pg_range{i} + c(i);
    marginal_cost{i} = 2*a(i)*pg_range{i} + b(i);
end

subplot(2,1,1);
hold on;
for i = 1:N
    plot(pg_range{i}, cost_range{i}, 'LineWidth', 2);
    plot(pg(i), a(i)*pg(i)^2 + b(i)*pg(i) + c(i), 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
end
title('Cost Curves');
xlabel('Power Output (MW)');
ylabel('Cost ($/h)');
legend('Generator 1', 'G1 Operating Point', 'Generator 2', 'G2 Operating Point', 'Generator 3', 'G3 Operating Point');
grid on;

subplot(2,1,2);
hold on;
for i = 1:N
    plot(pg_range{i}, marginal_cost{i}, 'LineWidth', 2);
    plot(pg(i), 2*a(i)*pg(i) + b(i), 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
end
title('Incremental Cost Curves');
xlabel('Power Output (MW)');
ylabel('Incremental Cost ($/MWh)');
grid on;

% Vraj did it