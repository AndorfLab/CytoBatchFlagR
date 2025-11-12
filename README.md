# ${{\color{#236CA6}{\Large{\textnormal{\textsf{cytoFlagR}}}}}}$

## Overview
The cytoFlagR tool intakes cytometry data and outputs information about potential technical batch issues in that data. The tool is automated and provides multiple metrics and visualizations that allow the user to access the quality of their data. 

While this tool is designed to be primarily applied on control samples, it is also able to assess biological samples. However, users should take into consideration the inherent biological variability between their biological samples while interpreting the outcome of cytoFlagR.

This tool consists of 5 main parts (each link leads to the relevant Wiki section):

1.	[Pre-processing and visual assessment of the data](https://github.com/AndorfLab/cytoFlagR/wiki/step-1-pre-processing-and-visual-assessment-of-the-data)
    * Samples (FCS files) are transformed and various plots (a MDS, UMAP, and barplot) are created
2.	[An Inter Quartile Range (IQR) based assessment](https://github.com/AndorfLab/cytoFlagR/wiki/step-2-interquartile-range-iqr-based-assessment)
    * Analyzes each marker in each control sample for the negative and positive populations, as well as the percent of positive cells
3.	[An Earth Mover’s Distance (EMD) based assessment](https://github.com/AndorfLab/cytoFlagR/wiki/step-3-earth-movers-distance-based-assessment)
    * Uses the EMD equation for pairwise comparisons between every marker in the control samples
4.	[A comprehensive summary of results (Parts 2 and 3)](https://github.com/AndorfLab/cytoFlagR/wiki/step-4-summary-of-results-for-parts-2-and-3)
    * Provides the metrics and figures that indicate potential batch issues in the inputted data
5.	[An unsupervised clustering based assessment](https://github.com/AndorfLab/cytoFlagR/wiki/step-5-unsupervised-clustering-based-assessment)
    *  Clusters the data to highlight batch issues present within the unique cell populations 

Aditional information about the required input files and the example data are also available in the [Wiki](https://github.com/AndorfLab/cytoFlagR/wiki/cytoFlagR-wiki/). 

## Download
The ZIP file containing all code can be downloaded by clicking on the *<>Code* button above.

Alternatively, the command line can be used to download the tool. Just copy and paste:

```
git clone https://github.com/AndorfLab/cytoFlagR.git
```

Once you download CytoFlagR, the code to run the various functions can be found in the `R/` folder. 

## Dependencies
This tool was developed using R version 4.4.1. Other versions may not be compatable with running the tool. Download and install R [here](https://cran.r-project.org/).

CytoFlagR requires several R and BioConductor packages to run.

Use the package_installer.R function to install the required packages:
```
source("package_installer.R")

# required CRAN packages
requiredPackages<-c("dplyr","scales","tidyr","reshape2","readr","matrixStats","readxl",
                    "ggplot2","ggpubr","ggridges","MASS","RColorBrewer","cowplot",
                    "randomcoloR","ggrepel","emdist","circlize","gridExtra","stats",
                    "LaplacesDemon","pheatmap","umap","progress","crayon","patchwork",
                    "ggpmisc","viridis","tidyverse","shiny","shinyjs","DT","bslib","shinyjs",
                    "cluster","rstudioapi","grid","shinycssloaders","shinyWidgets")
# install
package_installer(requiredPackages)

# check if the packages can be loaded
lapply(requiredPackages, require, character.only = TRUE)

# install Bioconductor package installer
checkBiocManager_install()

# required BioConductor packages
required_BioconductorPackages<-c("flowCore","FlowSOM","ComplexHeatmap","limma","ConsensusClusterPlus")

# install
BioC_package_installer(required_BioconductorPackages)

# check if the packages can be loaded
lapply(required_BioconductorPackages, require, character.only = TRUE)
```
