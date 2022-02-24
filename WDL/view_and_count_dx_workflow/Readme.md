#This workflow is delivered "As-Is". Notwithstanding anything to the contrary, DNAnexus will have no warranty, support, liability or other obligations with respect to Materials provided hereunder.

#[MIT License](https://github.com/dnanexus/UKB_RAP/blob/main/LICENSE) applies to this workflow.

# This workflow requires access to the following dependencies that are not packaged with the workflow

## Task count_bam
* Network Docker image
    * `quay.io/ucsc_cgl/samtools`
* Available instance types determined during WDL compilation will be used to select instance types during workflow execution
## Task slice_cram
* Network Docker image
    * `quay.io/ucsc_cgl/samtools`
* Available instance types determined during WDL compilation will be used to select instance types during workflow execution