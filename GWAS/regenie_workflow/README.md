# regenie_workflow
 
This code is delivered "As-Is". Notwithstanding anything to the contrary, DNAnexus will have no warranty, support, liability or other obligations with respect to Materials provided hereunder.

[MIT License](https://github.com/dnanexus/UKB_RAP/blob/main/LICENSE) applies to this code.

## Prerequisites / Requirements

0. Must have the dx-toolkit installed: https://documentation.dnanexus.com/downloads
1. Must have a RAP project with data dispensed
2. Must be logged in using `dx login`
3. Must have RAP project selected with `dx select`
4. Must create a folder in your RAP project called `/Data/` with your phenotype file in it

## How to use this Workflow

The workflow consists of 6 shell scripts that can be run from your own machine. They are designed to work with a 200k release. 

**You will need to adjust the variables** (see below) for the different exome file releases (such as 200k, 300k, and 450k).

All scripts can be run by using `sh`. For example:

```
sh partB-merge-files-dxfuse.sh
```

Will spawn a worker to run this step on the RAP platform

Each part is dependent on the previous parts. For more information about inputs/outputs, please look at each script.

## Customizing the workflow

In each script, there are a number of variables that can be set. These will need to be customized based on your exome release and when you dispensed the project.

- `data_file_dir` - this is the main output directory for the scripts (currently set to `/Data/`)
- `exome_file_dir` - this is the path in the bulk folder to the exome files (this will be different depending on which release you are using and when the project was dispensed)
- `data_field` -  The field id of the exome data release you want to use, such as "ukb23155"

For example, for the recent 450k WES release, we need to set these variables in `partF-step2-qc-filter.sh` and `partF-step2-regenie.sh` as:

```
data_file_dir="/Bulk/Exome sequences/Population level exome OQFE variants, PLINK format - interim 450k release/"
data_field="ukb23149"
```

