# Economic Load Dispatch using Reduced Gradient Method

## Overview

This project implements an Economic Load Dispatch (ELD) solver using the Reduced Gradient optimization method, with consideration of transmission line losses. The implementation is written in MATLAB and provides an efficient solution to the ELD problem, which is fundamental to power system operation and planning.

## Problem Description

Economic Load Dispatch (ELD) is the process of allocating generation among available units to meet the system load at minimum operating cost while satisfying various operational constraints. In this implementation, we consider:

1. Multiple generators with quadratic cost functions
2. Minimum and maximum generation limits for each generator
3. Transmission line losses using loss coefficients
4. Power balance constraints

The objective function is to minimize the total generation cost:

```
Min Σ(ai * PGi² + bi * PGi + ci)
```

Subject to:
- Power balance: Σ PGi = PD + PL (where PL represents transmission losses)
- Generation limits: PGi_min ≤ PGi ≤ PGi_max
- Transmission losses calculated using B-coefficients: PL = Σ(Bi * PGi²)

## The Reduced Gradient Method

The Reduced Gradient Method is an optimization technique for solving constrained nonlinear programming problems. In the context of ELD, it works by:

1. Choosing a dependent generator (typically the most flexible one)
2. Expressing the dependent generator's output in terms of other generators
3. Computing the reduced gradient by considering how changes in independent generators affect the objective function and the dependent generator
4. Moving in the negative gradient direction while maintaining feasibility
5. Iterating until convergence

Key concepts in the implementation:

- **Penalty Factors**: Account for the effect of losses on incremental costs, calculated as 1/(1-∂PL/∂PGi)
- **Lagrange Multiplier (λ)**: Represents the system incremental cost at the optimal solution
- **Gradient Vector**: Indicates the direction of steepest descent in the feasible region

## Code Structure

The project consists of two main MATLAB files:

1. **main_code.m**: The main script that sets up the ELD problem, initializes parameters, runs the optimization process, and displays/plots results.
2. **reduced_gradient_function.m**: The core optimization function implementing the Reduced Gradient method.

### Main Script Features

- Problem setup with generator cost coefficients, limits, and loss coefficients
- Intelligent initialization to ensure a feasible starting point
- Iteration process with adaptive step size adjustment
- Comprehensive output including generation values, costs, and incremental costs
- Visualization of results with bar charts and cost curves

### Solution Algorithm

The solution process follows these steps:

1. **Initialization**:
   - Set up generator parameters, demand, and loss coefficients
   - Initialize generator outputs to a feasible point
   - Calculate initial penalty factors

2. **Main Iteration Loop**:
   - Call the reduced gradient function to update generator outputs
   - Recalculate penalty factors and transmission losses
   - Check convergence criteria (loss difference, power balance, generator limits)
   - Adjust step size adaptively to improve convergence

3. **Final Adjustment**:
   - Ensure power balance by making small adjustments to generator outputs
   - Recalculate losses and costs

4. **Results Analysis**:
   - Calculate and display final generator outputs, costs, and incremental costs
   - Generate plots for visualization

## Using the Code

### Prerequisites
- MATLAB (R2018b or newer recommended)

### Running the Program
1. Save both files (`main_code.m` and `reduced_gradient_function.m`) in the same directory
2. Open MATLAB and navigate to the directory
3. Run the main script by typing `main_code` in the MATLAB command window

### Customizing the Problem
To modify the problem parameters, edit the following in `main_code.m`:

- `PG_data`: Generator cost coefficients, limits, and loss coefficients
- `pd`: System demand in MW
- Convergence tolerance and other optimization parameters

## Mathematical Background

### Cost Function
Each generator's cost function is modeled as a quadratic function:
```
F(PGi) = ai * PGi² + bi * PGi + ci
```

### Incremental Cost
The incremental cost (marginal cost) for each generator is:
```
IC(PGi) = 2 * ai * PGi + bi
```

### Transmission Losses
Transmission losses are calculated using the simplified B-coefficient method:
```
PL = Σ(Bi * PGi²)
```

### Optimality Conditions
At the optimal solution, the product of incremental cost and penalty factor is equal for all generators operating within their limits:
```
(2 * ai * PGi + bi) * PFi = λ
```
where λ is the system incremental cost (Lagrange multiplier) and PFi is the penalty factor for generator i.

## Features of This Implementation

1. **Robust Initialization**: Starts from a feasible point to improve convergence
2. **Adaptive Step Size**: Adjusts step size during iterations to balance convergence speed and stability
3. **Handling Generator Limits**: Properly manages generators at their limits
4. **Final Adjustment**: Ensures power balance in the final solution
5. **Comprehensive Results**: Provides detailed output and visualization

## Results Interpretation

The program outputs:
- Optimal generator dispatches
- Total and individual generator costs
- System incremental cost (λ)
- Transmission losses
- Generation distribution and cost curves

The bar chart shows the optimal generator outputs relative to their limits, while the cost curves illustrate how the optimal point relates to each generator's cost function.

## Author

Vraj Prajapati (March 2025)
