# Advanced AI Coursework

This workspace contains MATLAB work for an Advanced AI course, including two main coursework projects and supporting lab material.

## Coursework 1 — Neural Network + Genetic Algorithm

### Overview
This coursework uses MATLAB to build a binary classification neural network for an osteoporosis dataset and also includes a separate genetic algorithm optimisation task.

### Achieved
- `coursework1/Main.m` runs the full neural network pipeline for fracture classification:
  - load and pre-process the osteoporosis dataset
  - split data into stratified train/validation/test sets
  - train a feedforward neural network with two hidden layers
  - evaluate results using confusion matrix, ROC/AUC and F1 metrics
- `coursework1/train_network.m` defines a small `25 → 16 → 8 → 2` network and handles class imbalance by tuning regularisation, early stopping and decision threshold behaviour.
- The model training saves a trained network as `trained_net.mat`.

### Genetic Algorithm
- `coursework1/GA/ga_main.m` runs a genetic algorithm to solve a global optimisation problem on the Shekel family of benchmark functions.
- The GA configuration is defined in `coursework1/GA/ga_options.m` with:
  - population size 150
  - tournament selection
  - scattered crossover
  - adaptive feasible mutation
  - elitism and stall-based early stopping
- Supporting files include plotting, fitness, reporting and example GA output in `coursework1/GA/`.

## Coursework 2 — Fuzzy Network for Medical Insurance

### Overview
This coursework develops a fuzzy inference system to model insurance charge risk using the `insurance.csv` dataset.

### Achieved
- `coursework2/final_push.m` builds a cascaded fuzzy network and performs an 80/20 train/test evaluation.
- The system is composed of two sub-systems:
  - Sub-FIS 1: `age` + `bmi` → `body_risk`
  - Sub-FIS 2: `smoker` + `children` → `lifestyle_risk`
- The two sub-systems are combined using a fuzzy network merging method (`horizontal_merging`), building a final classifier for insurance charge category.
- The workflow is data grounded and uses membership functions and rules derived from the dataset.
- Reported results include accuracy and class performance metrics, showing a high-performing fuzzy network for the binary classification task.

### Key files
- `coursework2/FIS_2.m`: builds the lifestyle risk fuzzy system for smoking and number of children.
- `coursework2/final_push.m`: builds the full system, loads data, encodes variables, constructs sub-FIS models, merges them and evaluates performance.
- `coursework2/merged_fuzzy_network_FINAL.mat`: final saved network state for the merged fuzzy system.

## Other folders
- `week1/`, `week3/`, `week5/`: MATLAB labs and exercises from weekly teaching sessions.
- `coursework2/Fuzzy_network/`: likely contains earlier versions or helper functions for the fuzzy network work.

## Running the code
- Open MATLAB and add the relevant folder to the path.
- For Coursework 1 neural network: run `coursework1/Main.m`.
- For Coursework 1 GA task: run `coursework1/GA/ga_main.m`.
- For Coursework 2 fuzzy network: run `coursework2/final_push.m`.

## Summary
This repository contains two main projects for the Advanced AI course:
1. a supervised neural network for osteoporosis fracture classification plus a genetic algorithm optimiser, and
2. a fuzzy inference system for medical insurance risk classification built from sub-systems and merged into a final fuzzy network.

