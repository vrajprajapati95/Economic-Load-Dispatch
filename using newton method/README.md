# Economic Load Dispatch with Transmission Line Losses

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

This repository provides a comprehensive MATLAB implementation for solving Economic Load Dispatch (ELD) problems with integrated transmission line loss considerations. The codebase implements both traditional lambda iteration and advanced Newton's method approaches, offering robust solutions for power system optimization.

## Introduction

Economic Load Dispatch is a fundamental optimization problem in power system operations, aimed at determining the optimal power output allocation among multiple generating units to minimize the total generation cost while satisfying system operational constraints and meeting the load demand. This implementation addresses the practical challenge of transmission line losses, which significantly impacts the optimal generation schedule in real-world power systems.

## Key Features

- **Multiple Solution Methodologies**:
  - Iterative Lambda Search with binary search optimization
  - Newton's Method implementation for accelerated convergence
  - Detailed convergence tracking and iteration reporting

- **Comprehensive Power System Modeling**:
  - Transmission loss modeling with generator-specific coefficients
  - Penalty factor calculations to account for marginal losses
  - Generator operational constraints enforcement (minimum/maximum capacity limits)

- **Results Analysis and Visualization**:
  - Detailed economic analysis with incremental cost reporting
  - Power balance verification with loss accounting
  - Interactive visualization of optimal generation distribution
  - Cost breakdown and performance metrics

## Technical Implementation

### Files Structure

```
├── main.m                      # Primary ELD solver using lambda search method
├── newton_method_function.m    # Newton's method implementation for ELD
├── ELD_data.m                  # Generator parameters and system configuration
├── LICENSE                     # MIT License file
└── README.md                   # This documentation file
```

### Generator Data Specification

The generator data structure is defined as follows:

| Column | Parameter | Unit | Description |
|--------|-----------|------|-------------|
| 1 | a | $/MW²h | Quadratic cost coefficient in generator cost function |
| 2 | b | $/MWh | Linear cost coefficient in generator cost function |
| 3 | c | $/h | Fixed cost coefficient in generator cost function |
| 4 | pg_min | MW | Minimum generation capacity constraint |
| 5 | pg_max | MW | Maximum generation capacity constraint |
| 6 | pg_initial | MW | Initial generation value for iterative process |
| 7 | ploss_coeff | per unit | Generator-specific transmission loss coefficient |

### Mathematical Formulation

The optimization problem is formulated as:

**Objective Function:**
```
Minimize Σ(a_i*pg_i² + b_i*pg_i + c_i)  for i=1 to N
```

**Subject to Constraints:**
1. Power balance: `Σpg_i - Σploss_i = PD`
2. Generation limits: `pg_min_i ≤ pg_i ≤ pg_max_i`
3. Transmission losses: `ploss_i = ploss_coeff_i * pg_i²`

### Loss Model

This implementation employs a simplified transmission loss model which approximates the losses associated with each generator as a function of its output:

```
ploss_i = ploss_coeff_i * (pg_i)²
```

While this is a simplification of the full B-coefficient matrix approach typically used in power systems, it provides computational efficiency while maintaining acceptable accuracy for many practical applications.

## Usage Guide

### Prerequisites

- MATLAB R2019b or later
- No additional toolboxes required

### Installation

```bash
# Clone the repository
git clone https://github.com/username/economic-load-dispatch.git

# Navigate to the project directory
cd economic-load-dispatch
```

### Running the Code

1. Start MATLAB and navigate to the repository directory
2. Configure system parameters in `ELD_data.m` if necessary
3. Execute the main script:
   ```matlab
   >> main
   ```
4. For utilizing Newton's method with custom parameters:
   ```matlab
   >> [pg_optimal, lambda_optimal] = newton_method_function(N, a, b, pg_initial, ploss_initial, ploss_coeff, lambda_initial, pd, pg_min, pg_max, tolerance);
   ```

### Example Output

The program provides detailed iteration logs during execution:

```
Initial conditions:
Demand (Pd) = 975.00 MW
Initial generation: 450.00 MW
Initial losses: 1.04 MW

--- Iteration 1 ---
Lambda = 10.000000
Total generation: 918.5431 MW
Total losses: 10.8549 MW
Power balance: -67.3118 MW

...

=== FINAL RESULTS ===
Optimal lambda = 10.456291
Generator 1: Pg = 399.7252 MW, Incremental Cost = 10.5567 $/MWh
Generator 2: Pg = 335.1474 MW, Incremental Cost = 10.8647 $/MWh
Generator 3: Pg = 255.1242 MW, Incremental Cost = 10.8651 $/MWh
Total generation: 989.9968 MW
Total losses: 14.9968 MW
Generation - Losses = 975.0000 MW
Demand = 975.0000 MW
Power balance check: 0.000000 MW
Total generation cost: 9538.62 $/h

Optimization complete.
```

The visualization output includes:
- Bar charts of optimal generator outputs
- Incremental cost distribution
- Penalty factor analysis
- Power balance pie chart showing demand vs. losses

## Performance Considerations

- The Newton's method implementation typically converges in 3-10 iterations for most practical systems
- The iterative lambda search may require more iterations but offers greater stability for ill-conditioned systems
- Computation time scales approximately linearly with the number of generators

## Applications

This codebase is suitable for:

- Power system operation and planning
- Educational demonstrations of economic dispatch principles
- Benchmarking against advanced optimization methods
- Research on power system economics

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Vraj

## Contributing

Contributions are welcome. Please feel free to submit a Pull Request.

## Citation

If you use this code in your research, please cite:

```
@software{EconomicLoadDispatch,
  author = {Vraj},
  title = {Economic Load Dispatch with Transmission Line Losses},
  year = {2025},
  url = {https://github.com/username/economic-load-dispatch}
}
```
