# LungIPFNetLogo

## Code developed by Team #5 at [ICERM Women in Mathematical Computational Biology](https://icerm.brown.edu/program/topical_workshop/tw-25-wmcb) 
### Authors: Claudia de Sousa Miranda Perez, Narshini Gunputh, Eirini Kilikian, Shayn Peirce-Cottler, and Ashlee N. Ford Versypt

## Abstract: Project #5 - Agent-based modeling of lung fibrotic disease for testing and identifying new drug targets
### Leaders: Shayn Peirce-Cottler (University of Virginia), Ashlee N. Ford Versypt (University at Buffalo)

Agent-based modeling (ABM) is a computational method for analyzing and predicting the emergent, population-level outcomes of interacting, autonomous individuals in a complex system. ABM has been widely used to inform planning and decision making across a variety of industries and sectors of society, including finance, architecture and urban planning, national security and defense, sales and marketing, social and political sciences, education, public health, medicine, and biomedical research. In this project, participants will learn how to develop and code an ABM to simulate the cellular and molecular mechanisms of human disease and to identify new drug targets for treating disease. The goals of this project are to: 1) simulate human fibrotic lung disease, 2) use ABM simulations to investigate the contributions of fibroblast cellular heterogeneity to pathogenesis, and 3) use the ABM to identify novel molecular targets for drugs that can slow or reverse disease progression. Participants will learn how to simulate different initial conditions in order to explore the use of ABMs as a framework for constructing a patient-specific “digital twin”. They will also use their models to test real and hypothetical drugs for personalized medicine. Participants are not required to have any prior experience with ABM. During this project, they will learn how to program in a user-friendly, freely available ABM software called NetLogo.

## Main agent-based model file
LungFibrosis_BehaviorSpace.nlogo for NetLogo version 6.4.0

## Postprocessing to generate manuscript figures
* CombineWorldPNGFiles.m: combines image files generated during BehaviorSpace in silico experiments
* PlotBehaviorSpace.m: analyzes output metrics from BehaviorSpace in silico experiments and generates time-dependent and bar graphs of outputs
* PlotExportWorldBehaviorSpaceFigForEachRep.m: visualizes patch variable fields saved before and after each BehaviorSpace in silico experiment and compiles into NetLogo world spatial configurations

## Subfolders
* BehaviorSpaceResults: contains output files from BehaviorSpace in silico experiments repeated on three human lung tissue samples
* CropMaskHE: image files from [Franzen et al. 2024](https://doi.org/10.1038/s41588-024-01819-2) processed in ImageJ and NetLogo worlds .csv files for initialization to human samples with naming following [Franzen et al. 2024](https://doi.org/10.1038/s41588-024-01819-2)
* Results images: png files used or compiled into figures in the manuscript
* natsortfiles: third party codes for sorting file names; used here as helper functions during automated processing of images across several folders
