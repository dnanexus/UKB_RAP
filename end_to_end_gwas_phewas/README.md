# Identifying important variants for ischaemic heart disease using genome-wide and phenome-wide association studies


This folder contains collection of scripts and Jupyter notebooks to perform genome-wide association studies (GWAS) analysis of Ischemic heart disease, aggregating significant variants using linkage disequilibrium (LD) clumping and subsequent phenome-wide association study (PheWAS).


|Order| Name          | Description   |
|:----|:------------- |:-------------|
|1 | gwas-phenotype-samples-qc.ipynb      | Performs sample QC on cases and controls cohorts and select only those samples, for which imputed data are available.|
|2 | liftover_plinks_bed.wdl| Lifts array data to the newer version of the reference genome - GRCh38 and merges files per chromosome as one file.|
|3 | run_array_qc.sh | Performs QC on lifted array PLINK files. |
|4 | bgen_qc.wdl  | Performs QC on imputed data BGEN files and merges results for individual chromosomes into one file.   |
|5 | run_ld_clumping.ipynb  | Performs LD clumping on significant GWAS variants.  |
|6 | get-phewas-data.ipynb   | Create phenotype data in long format suitable for the PheWAS R package. Extract Genotype data for each variant selected by LD clumping.   |
|7 | run-phewas.ipynb  | Run PheWAS analysis using PheWAS R package   |

