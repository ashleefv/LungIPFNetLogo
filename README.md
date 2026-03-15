# LungIPF NetLogo
[![DOI](https://zenodo.org/badge/917191365.svg)](https://doi.org/10.5281/zenodo.19026069)

## Code developed by Team #5 at [ICERM Women in Mathematical Computational Biology](https://icerm.brown.edu/program/topical_workshop/tw-25-wmcb) 
### Authors: Narshini D. Gunputh*, Eirini Kilikian*, Claudia A. Miranda*,  Shayn M. Peirce, and Ashlee N. Ford Versypt. The first three authors contributed equally. Corresponding author: [A. N. Ford Versypt, ashleefv@buffalo.edu](mailto:ashleefv@buffalo.edu).

## Abstract: Agent-Based Modeling of Idiopathic Lung Fibrosis and Mechanistic Treatments
### Leaders: Shayn M. Peirce (University of Virginia), Ashlee N. Ford Versypt (University at Buffalo)

Agent-based modeling (ABM) is a computational method for predicting the emergent outcomes of interacting, autonomous individuals in a complex system. Here, ABM is used to simulate interactions between fibroblast and myofibroblast cells during idiopathic pulmonary fibrosis (IPF) in alveolar tissue microenvironments derived from histology of a healthy human lung sample and moderate- and severe-IPF lung samples. Fibroblast differentiation, cell migration, and collagen secretion in response to spatial distributions of the inflammatory cytokine transforming growth factor-beta are captured in the ABM using NetLogo software. Results are presented from one simulated year without treatment and with mechanisms representing treatment by pirfenidone and pentoxifylline, alone and in combination. 180 in silico experiments are run, analyzed, and compared in a high-throughput workflow. Effects of the initial number of fibroblasts and the treatment scenarios on various metrics related to the collagen accumulated in the domain and the invasion of collagen into regions previously occupied by alveoli are determined. The ABM and the analysis files are shared to facilitate model reuse. By integrating computational modeling of IPF and therapeutic mechanisms, this research aims to improve understanding of fibrosis progression and assess the efficacy of targeting different mechanisms to inform decision making for treatment of IPF.

## Main agent-based model file
LungFibrosis_BehaviorSpace.nlogo for [NetLogo version 6.4.0](https://www.netlogo.org/downloads/archive/6.4.0/)

## Postprocessing to generate manuscript figures
* CombineWorldPNGFiles.m: combines image files generated during BehaviorSpace in silico experiments
* PlotBehaviorSpace.m: analyzes output metrics from BehaviorSpace in silico experiments and generates time-dependent and bar graphs of outputs
* PlotExportWorldBehaviorSpaceFigForEachRep.m: visualizes patch variable fields saved before and after each BehaviorSpace in silico experiment and compiles into NetLogo world spatial configurations

## Subfolders
* BehaviorSpaceResults: contains output files from BehaviorSpace in silico experiments repeated on three human lung tissue samples
* CropMaskHE: image files from [Franzen et al. 2024](https://doi.org/10.1038/s41588-024-01819-2) processed in ImageJ and NetLogo worlds .csv files for initialization to human samples with naming following [Franzen et al. 2024](https://doi.org/10.1038/s41588-024-01819-2)
* Results images: png files used or compiled into figures in the manuscript
* natsortfiles: third party codes for sorting file names; used here as helper functions during automated processing of images across several folders
