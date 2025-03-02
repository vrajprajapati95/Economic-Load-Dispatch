# Economic Load Dispatch with Transmission Line Losses

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A MATLAB implementation of Economic Load Dispatch (ELD) with transmission line losses using Newton's method. This project optimizes generator outputs to minimize total generation cost while satisfying power balance constraints.

## Overview

Economic Load Dispatch is a critical aspect of power system operation that determines the optimal output of multiple electricity generators to meet the system load at the lowest possible cost, subject to transmission and operational constraints.

This implementation includes:
- Cost optimization with quadratic cost functions
- Transmission line loss modeling
- Generator operating limits (min/max constraints)
- Penalty factor calculations
- Iterative solution using Newton's method
- Comprehensive visualization of results

## Features

- **Cost Minimization**: Minimizes total generation cost while meeting demand
- **Loss Consideration**: Incorporates transmission line losses in the optimization
- **Convergence Control**: Implements adaptive iteration control for reliable convergence
- **Visualization**: Generates plots for generator outputs, incremental costs, and more
- **Reporting**: Exports detailed results to Excel for further analysis

## Requirements

- MATLAB R2019b or newer
- Optimization Toolbox (recommended but not required)

## Files

- `ELD_main.m` - Main script that executes the algorithm
- `newton_method_function.m` - Implementation of Newton's method for ELD
- `ELD_data.m` - Data file containing generator parameters and constraints

## Usage

1. Clone this repository or download the files
2. Open MATLAB and navigate to the project directory
3. Run the main script:
```matlab
ELD_main
```
4. View the results in the MATLAB command window and figures
5. Check the exported Excel file for detailed results

## Example Results

The algorithm determines the optimal power output for each generator to minimize the total cost while considering transmission losses.

Example output for a three-generator system with 975 MW demand:

| Generator | Power Output (MW) | Incremental Cost ($/MWh) | Penalty Factor |
|-----------|-------------------|--------------------------|----------------|
| 1         | 393.25            | 12.88                    | 1.082          |
| 2         | 334.27            | 13.81                    | 1.124          |
| 3         | 258.73            | 14.79                    | 1.151          |

Total generation: 986.25 MW  
Total losses: 11.25 MW  
Total cost: 8,254.73 $/h

## Customization

To use this code with different systems:
1. Modify the `ELD_data.m` file with your generator parameters
2. Adjust the demand value in `ELD_main.m`
3. Tune the convergence parameters if necessary

## Mathematical Formulation

The Economic Load Dispatch problem is formulated as:

Minimize:
```
Σ (a_i × P_i² + b_i × P_i + c_i)
```

Subject to:
```
Σ P_i = P_D + P_L
P_i_min ≤ P_i ≤ P_i_max
```

Where:
- P_i is the power output of generator i
- P_D is the total demand
- P_L is the transmission loss
- a_i, b_i, c_i are the cost coefficients

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Citation

If you use this code in your research, please cite:

```
@software{EconomicLoadDispatch2025,
  author = Vraj Prajapati,
  title = {Economic Load Dispatch with Transmission Line Losses},
  year = {2025},
  url = {https://github.com/your-username/Economic-Load-Dispatch}
}
```
