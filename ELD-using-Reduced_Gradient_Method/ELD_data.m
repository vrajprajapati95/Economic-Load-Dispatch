% Economic Load Dispatch Data Setup
% This script contains the data for the Economic Load Dispatch problem
% 
% Generator data format:
% [a, b, c, low_limit, high_limit, pgi_guess, ploss_coeff]
%   a, b, c - Cost function coefficients (Cost = a*PG^2 + b*PG + c)
%   low_limit - Minimum generation limit (MW)
%   high_limit - Maximum generation limit (MW)
%   pgi_guess - Initial generation guess (not used in this implementation)
%   ploss_coeff - Loss coefficient for the B-coefficient matrix

% Generator data
PG_data = [
    0.004, 5.3, 500, 200, 450, 0, 0.00003;
    0.006, 5.5, 400, 150, 350, 0, 0.00009;
    0.009, 5.8, 200, 100, 2250, 0, 0.00012
];

% System load demand in MW
pd=1000;

% Cost function:
% C_i(PG_i) = a_i * PG_i^2 + b_i * PG_i + c_i
% where:
%   a_i is the quadratic cost coefficient ($/MW²h)
%   b_i is the linear cost coefficient ($/MWh)
%   c_i is the constant cost coefficient ($/h)
%   PG_i is the power output of generator i (MW)

% Transmission line loss model:
% PL = Σ PG_i * B_ii * PG_i
% where:
%   B_ii is the loss coefficient for generator i
%   This is a simplified version of the B-coefficient matrix
%   The full matrix would include cross-terms B_ij

% For pgdata columns:
% a,b,c,low_limit,high_limit,pgi_guess,plosscoeff

% Vraj did it