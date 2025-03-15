function pg = lambda_iteration_function(ploss_temp, pf)

ELD_data
Nof_gen = length(PG_data(:,1));
a = PG_data(:,1);
b = PG_data(:,2);
pg_min = PG_data(:,4);
pg_max = PG_data(:,5);
pd; % demand value
error_tolerance_lambda_iteration; % error value in MW, can be changed in % by changing error formula
lambda = 8; % Ensure lambda is initialized
pg = zeros(1, Nof_gen);

for i = 1:999
    sum_pg = 0;
    for j = 1:Nof_gen
        pg(j) = (lambda / pf(j) - b(j)) / (2 * a(j));
        % Enforce limits
        if pg(j) < pg_min(j)
            pg(j) = pg_min(j);
        elseif pg(j) > pg_max(j)
            pg(j) = pg_max(j);
        end
        sum_pg = sum_pg + pg(j);
    end
    
    error = sum_pg - (pd + ploss_temp);

    % Check convergence
    if abs(error) < error_tolerance_lambda_iteration
        break
    else
        lambda_step = abs(error) / 100; % You can input lambda's step value if required
        if error < 0
            lambda = lambda + lambda_step;
        else
            lambda = lambda - lambda_step;
        end
    end
end
end
