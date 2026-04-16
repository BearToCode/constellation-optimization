# Satellite Constellation Optimization

![Project Banner](https://github.com/BearToCode/constellation-optimization/blob/master/out/simplified_cost_surface.png?raw=true)

This project investigates the design and optimization of a Low Earth Orbit (LEO) satellite constellation to improve ground coverage and reduce revisit time over selected target regions. It combines orbital mechanics, numerical simulation, and global optimization techniques to address a highly non-linear design problem.

---

## Overview

Efficient satellite constellation design is essential for Earth observation and communication missions. As the number of satellites increases, identifying optimal orbital configurations becomes significantly more complex.

In this project, a constellation of three satellites is optimized to maximize coverage over specific regions while minimizing the time between successive observations of the same location. The study focuses on a balance between physical modeling accuracy and computational efficiency.

---

## Problem Formulation

The constellation is defined through the orbital parameters of each satellite. These parameters form the design variables of the optimization problem, subject to constraints that ensure physically realistic Low Earth Orbits.

The objective function evaluates how well a given configuration performs in terms of coverage and revisit time. Ground coverage is computed by discretizing the Earth’s surface into sample points and tracking their visibility over time.

---

## Methodology

The orbital propagation is based on a two-body model augmented with the J2 perturbation to account for Earth’s oblateness. While higher-order effects are neglected, the model captures the key dynamics required for short-term coverage analysis.

Ground sampling is performed using a Fibonacci-based distribution to ensure a uniform representation of the target regions. Coverage is determined using a geometric visibility condition derived from a minimum elevation angle.

The optimization problem is highly non-convex and exhibits multiple local minima. For this reason, global optimization methods are used instead of gradient-based approaches.

Two strategies are explored:

- A custom implementation of simulated annealing, designed to explore the solution space stochastically
- A genetic algorithm using MATLAB’s built-in tools, used as a reference method

Both approaches rely on penalty functions to handle constraints.

---

## Results

The optimization process produces physically consistent constellation configurations that balance coverage performance across the target regions. The solutions found by different algorithms are structurally similar, indicating that the global features of the problem are well captured.

The optimized constellations typically allocate satellites in a way that prioritizes coverage of the larger or more frequently revisited region, while maintaining partial coverage of the secondary target. Differences between solutions are mainly related to orbital phasing rather than fundamental design choices.

---

## Repository Structure

```
├── data/       External data used in the project
├── cache/      Cached values from main run
├── lib/        Library containing project functions
├── out/        Generate figures
├── scripts/    Additional scripts
├── config.m    Script that creates the project settings
├── main.m      Main run script file
└── README.md
```

---

## Usage

To run the project, open MATLAB, navigate to the repository folder, and execute the main script. The simulation and optimization parameters can be adjusted directly within the code.

---

## Future Work

Possible extensions include incorporating higher-fidelity perturbation models, improving numerical robustness of the objective function, and exploring surrogate-based optimization techniques to reduce computational cost.

---

## Authors

Davide Basso  
Nicolò Basso

---

## License

This project was developed for academic purposes.
