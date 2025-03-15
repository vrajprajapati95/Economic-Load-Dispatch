# Economic Load Dispatch with Transmission Loss Optimization

## Overview

This repository contains MATLAB implementations of various algorithms for solving the Economic Load Dispatch (ELD) problem with transmission line losses. Economic Load Dispatch is a critical optimization problem in power systems that aims to distribute power generation among available units to minimize total operating costs while meeting system constraints.

The implementation includes three primary methods for solving the ELD problem:
1. **Reduced Gradient Method**
2. **Newton's Method**
3. **Lambda Iteration Method**

Each method has different characteristics in terms of convergence speed, robustness, and accuracy.

## Problem Description

The Economic Load Dispatch problem determines the optimal power output for each generating unit to:
- Minimize the total generation cost
- Meet the total power demand
- Account for transmission losses
- Respect generator operating limits

### Mathematical Formulation

The objective function is to minimize the total generation cost:

```
Minimize: 
CT = ∑(ai×PGi² + bi×PGi + ci) for i=1 to N
```

Subject to:
- Power balance constraint: ∑PGi = PD + PL
- Generator capacity constraints: PGmin ≤ PGi ≤ PGmax
- Transmission loss calculation: PL = ∑∑PGi×Bij×PGj

Where:
- CT: Total generation cost
- PGi: Power output of generator i
- ai, bi, ci: Cost coefficients for generator i
- PD: Total power demand
- PL: Total transmission losses
- Bij: B-coefficients for transmission loss calculation

## Solution Methods

### 1. Reduced Gradient Method

The main implementation is in `main_code.m` which uses the `reduced_gradient_function.m`. This method:

- Optimizes the generation dispatch using gradient-based optimization
- Handles generator limits with a specialized constraint handling approach
- Uses penalty factors to account for transmission losses
- Dynamically adjusts dependent generators to maintain power balance
- Features adaptive step size to improve convergence

#### Key Features
- Robust handling of generator limits
- Adaptive step size adjustment
- Detailed power balance monitoring
- Iterative refinement of loss calculations
- Visualization of results with cost curves and generation distribution

### 2. Newton's Method

Implemented in `newton_method_main.m` and `newton_method_function.m`, this method:

- Uses a second-order optimization approach (Newton's method)
- Creates and solves a Jacobian matrix at each iteration
- Generally offers faster convergence for well-conditioned problems
- Provides direct computation of the Lagrange multiplier (system marginal cost)

#### Key Features
- Quadratic convergence near the solution
- Direct calculation of system marginal cost
- Jacobian-based optimization
- Automatic adjustment for feasibility

### 3. Lambda Iteration Method

Implemented in `lambda_iteration_main_code.m` and `lambda_iteration_function.m`, this method:

- Iteratively adjusts the incremental cost (lambda) until power balance is achieved
- Uses a straightforward approach based on the equal incremental cost principle
- Applies penalty factors to account for transmission losses

#### Key Features
- Conceptually simple implementation
- Based directly on the equal incremental cost criterion
- Iterative refinement of lambda and loss calculation

## Usage

### Prerequisites
- MATLAB (R2018b or newer recommended)

### Running the Code
1. Clone the repository
2. Open MATLAB and navigate to the repository directory
3. Run one of the main files:
   - For Reduced Gradient Method: `main_code.m`
   - For Newton's Method: `newton_method_main.m`
   - For Lambda Iteration Method: `lambda_iteration_main_code.m`

### Input Data Format
The generator data is structured as follows:
```
PG_data = [a, b, c, pg_min, pg_max, pgi_guess, ploss_coeff]
```
Where:
- a, b, c: Cost function coefficients (Cost = a*PG^2 + b*PG + c)
- pg_min, pg_max: Minimum and maximum generation limits
- pgi_guess: Initial generator output guess
- ploss_coeff: B-coefficients for transmission loss calculation

### Sample Data
The repository includes a test case with 3 generators and the following parameters:
- Three generators with quadratic cost functions
- System demand of 975 MW
- Individual B-loss coefficients for each generator

## Results and Visualization

The code generates detailed outputs including:
- Optimal power output for each generator
- Total system cost
- Incremental costs at operating points
- Total transmission losses
- Power balance verification

### Visualization
- Bar charts showing generator outputs against their limits
- Cost curves for each generator
- Incremental cost curves

## Performance Comparison

The three methods have different characteristics:

1. **Reduced Gradient Method**:
   - Good overall performance
   - Reliable convergence even with poor initial conditions
   - Handles constraints effectively
   - May require more iterations than Newton's method

2. **Newton's Method**:
   - Fast convergence near the solution
   - Requires good initial conditions
   - More computationally intensive per iteration
   - May struggle with ill-conditioned problems

3. **Lambda Iteration Method**:
   - Simple implementation
   - Easy to understand
   - May require more iterations to converge
   - Good for educational purposes and understanding the equal incremental cost principle

## Technical Implementation Details

### Penalty Factors
All methods use penalty factors to account for the effect of transmission losses on generator dispatch. The penalty factor for generator i is calculated as:
```
PFi = 1/(1-∂PL/∂PGi)
```

### Power Balance Adjustment
The implementations include mechanisms to:
- Enforce the power balance constraint
- Handle violations of generator limits
- Redistribute power when necessary
- Iteratively refine the transmission loss calculation

### Convergence Criteria
Convergence is achieved when:
- The maximum absolute value of the gradient is below the tolerance
- The power balance error is below the tolerance
- The change in transmission losses between iterations is below the tolerance

## Author
Vraj Prajapati

## License
This project is open-source. Feel free to use and modify the code with appropriate attribution.

## Acknowledgements
This implementation is based on classic optimization techniques applied to the Economic Load Dispatch problem, which has been extensively studied in power system literature.
