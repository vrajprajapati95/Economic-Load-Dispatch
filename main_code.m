%% Economic Load Dispatch with Transmission Line Losses
% This script performs economic load dispatch (ELD) calculation with
% transmission line losses using Newton's method.
%
% Author: Vraj Prajapati
% Date: March 2025
%
% Description:
%   The program minimizes total generation cost while satisfying power
%   balance constraints including losses.

%% Initialize data and parameters
clc;
clear;
close all;

% Load economic load dispatch data
ELD_data; % Load economic load dispatch data from external file

% Set parameters
error_tolerance_ploss_diff = 0.001;
error_tolerance_newton_method = 0.001;
max_outer_iterations = 50;  % Limit the outer iterations

% Extract data
N = length(PG_data(:,1));
a = PG_data(:,1);
b = PG_data(:,2);
c = PG_data(:,3);
pg_min = PG_data(:,4);
pg_max = PG_data(:,5);
ploss_coeff = PG_data(:,7);

% Initial values
pd = 975;  % Demand
lambda = 8;  % Initial lambda guess

% Better initial guess for generator outputs
% Start with a feasible solution at average between min and max
pg = zeros(N, 1);
for i = 1:N
    pg(i) = (pg_min(i) + pg_max(i)) / 2;
end

% Adjust to meet demand
total_gen = sum(pg);
scaling_factor = pd / total_gen; % alpha value
pg = pg * scaling_factor;

% Make sure initial guess respects limits
for i = 1:N
    pg(i) = max(pg_min(i), min(pg_max(i), pg(i)));
end

% Initialize power loss
ploss_old = zeros(N, 1);
for i = 1:N
    ploss_old(i) = (pg(i)^2) * ploss_coeff(i);
end

% Initial penalty factors
pf = 1 ./ (1 - 2 * pg .* ploss_coeff);

%% Display initial conditions
% Display initial conditions
fprintf('Initial conditions:\n');
fprintf('Demand (Pd) = %.2f MW\n', pd);
for i = 1:N
    fprintf('Generator %d: Pg = %.2f MW (%.2f to %.2f MW)\n', ...
            i, pg(i), pg_min(i), pg_max(i));
end
fprintf('Initial power loss = %.4f MW\n', sum(ploss_old));
fprintf('Initial penalty factors: %.4f, %.4f, %.4f\n', pf(1), pf(2), pf(3));
fprintf('--------------------------------------------------\n');

%% Main optimization loop
% Outer iteration loop
for iteration = 1:max_outer_iterations
    fprintf('\nOuter Iteration %d:\n', iteration);
    fprintf('Total generation: %.4f MW\n', sum(pg));
    fprintf('Total losses: %.4f MW\n', sum(ploss_old));
    
    % Call Newton's method function
    [pg_new, lambda_new] = newton_method_function(N, a, b, pg, ploss_old, ...
                            ploss_coeff, lambda, pd, pg_min, pg_max, ...
                            error_tolerance_newton_method);
    
    % Compute new power loss
    ploss_new = zeros(N, 1);
    for i = 1:N
        ploss_new(i) = ploss_coeff(i) * (pg_new(i)^2);
    end
    
    % Calculate difference in power loss
    diff_ploss = sum(ploss_new) - sum(ploss_old);
    
    % Check output
    fprintf('After Newton method:\n');
    fprintf('Lambda = %.6f\n', lambda_new);
    for i = 1:N
        fprintf('Generator %d: Pg = %.4f MW\n', i, pg_new(i));
    end
    fprintf('Total generation: %.4f MW\n', sum(pg_new));
    fprintf('New total losses: %.4f MW\n', sum(ploss_new));
    fprintf('Loss difference: %.6f MW\n', diff_ploss);
    
    % Update for next iteration
    ploss_old = ploss_new;
    pg = pg_new;
    lambda = lambda_new;
    
    % Check for convergence
    if abs(diff_ploss) < error_tolerance_ploss_diff
        fprintf('\nConverged! Loss difference < %.6f\n', error_tolerance_ploss_diff);
        break;
    end
end

%% Display final results
% Final results
fprintf('\n=== FINAL RESULTS ===\n');
fprintf('Optimal lambda = %.6f\n', lambda);
for i = 1:N
    incremental_cost = 2 * a(i) * pg(i) + b(i);
    fprintf('Generator %d: Pg = %.4f MW, Incremental Cost = %.4f $/MWh\n', ...
            i, pg(i), incremental_cost);
end
fprintf('Total generation: %.4f MW\n', sum(pg));
fprintf('Total losses: %.4f MW\n', sum(ploss_old));
fprintf('Generation - Losses = %.4f MW\n', sum(pg) - sum(ploss_old));
fprintf('Demand = %.4f MW\n', pd);
fprintf('Power balance check: %.6f MW\n', sum(pg) - sum(ploss_old) - pd);

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
pf = 1 ./ (1 - 2 * pg .* ploss_coeff); % Update penalty factors with final values
bar(pf);
grid on;
xlabel('Generator Number');
ylabel('Penalty Factor');
title('Generator Penalty Factors');
xticks(1:N);

% Power balance
subplot(2, 2, 4);
pie([sum(pg)-sum(ploss_old), sum(ploss_old)], {'Net Load', 'Losses'});
title(sprintf('Power Balance (Demand = %.1f MW)', pd));

% Save figures
saveas(gcf, 'ELD_Results.fig');
saveas(gcf, 'ELD_Results.png');

%% Export results to Excel
results_table = table((1:N)', pg, inc_costs, pf, ...
                     'VariableNames', {'Generator', 'Power_MW', 'Incremental_Cost', 'Penalty_Factor'});
writetable(results_table, 'ELD_Results.xlsx', 'Sheet', 'Generator_Results');

fprintf('\nResults saved to ELD_Results.xlsx\n');

% Vraj did it  