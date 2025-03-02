# Economic Load Dispatch with Transmission Line Losses

## Overview
This project implements an Economic Load Dispatch (ELD) solution that incorporates transmission line losses using the Reduced Gradient optimization method. The algorithm efficiently distributes electrical load among multiple generators while minimizing total operating cost and accounting for power losses in the transmission system.

## Features
- Solves Economic Load Dispatch considering transmission line losses
- Uses the Reduced Gradient optimization method for minimizing generation costs
- Handles generator operating constraints (minimum and maximum power limits)
- Dynamic penalty factor calculation to account for transmission losses
- Adaptive step size adjustment for improved convergence
- Comprehensive visualization of results with cost curves and generation distribution

## Files
- `main.m` - Main ELD optimization script with visualization capabilities
- `reduced_gradient_function.m` - Implementation of the Reduced Gradient method
- `eld_data.m` - Generator data configuration file

## Data Structure
The generator data is structured as follows:
```
[a, b, c, pg_min, pg_max, pgi_guess, ploss_coeff]
```
Where:
- `a`, `b`, `c`: Cost function coefficients for each generator (Cost = a×PG² + b×PG + c)
- `pg_min`, `pg_max`: Minimum and maximum generation limits (MW)
- `pgi_guess`: Initial generator output guess (not used in current implementation)
- `ploss_coeff`: B-coefficients for transmission loss calculation

## Algorithm Details
The implementation uses a modified Reduced Gradient approach with the following steps:
1. Initialize generator outputs to a feasible solution
2. Calculate transmission losses based on current generation
3. Calculate penalty factors to account for losses
4. Perform Reduced Gradient optimization
   - Calculate gradients for all generators except the dependent one
   - Update generator outputs using gradient descent
   - Maintain power balance by adjusting the dependent generator
   - Apply generator limits and redistribute if necessary
5. Recalculate losses and check convergence
6. Perform final adjustments to ensure exact power balance

## Mathematical Model
- **Objective Function**: Minimize Σ(a₁×PG₁² + b₁×PG₁ + c₁)
- **Constraints**:
  - Power Balance: Σ(PG₁) = PD + PL
  - Generation Limits: PG₁ₘᵢₙ ≤ PG₁ ≤ PG₁ₘₐₓ
  - Transmission Losses: PL = Σ(PG₁ × B₁₁ × PG₁)

## Usage
1. Configure your generation data in the format shown above
2. Set the system demand (`pd`)
3. Run the main script:
```matlab
>> main
```

## Sample Output
The program provides detailed output including:
- Generator outputs and their limits
- Total generation, demand, and losses
- Individual and total generation costs
- Incremental costs at the operating point
- Visual representation of optimal solutions with cost curves

## Results Visualization
The program generates two figures:
1. **Bar chart**: Shows optimal generator outputs compared to their minimum and maximum limits
2. **Cost curves**: Displays:
   - Total cost curves for each generator
   - Incremental cost curves
   - Optimal operating points marked on each curve

## Example Problem
The included example solves an ELD problem with three generators and the following data:
- Three generators with quadratic cost functions
- System demand of 975 MW
- Transmission line loss coefficients for each generator
- Generator limits:
  - G1: 200-450 MW
  - G2: 150-350 MW
  - G3: 100-225 MW

## Dependencies
- MATLAB (developed with R2022b, but should work with earlier versions)
- No additional toolboxes required

## Author
Vraj Prajapati (March 2025)

## References
- Wood, A.J. and Wollenberg, B.F. (1996). Power Generation, Operation, and Control. John Wiley & Sons.
- El-Hawary, M.E. and Christensen, G.S. (1979). Optimal Economic Operation of Electric Power Systems. Academic Press.
