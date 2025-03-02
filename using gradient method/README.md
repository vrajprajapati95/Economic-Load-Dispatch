# Economic Load Dispatch with Transmission Line Losses

## Overview
This MATLAB implementation solves the Economic Load Dispatch (ELD) problem using the Reduced Gradient optimization method. The program optimally distributes power generation among multiple generators to meet load demand while minimizing total operating cost, considering transmission line losses and generator operating constraints.

## Author
Vraj Prajapati (March 2025)

## Problem Description
Economic Load Dispatch is a fundamental optimization problem in power systems engineering where the objective is to determine the optimal power output of each generator in a power system to meet the total load demand at minimum operating cost. This implementation specifically addresses:

1. Quadratic cost functions for each generator
2. Transmission line losses using B-coefficient loss formula
3. Generator capacity constraints (minimum and maximum output)
4. System power balance (generation = demand + losses)

## Mathematical Formulation

### Objective Function
Minimize the total generation cost:
```
Min CT = ∑(ai × PGi² + bi × PGi + ci)
```
where:
- CT is the total generation cost ($/h)
- ai, bi, ci are the cost coefficients for generator i
- PGi is the power output of generator i

### Constraints
1. **Power Balance**:
   ```
   ∑PGi = PD + PL
   ```
   where:
   - PD is the total system demand
   - PL is the total transmission line losses

2. **Generator Limits**:
   ```
   PGi_min ≤ PGi ≤ PGi_max
   ```

3. **Transmission Loss Model**:
   ```
   PL = ∑PGi × B_ii × PGi
   ```
   where:
   - B_ii is the loss coefficient for generator i

## Solution Methodology
The implementation uses the Reduced Gradient method, which is an efficient optimization technique for solving constrained optimization problems. The key steps include:

1. **Initialization**: 
   - Start with a feasible solution
   - Estimate initial transmission losses
   - Calculate initial penalty factors

2. **Iteration Process**:
   - Select one generator as dependent (swing generator)
   - Calculate gradients for independent generators
   - Update generator outputs using gradient descent
   - Enforce generator limits
   - Update the dependent generator to maintain power balance
   - Recalculate losses and penalty factors
   - Check for convergence

3. **Final Adjustment**:
   - Make final adjustments to ensure exact power balance
   - Verify all constraints are satisfied

## Implementation Details

### Files
- **reduced_gradient_function.m**: Core optimization algorithm
- **main_script.m**: Main program that sets up the problem and calls the optimization function

### Input Data
The program uses the following input data format:
```
PG_data = [a, b, c, pg_min, pg_max, initial_guess, ploss_coeff]
```
where:
- a, b, c: Cost function coefficients (Cost = a·PG² + b·PG + c)
- pg_min, pg_max: Minimum and maximum generation limits
- initial_guess: Initial generator output guess (not used in current implementation)
- ploss_coeff: B-coefficients for transmission loss calculation

### Algorithm Parameters
- **error_tolerance_reduced_gradient**: Convergence tolerance for gradients
- **error_tolerance_ploss_diff**: Convergence tolerance for transmission losses
- **lambda**: Initial Lagrange multiplier
- **alpha**: Step size for gradient descent (adaptive)
- **max_iterations**: Maximum number of iterations

## Features
- **Adaptive Step Size**: Automatically adjusts step size to improve convergence
- **Intelligent Initialization**: Starts with a feasible solution
- **Limit Handling**: Efficiently redistributes power when generators hit limits
- **Convergence Monitoring**: Tracks multiple convergence criteria
- **Visualization**: Generates plots showing:
  - Final generation distribution vs. limits
  - Cost curves and operating points
  - Incremental cost curves and operating points

## Output Information
The program provides detailed output including:
- Optimal power output for each generator
- Total system generation, demand, and losses
- Power balance verification
- Individual and total generation costs
- Incremental costs at operating points
- Visualization of results

## Example Case
The default example consists of 3 generators with the following characteristics:
- System demand: 975 MW
- Generator 1: 200-450 MW, Cost = 0.004·PG² + 5.3·PG + 500
- Generator 2: 150-350 MW, Cost = 0.006·PG² + 5.5·PG + 400
- Generator 3: 100-225 MW, Cost = 0.009·PG² + 5.8·PG + 200

## How to Use
1. Open MATLAB
2. Set up your generator data in the format described above
3. Specify the system demand
4. Run the main script
5. Review the console output and generated plots

## Advanced Options
- Modify convergence tolerance parameters for precision vs. speed
- Adjust the step size parameter for convergence behavior
- Change the maximum iterations for complex cases
- Modify generator data to solve different scenarios

## Technical Notes
- The dependent generator (swing generator) is selected automatically
- Penalty factors account for the effect of losses on incremental costs
- The algorithm handles infeasible cases with appropriate warnings
- The reduced gradient method guarantees optimality when converged

## Requirements
- MATLAB (R2018a or newer recommended)
- Optimization Toolbox (optional, not required)

## References
1. Wood, A.J., Wollenberg, B.F., & Sheblé, G.B. (2013). Power Generation, Operation, and Control. Wiley.
2. Saadat, H. (1999). Power System Analysis. McGraw-Hill.
3. Grainger, J.J., & Stevenson, W.D. (1994). Power System Analysis. McGraw-Hill.
