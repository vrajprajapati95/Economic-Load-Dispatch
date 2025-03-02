# Economic Load Dispatch with Transmission Line Losses

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A MATLAB implementation of Economic Load Dispatch (ELD) with transmission line losses using optimization methods. This project efficiently distributes electrical load among multiple generators while minimizing total operating cost and accounting for power losses in the transmission system.

## Overview

Economic Load Dispatch is a critical aspect of power system operation that determines the optimal output of multiple electricity generators to meet the system load at the lowest possible cost, subject to transmission and operational constraints.

This implementation includes:
- Cost optimization with quadratic cost functions
- Transmission line loss modeling
- Generator operating limits (min/max constraints)
- Penalty factor calculations
- Multiple optimization approaches (Reduced Gradient method and Newton's method)
- Comprehensive visualization of results

## Features

- **Cost Minimization**: Minimizes total generation cost while meeting demand
- **Loss Consideration**: Incorporates transmission line losses in the optimization
- **Multiple Optimization Methods**:
  - Reduced Gradient optimization method
  - Newton's method for improved convergence
- **Adaptive Parameters**: Dynamic penalty factor calculation and step size adjustment
- **Visualization**: Generates plots for generator outputs, cost curves, and incremental costs
- **Reporting**: Comprehensive output of results for analysis

## Requirements

- MATLAB (R2019b or newer recommended)
- No additional toolboxes strictly required (Optimization Toolbox recommended but optional)

## Files

### Main Implementation:
- `main.m` / `ELD_main.m` - Main ELD optimization script with visualization capabilities
- `reduced_gradient_function.m` - Implementation of the Reduced Gradient method
- `newton_method_function.m` - Implementation of Newton's method for ELD
- `eld_data.m` / `ELD_data.m` - Generator data configuration file

## Data Structure

The generator data is structured as follows:

```
[a, b, c, pg_min, pg_max, pgi_guess, ploss_coeff]
```

Where:
- `a`, `b`, `c`: Cost function coefficients for each generator (Cost = a×PG² + b×PG + c)
- `pg_min`, `pg_max`: Minimum and maximum generation limits (MW)
- `pgi_guess`: Initial generator output guess
- `ploss_coeff`: B-coefficients for transmission loss calculation

## Mathematical Model

- **Objective Function**: Minimize Σ(a₁×PG₁² + b₁×PG₁ + c₁)
- **Constraints**:
  - Power Balance: Σ(PG₁) = PD + PL
  - Generation Limits: PG₁ₘᵢₙ ≤ PG₁ ≤ PG₁ₘₐₓ
  - Transmission Losses: PL = Σ(PG₁ × B₁₁ × PG₁)

## Algorithm Details

### Reduced Gradient Method:
1. Initialize generator outputs to a feasible solution
2. Calculate transmission losses based on current generation
3. Calculate penalty factors to account for losses
4. Perform Reduced Gradient optimization:
   - Calculate gradients for all generators except the dependent one
   - Update generator outputs using gradient descent
   - Maintain power balance by adjusting the dependent generator
   - Apply generator limits and redistribute if necessary
5. Recalculate losses and check convergence
6. Perform final adjustments to ensure exact power balance

### Newton's Method:
1. Initialize generator outputs to a feasible solution
2. Calculate transmission losses based on current generation
3. Calculate penalty factors to account for losses
4. Perform Newton's method optimization:
   - Compute Hessian matrix and gradient vector
   - Update generator outputs using Newton's step
   - Maintain power balance and apply generator limits
5. Check convergence and iterate until solution is found

## Usage

1. Configure your generation data in the format shown above
2. Set the system demand (`pd`)
3. Run the main script:

```matlab
>> main  % or ELD_main depending on which implementation you use
```

## Sample Output

The program provides detailed output including:
- Generator outputs and their limits
- Total generation, demand, and losses
- Individual and total generation costs
- Incremental costs at the operating point
- Visual representation of optimal solutions with cost curves

### Example Results

Example output for a three-generator system with 975 MW demand:

| Generator | Power Output (MW) | Incremental Cost ($/MWh) | Penalty Factor |
|-----------|-------------------|--------------------------|----------------|
| 1         | ~393              | ~12.9                    | ~1.08          |
| 2         | ~334              | ~13.8                    | ~1.12          |
| 3         | ~259              | ~14.8                    | ~1.15          |

Total generation: ~986 MW  
Total losses: ~11 MW  
Total cost: ~8,255 $/h

## Results Visualization

The program generates figures that show:
1. **Bar chart**: Optimal generator outputs compared to their minimum and maximum limits
2. **Cost curves**: 
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

## Customization

To use this code with different systems:
1. Modify the `eld_data.m`/`ELD_data.m` file with your generator parameters
2. Adjust the demand value in the main script
3. Tune the convergence parameters if necessary

## Author

Vraj Prajapati (March 2025)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Citation

If you use this code in your research, please cite:
```
@software{EconomicLoadDispatch2025,
  author = {Vraj Prajapati},
  title = {Economic Load Dispatch with Transmission Line Losses},
  year = {2025},
  url = {https://github.com/your-username/Economic-Load-Dispatch}
}
```

## References

- Wood, A.J. and Wollenberg, B.F. (1996). Power Generation, Operation, and Control. John Wiley & Sons.
- El-Hawary, M.E. and Christensen, G.S. (1979). Optimal Economic Operation of Electric Power Systems. Academic Press.
