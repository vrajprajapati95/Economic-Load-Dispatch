# Lambda Iteration Method for Economic Load Dispatch

## Overview

This repository contains a MATLAB implementation of the Lambda Iteration Method for solving the Economic Load Dispatch (ELD) problem with transmission line losses. The Lambda Iteration Method is a classical technique based on the equal incremental cost principle that determines the optimal allocation of generation among multiple generators to minimize total operating cost while satisfying system constraints.

## Algorithm Principles

The Lambda Iteration Method is founded on the principle that, at the optimal operating point, all generators should operate at the same incremental cost when adjusted for transmission losses. This principle is derived from the Lagrangian optimization of the ELD problem.

### Core Concept: Equal Incremental Cost

For a system with N generators, the optimal solution satisfies:

```
λ = (2ai×PGi + bi) × PFi for all i=1 to N
```

Where:
- λ (lambda) is the system incremental cost ($/MWh)
- PGi is the power output of generator i
- ai, bi are the cost coefficients of generator i
- PFi is the penalty factor accounting for transmission losses

### Penalty Factors

The penalty factor for each generator accounts for the change in system losses when that generator's output changes:

```
PFi = 1/(1 - ∂PL/∂PGi)
```

Where ∂PL/∂PGi is the incremental transmission loss with respect to generator i's output.

## Algorithm Steps

The Lambda Iteration Method follows these steps:

1. **Initialization**:
   - Set an initial value for λ (system incremental cost)
   - Initialize generator outputs (PG) to feasible values
   - Calculate initial transmission losses
   - Compute initial penalty factors

2. **Iteration Process**:
   ```
   REPEAT
       FOR each generator i:
           Calculate PGi = (λ/PFi - bi)/(2×ai)
           Apply generator limits: 
               If PGi < PGi_min then PGi = PGi_min
               If PGi > PGi_max then PGi = PGi_max
       END FOR
       
       Calculate total generation: PG_total = sum(PGi)
       Update transmission losses (PL) based on new generator outputs
       Calculate mismatch: error = PG_total - (PD + PL)
       
       IF |error| < tolerance THEN
           EXIT (solution found)
       ELSE
           Adjust λ:
               If error > 0, decrease λ
               If error < 0, increase λ
       END IF
   UNTIL convergence or maximum iterations
   ```

3. **Final Solution**:
   - Calculate final generator outputs
   - Compute total cost
   - Verify power balance

## Implementation Details

The implementation consists of two main files:

1. **lambda_iteration_main_code.m**: Main script that:
   - Loads generator data and system parameters
   - Initializes variables
   - Calls the lambda iteration function iteratively
   - Updates penalty factors and loss calculations
   - Checks convergence
   - Displays results

2. **lambda_iteration_function.m**: Function that:
   - Takes current transmission losses and penalty factors as inputs
   - Performs the lambda iteration process to find generator outputs
   - Enforces generator limits
   - Returns updated generator outputs

### B-Loss Coefficient Method

Transmission losses are calculated using the B-coefficient method:

```
PL = sum(PGi² × Bi)
```

Where Bi is the loss coefficient for generator i.

## Convergence Characteristics

The Lambda Iteration Method has the following convergence characteristics:

1. **Linear Convergence**: Typically shows linear convergence behavior
2. **Sensitivity to Initial λ**: The choice of initial lambda can affect convergence speed
3. **Robust for Convex Problems**: Works reliably for convex cost functions
4. **Step Size Impact**: The λ adjustment step size affects both convergence speed and stability

## Advantages and Limitations

### Advantages:
- Conceptually simple and easy to implement
- Directly tied to the economic principle of equal incremental cost
- Works well for smooth, convex cost functions
- Handles inequality constraints (generator limits) effectively

### Limitations:
- May require many iterations for high precision
- May have slower convergence compared to second-order methods
- May struggle with ill-conditioned problems
- Convergence not guaranteed for complex loss functions

## Usage

### Required Input Data:
- Generator cost coefficients (a, b, c)
- Generator minimum and maximum limits
- System demand
- Transmission loss coefficients
- Convergence tolerances

### Running the Code:
1. Ensure the generator data is properly defined
2. Run `lambda_iteration_main_code.m` in MATLAB
3. Monitor convergence progress in the console output
4. Verify results through the final power balance

### Sample Call:
```matlab
% Example values already set in the code
% Run the main script
lambda_iteration_main_code
```

## Mathematical Foundation

The Lambda Iteration Method derives from the Lagrangian function of the ELD problem:

```
L = ∑(ai×PGi² + bi×PGi + ci) + λ(PD + PL - ∑PGi)
```

Taking partial derivatives and solving:

```
∂L/∂PGi = 2ai×PGi + bi - λ(1 - ∂PL/∂PGi) = 0
```

Which leads to:

```
2ai×PGi + bi = λ/(1 - ∂PL/∂PGi) = λ×PFi
```

This is the core equation that the Lambda Iteration Method solves iteratively.

## Author
Vraj Prajapati

## License
This project is open-source. Feel free to use and modify the code with appropriate attribution.
