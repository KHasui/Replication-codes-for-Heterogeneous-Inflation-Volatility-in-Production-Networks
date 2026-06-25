# Readme

Replication codes for “Heterogeneous Inflation Volatility in Production Networks: Producer vs. Consumer Prices,” by K. Hasui and T. Kobayashi, JEDC.

(This version: June 2026)

This repository contains the codes used to reproduce the figures in the paper.

## Environment

These codes are written in MATLAB, and Dynare is used to describe the model.

The codes have been confirmed to run under the following environment:

* MATLAB 2023a
* Dynare 6.0/6.1

The code may not work properly with versions other than those listed above. In particular, its behavior is highly dependent on the version of Dynare, and it has been confirmed not to work properly with MATLAB 2025a.

Some of the codes use [SpringRank](https://github.com/cdebacco/SpringRank). Please download SpringRank separately and place the files in the `Utils/Spring_Rank` folder.

## Main Files

* `run00_make_database.m`
* `run01_build_dynaremod.m`
* `run02_fig03a_IOmat.m`
* `run03_fig04_relative_stdev.m`
* `run04_figs05_and_06_estimation.m`
* `run05_fig07_irf.m`
* `run06_figs09_and_10_passthrough.m`
* `run07_fig11_stdev_network.m`
* `run08_fig08_struct_importance.m`
* `run_additional_figs_tabs.m`

Running these files will generate the figures presented in the paper. The scripts should be run in numerical order.

Some scripts, especially those involving estimation, may take a long time to run. In particular, `run04_figs05_and_06_estimation.m` and `run07_fig11_stdev_network.m` may require substantial computation time.

## Folders

* `DATA`
  This folder contains the processed data used in the analysis. It also contains the grouped data obtained from K-means clustering in the estimation part.

* `Utils`
  This folder contains auxiliary functions used for figures, tables, and other related tasks.

## Note

Please use these codes at your own risk. We are not responsible for any damage or errors that may occur from using these codes.

Code author: Kohei Hasui (Aichi University)
