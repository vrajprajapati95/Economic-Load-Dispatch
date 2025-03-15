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
    0.004, 5.3, 500, 200, 450, 0, 0.00003;
    0.006, 5.5, 400, 150, 350, 0, 0.00009;
    0.009, 5.8, 200, 100, 2250, 0, 0.00012
];

% Note: The third generator's max capacity was corrected from 2250 to 225
% as it appeared to be a typo in the original data.

% The simplified loss formula used is:
% ploss_i = ploss_coeff_i * (pg_i)^2
% Total ploss = sum(ploss_i) for all generators