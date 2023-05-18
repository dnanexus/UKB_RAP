# Protein differential expression (DE) tutorial

In general, differential expression (DE) analyses try to identify quantitative changes in expression level between two experimental groups. In this case, we will be performing protein DE analysis, where we will compare the protein expression profiles between groups of samples. The proteins that are found to be differentially expressed between the two groups can reveal biological processes or mechanisms that contribute to the trait that we’re studying.

*NOTE:* This folder contains example code for how to run DE analysis on the UKB RAP.  This tutorial is not using UKB proteomics data. Here we are using public proteomics data found in the [Kivisakk et al publication](https://academic.oup.com/braincomms/article/4/4/fcac155/6608340#366642284).

## File structure
| Folder | Description |
| --- | --- |
| [1_preprocess_explore_data.ipynb](1_preprocess_explore_data.ipynb) | Python notebook that pre-processes (normalize and subset expression data) and explore (plot distribution) the data in preparation for DE analysis.|
| [2_differential_expression_analysis.ipynb](2_differential_expression_analysis.ipynb) | R notebook that performs DE analysis and visualizes the data using a volcano plot. We reused code created by SciProd team to perform [DE for transcriptomic data](https://github.com/dnanexus/OpenBio/blob/master/transcriptomics/tutorial_notebooks/Transcript_Expression_Part-02_Analysis-diff-exp_R.ipynb). |
| [normalization_experiment.ipynb](normalization_experiment.ipynb) | R notebook that compares the DE proteins found using unnormalized vs normalized data. |


## Steps

1. Run [`1_preprocess_explore_data.ipynb`](1_preprocess_explore_data.ipynb) notebook.

Input:
* This notebook started with QC'd proteomic expression data from [Kivisakk et al publication](https://academic.oup.com/braincomms/article/4/4/fcac155/6608340#366642284).

Outputs:
* Proteomic expression matrix: 59 sample x 400 protein (`npx.csv`)
* Phenotype matrix: 59 sample x trait (`pheno.csv`).

2. Run [`2_differential_expression_analysis.ipynb`](2_differential_expression_analysis.ipynb) notebook. Using the expression and phenotype output from step 1, this notebooks performs DE analysis comparing patients with mild cognitive impairements (MIC) that are stable vs those that progress to Alzheimer's disease dementia.

## Acknowledgements
We would like to thank the DNAnexus SciProd team for providing the code base for the differential expression analysis, which we extended to allow for proteomics data as input.
We would also like to thank Ondrej Klempir, Anastazie Sedlakova and Arkarachai Fungtammasan for insightful discussions, testing and code review