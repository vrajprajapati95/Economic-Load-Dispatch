%% Economic Load Dispatch with Transmission Line Losses - Revised
% This script performs economic load dispatch (ELD) calculation with
% transmission line losses using a modified approach.

%% Initialize data and parameters
clc;
clear;
close all;

% Extract generator data
PG_data = [
 0.00142, 7.20, 510, 200, 450, 150, 0.00010;
 0.00194, 7.85, 310, 150, 350, 100, 0.00015;
 0.00284, 8.12, 335, 100, 225, 50, 0.00020
];

% Extract data
N = length(PG_data(:,1));
a = PG_data(:,1);
b = PG_data(:,2);
c = PG_data(:,3);
pg_min = PG_data(:,4);
pg_max = PG_data(:,5);
ploss_coeff = PG_data(:,7);

% Set parameters
pd = 975;  % Demand
tolerance = 0.00001;  % Convergence tolerance
max_iterations = 100;

% Initialize generators at minimum values to start
pg = pg_min;

% Initial calculation of losses
ploss = zeros(N, 1);
for i = 1:N
    ploss(i) = ploss_coeff(i) * (pg(i)^2);
end

%% Iterative Lambda Search Method
% Start with a reasonable lambda range
lambda_min = 8;
lambda_max = 12;
lambda = (lambda_min + lambda_max) / 2;

fprintf('Initial conditions:\n');
fprintf('Demand (Pd) = %.2f MW\n', pd);
fprintf('Initial generation: %.2f MW\n', sum(pg));
fprintf('Initial losses: %.2f MW\n', sum(ploss));

% Main optimization loop
iteration = 1;
converged = false;

while ~converged && iteration <= max_iterations
    fprintf('\n--- Iteration %d ---\n', iteration);
    
    % Calculate penalty factors
    pf = 1 ./ (1 - 2 * pg .* ploss_coeff);
    
    % Update generation based on lambda and penalty factors
    for i = 1:N
        % Economic dispatch equation with penalty factor
        pg_unconstrained = (lambda/pf(i) - b(i)) / (2 * a(i));
        
        % Apply generator limits
        pg(i) = max(pg_min(i), min(pg_max(i), pg_unconstrained));
    end
    
    % Calculate losses with updated generation
    total_loss = 0;
    for i = 1:N
        ploss(i) = ploss_coeff(i) * (pg(i)^2);
        total_loss = total_loss + ploss(i);
    end
    
    % Check power balance
    power_balance = sum(pg) - total_loss - pd;
    
    fprintf('Lambda = %.6f\n', lambda);
    fprintf('Total generation: %.4f MW\n', sum(pg));
    fprintf('Total losses: %.4f MW\n', total_loss);
    fprintf('Power balance: %.4f MW\n', power_balance);
    
    % Check convergence
    if abs(power_balance) < tolerance
        converged = true;
        fprintf('Converged! Power balance within tolerance.\n');
    else
        % Binary search to adjust lambda
        if power_balance > 0
            % Generation exceeds demand + losses, increase lambda to reduce generation
            lambda_min = lambda;
        else
            % Generation less than demand + losses, decrease lambda to increase generation
            lambda_max = lambda;
        end
        
        lambda = (lambda_min + lambda_max) / 2;
    end
    
    iteration = iteration + 1;
end

%% Display final results
fprintf('\n=== FINAL RESULTS ===\n');
fprintf('Optimal lambda = %.6f\n', lambda);

for i = 1:N
    incremental_cost = 2 * a(i) * pg(i) + b(i);
    fprintf('Generator %d: Pg = %.4f MW, Incremental Cost = %.4f $/MWh\n', ...
            i, pg(i), incremental_cost);
end

fprintf('Total generation: %.4f MW\n', sum(pg));
fprintf('Total losses: %.4f MW\n', sum(ploss));
fprintf('Generation - Losses = %.4f MW\n', sum(pg) - sum(ploss));
fprintf('Demand = %.4f MW\n', pd);
fprintf('Power balance check: %.6f MW\n', sum(pg) - sum(ploss) - pd);

%% Calculate total generation cost
total_cost = 0;
for i = 1:N
    % Cost function: a*P^2 + b*P + c
    gen_cost = a(i)*(pg(i)^2) + b(i)*pg(i) + c(i);
    total_cost = total_cost + gen_cost;
end
fprintf('Total generation cost: %.2f $/h\n', total_cost);

%% Plot results
figure('Name', 'Economic Load Dispatch Results', 'Position', [100, 100, 800, 600]);

% Generator outputs
subplot(2, 2, 1);
bar(pg);
grid on;
xlabel('Generator Number');
ylabel('Power Output (MW)');
title('Optimal Generator Outputs');
xticks(1:N);
for i = 1:N
    text(i, pg(i)+10, sprintf('%.1f MW', pg(i)), 'HorizontalAlignment', 'center');
end

% Incremental costs
subplot(2, 2, 2);
inc_costs = zeros(N, 1);
for i = 1:N
    inc_costs(i) = 2 * a(i) * pg(i) + b(i);
end
bar(inc_costs);
grid on;
xlabel('Generator Number');
ylabel('Incremental Cost ($/MWh)');
title('Generator Incremental Costs');
xticks(1:N);

% Penalty factors
subplot(2, 2, 3);
pf = 1 ./ (1 - 2 * pg .* ploss_coeff);
bar(pf);
grid on;
xlabel('Generator Number');
ylabel('Penalty Factor');
title('Generator Penalty Factors');
xticks(1:N);

% Power balance
subplot(2, 2, 4);
pie([pd, sum(ploss)], {'Demand', 'Losses'});
title(sprintf('Power Balance (Total Gen = %.1f MW)', sum(pg)));

fprintf('\nOptimization complete.\n');