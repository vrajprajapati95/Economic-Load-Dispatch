# Newton's Method for Economic Load Dispatch

## Overview

This repository contains a MATLAB implementation of Newton's Method for solving the Economic Load Dispatch (ELD) problem with transmission line losses. Newton's Method is a powerful second-order optimization technique that offers quadratic convergence characteristics when applied to the ELD problem, making it one of the most efficient approaches for finding optimal generation schedules.

## Algorithm Principles

Newton's Method for ELD is based on a second-order Taylor series approximation of the Lagrangian function. It uses both first derivatives (gradients) and second derivatives (Hessian) to iteratively find the optimal solution. This approach allows for rapid convergence, especially when starting from a good initial point.

### Core Concept: Quadratic Approximation

The method solves the ELD problem by finding the point where the first-order optimality conditions are satisfied:

```
∇L(x) = 0
```

Where L is the Lagrangian function of the ELD problem, and x is the vector of generator outputs and the Lagrange multiplier λ.

## Algorithm Steps

Newton's Method follows these steps:

1. **Initialization**:
   - Set initial values for generator outputs (PG)
   - Initialize Lagrange multiplier λ
   - Calculate initial transmission losses and penalty factors

2. **Iteration Process**:
   ```
   REPEAT
       // Calculate gradient vector (mismatch equations)
       FOR each generator i:
           gradient_vector(i) = (2*a(i)*pg(i) + b(i)) - (λ/pf(i))
       END FOR
       gradient_vector(N+1) = pd + sum(ploss) - sum(pg)  // Power balance equation
       
       // Build Jacobian matrix (second derivatives)
       FOR i = 1 to N:
           jacobian_matrix(i,i) = 2*a(i)  // Diagonal elements
           jacobian_matrix(i,N+1) = -1/pf(i)  // Lambda column
           jacobian_matrix(N+1,i) = (2*ploss_coeff(i)*pg(i)) - 1  // Power balance row
       END FOR
       jacobian_matrix(N+1,N+1) = 0
       
       // Solve Newton's equation for correction vector
       correction_vector = -jacobian_matrix \ gradient_vector
       
       // Update variables with damping if necessary
       λ = λ + damping * correction_vector(N+1)
       FOR i = 1 to N:
           pg(i) = pg(i) + damping * correction_vector(i)
           // Apply generator limits
           IF pg(i) < pg_min(i) THEN pg(i) = pg_min(i)
           IF pg(i) > pg_max(i) THEN pg(i) = pg_max(i)
       END FOR
       
       // Update transmission losses and penalty factors
       Update_Losses_And_Penalty_Factors()
       
       // Check convergence
       IF max(abs(gradient_vector)) < tolerance THEN
           EXIT (solution found)
       END IF
   UNTIL convergence or maximum iterations
   ```

3. **Final Solution**:
   - Apply any final adjustments to ensure power balance
   - Calculate final cost and verify constraints

## Implementation Details

The implementation consists of two main files:

1. **newton_method_main.m**: Main script that:
   - Loads generator data and system parameters
   - Initializes variables with a feasible starting point
   - Calls the Newton's Method function iteratively
   - Updates penalty factors and transmission losses
   - Checks convergence
   - Displays and analyzes results

2. **newton_method_function.m**: Core function that:
   - Builds the gradient vector and Jacobian matrix
   - Solves the Newton system to find the correction vector
   - Updates generator outputs and lambda
   - Enforces generator limits
   - Handles special cases near convergence

### Handling Constraints

Generator limits are enforced after each Newton update by projecting the solution back to the feasible region:

```matlab
if pg(i) < pg_min(i)
    pg(i) = pg_min(i);
elseif pg(i) > pg_max(i)
    pg(i) = pg_max(i);
end
```

This projection approach can slow down convergence when many generators are at their limits, but it ensures feasibility at each iteration.

## Convergence Characteristics

Newton's Method has the following convergence characteristics:

1. **Quadratic Convergence**: Near the solution, the error typically decreases quadratically with each iteration
2. **Sensitivity to Initial Point**: Good initial points lead to faster convergence
3. **Robustness Issues**: May diverge if started far from the solution or if the Jacobian is ill-conditioned
4. **Handling of Constraints**: The projection method for handling constraints can slow convergence

## Mathematical Foundation

Newton's Method for ELD is derived from the Lagrangian function:

```
L = ∑(ai×PGi² + bi×PGi + ci) + λ(PD + PL - ∑PGi)
```

The first-order optimality conditions are:

```
∂L/∂PGi = 2ai×PGi + bi - λ(1 - ∂PL/∂PGi) = 0
∂L/∂λ = PD + PL - ∑PGi = 0
```

Newton's Method solves these equations by iteratively applying:

```
x(k+1) = x(k) - [H(x(k))]^(-1) * ∇L(x(k))
```

Where:
- x is the vector of variables [PG1, PG2, ..., PGN, λ]
- ∇L is the gradient vector of the Lagrangian
- H is the Hessian matrix of the Lagrangian

## Advantages and Limitations

### Advantages:
- Fast convergence (quadratic) near the solution
- Fewer iterations compared to first-order methods
- Provides accurate lambda values (system marginal cost)
- Handles complex cost functions effectively

### Limitations:
- Requires computation and inversion of the Jacobian matrix at each iteration
- More computationally expensive per iteration than first-order methods
- May diverge if started far from the solution
- Can be sensitive to ill-conditioning in the Jacobian matrix

## Usage

### Required Input Data:
- Generator cost coefficients (a, b, c)
- Generator minimum and maximum limits
- System demand
- Transmission loss coefficients
- Convergence tolerances

### Running the Code:
1. Ensure the generator data is properly defined
2. Run `newton_method_main.m` in MATLAB
3. Monitor convergence progress in the console output
4. Verify results through the final power balance

### Example Output:
```
Initial: Gen: 975.00 MW, Demand: 975.00 MW, Loss: 31.46 MW, Balance: -31.46 MW
Iter  1: Gen: 983.73 MW, Loss: 31.92 MW, Balance: -23.19 MW, Lambda: 6.127836
Iter  2: Gen: 999.50 MW, Loss: 33.18 MW, Balance: -8.68 MW, Lambda: 6.193650
...
Converged after 8 iterations!

Final Results:
Generator    Output (MW)    Min (MW)    Max (MW)    Marginal Cost ($/MWh)
1            445.28         200.00      450.00      8.861440
2            299.64         150.00      350.00      9.097760
3            221.80         100.00      225.00      9.792480

Total generation: 966.72 MW
Total demand: 975.00 MW
Total losses: 31.72 MW
Power balance: 0.000012 MW
Final lambda (system marginal cost): 6.260518 $/MWh
```

## Special Considerations

### Damping Factor
A damping factor is often used to improve convergence stability:

```matlab
damping = 1.0;  % Can be reduced if convergence is difficult
lambda = lambda + damping * correction_vector(N+1);
```

### Ill-Conditioning
For systems with wide ranges of generator parameters, the Jacobian matrix may become ill-conditioned. Using MATLAB's backslash operator (`\`) instead of explicitly inverting the matrix improves numerical stability:

```matlab
correction_vector = -jacobian_matrix \ gradient_vector;  % More stable than inv()
```

### Final Adjustments
A final adjustment step ensures power balance is maintained:

```matlab
if abs(required_generation - current_generation) > error_tolerance
    // Adjust generation to match demand plus losses
    ...
end
```

## Author
Vraj Prajapati

## License
This project is open-source. Feel free to use and modify the code with appropriate attribution.
