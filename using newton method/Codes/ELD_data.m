%% ELD_data.m - Economic Load Dispatch Data
% This file contains the data for the Economic Load Dispatch problem
% including generator parameters and system constraints.

% Generator parameters:
% Column 1: a - Quadratic cost coefficient ($/MW^2h)
% Column 2: b - Linear cost coefficient ($/MWh)
% Column 3: c - Constant cost coefficient ($/h)
% Column 4: pg_min - Minimum generation limit (MW)
% Column 5: pg_max - Maximum generation limit (MW)
% Column 6: Initial generation (MW) - not used in the program
% Column 7: ploss_coeff - Loss coefficient for each generator

% Generator data: [a, b, c, pg_min, pg_max, pg_initial, ploss_coeff]
PG_data = [
    0.00142, 7.20, 510, 200, 450, 150, 0.00010;
    0.00194, 7.85, 310, 150, 350, 100, 0.00015;
    0.00284, 8.12, 335, 100, 2250, 50, 0.00020
];

% Note: The actual loss formula is typically represented using B-coefficients
% in the full B-matrix formulation. This simplified version uses individual
% loss coefficients for each generator, so the loss is approximated as:
% ploss_i = ploss_coeff_i * (pg_i)^2

% Vraj did it  