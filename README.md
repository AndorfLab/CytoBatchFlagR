# ${{\color{#236CA6}{\Large{\textnormal{\textsf{cytoFlagR}}}}}}$

## Overview
The cytoFlagR tool intakes cytometry data and outputs information about potential technical batch issues in that data. The tool is automated and provides multiple metrics and visualizations that allow the user to access the quality of their data. 

While this tool is designed to be primarily applied on control samples, it is also able to assess biological samples. However, users should take into consideration the inherent biological variability between their biological samples while interpreting the outcome of cytoFlagR.

This tool consists of 5 main parts (each link leads to the relevant Wiki section):

1.	[Pre-processing and Visual Assessment of the Data](https://github.com/AndorfLab/cytoFlagR/wiki/Wiki#step-1-pre-processing-and-visual-assessment-of-the-data)
    * Samples (FCS files) are transformed and various plots (a MDS, UMAP, and barplot) are created
2.	[An Interquartile Range (IQR)-Based Assessment](https://github.com/AndorfLab/cytoFlagR/wiki/Wiki#step-2-interquartile-range-iqr-based-assessment)
    * Analyzes each marker in each control sample for the negative and positive populations, as well as the percent of positive cells
3.	[An Earth Mover’s Distance (EMD)-Based Assessment](https://github.com/AndorfLab/cytoFlagR/wiki/Wiki#step-3-earth-movers-distance-emd-based-assessment)
    * Uses the EMD equation for pairwise comparisons between every marker in the control samples
4.	[A Comprehensive Summary of Results (Parts 2 and 3)](https://github.com/AndorfLab/cytoFlagR/wiki/Wiki#step-4-summary-of-results-for-parts-2-and-3)
    * Provides the metrics and figures that indicate potential batch issues in the inputted data
5.	[An Unsupervised Clustering Based Assessment](https://github.com/AndorfLab/cytoFlagR/wiki/Wiki#step-5-unsupervised-clustering-based-assessment)
    *  Clusters the data to highlight batch issues present within the unique cell populations 

Aditional information about the required input files and the example data are also available in the [Wiki](https://github.com/AndorfLab/cytoFlagR/wiki/Wiki/). 

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

First, make sure you set your directory as the `R/` folder of cytoFlagR:

```
setwd("C:/you/directory/here/cytoFlagR-main/R")
```

Once the directory is correctly set, you can use the package_installer.R function to install the required packages:
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
## Citations

Eswar, S., Koenig, Z. T., Tursi, A. R., Cobeña-Reyes, J., Tilburgs, T., & Andorf, S. (2025). cytoFlagR: A comprehensive framework to objectively assess high-parameter cytometry data for batch effects. bioRxiv : the preprint server for biology, 2025.05.27.656370. https://doi.org/10.1101/2025.05.27.656370

Koenig, Z., Andorf, S., Tilburgs, T., & Eswar, S. (2025). cytoFlagR: Spectral flow cytometry dataset [Data set]. Zenodo. https://doi.org/10.5281/zenodo.15388817
