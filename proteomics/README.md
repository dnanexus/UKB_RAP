# Proteomics analysis examples

This folder contains 2 examples of analyses using the newly available proteomics data.

## File structure
| Folder | Description |
| --- | --- |
| [protein_DE_analysis](protein_DE_analysis) | Folder containing jupyterlab notebooks to run differential expression analysis on the UKB-RAP.|
| [protein_pQTL](protein_pQTL) | Folder containing a notebook to prepare the data to input into the REGENIE app on the UKB-RAP.|

## How to extract proteomics data from UKB-RAP
The proteomics data on UKB-RAP is available in the Cohort Browser. There are 2 options for extracting the data:

1. Use the `dx extract_dataset` command line tool. An example for how to do this can be found in the [0_extract_phenotype_protein_data.ipynb](0_extract_phenotype_protein_data.ipynb) notebook.
2. Use the Table exporter app on the platform. To use this tool you'll need to specify the following input params:

*Dataset or Cohort or Dashboard*: <file path to the cohort dataset or .dataset file in the root directory>
*File containing Field Names*: If you want to use all proteins then use [field_names.txt](field_names.txt)
* *Entity*: Options are olink_instance_0, olink_instance_2, olink_instance_3 depending on the samples you want to include