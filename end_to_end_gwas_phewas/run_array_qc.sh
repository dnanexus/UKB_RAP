#!/bin/sh

# This script runs the QC process using PLINK on the lifted over merged PLINK files generated
# using liftover_plinks_bed.wdl script

# This script is delivered "As-Is". Notwithstanding anything to the contrary, DNAnexus will have no warranty, 
# support, liability or other obligations with respect to Materials provided hereunder.
# MIT License(https://github.com/dnanexus/UKB_RAP/blob/main/LICENSE) applies to this script.


# How to Run:
# Run this shell script using:
# sh run_array_qc.sh
# on the command line on your machine



# Outputs:
# - List of variants to use in regenie GWAS step 1 (/Data/array_qc/imputed_array_snps_qc_pass.snplist)
# - Log file (/Data/array_qc/imputed_array_snps_qc_pass.log)
# - List of samples remained after filtering (/Data/array_qc/imputed_array_snps_qc_pass.id)

#set output directory (also location of merged files)
data_file_dir="/Bulk-DRL/Genotype Calls, merged/"

run_plink_qc="plink2 --bfile ukb_c1-22_merged\
 --keep ischemia_df.phe --autosome\
 --maf 0.01 --mac 20 --geno 0.1 --hwe 1e-15\
 --mind 0.1 --write-snplist --write-samples\
 --no-id-header --out  imputed_array_snps_qc_pass"

dx run swiss-army-knife -iin="${data_file_dir}/ukb_c1-22_merged.bed" \
   -iin="${data_file_dir}/ukb_c1-22_merged.bim" \
   -iin="${data_file_dir}/ukb_c1-22_merged.fam"\
   -iin="/Data/ischemia_df.phe" \
   -icmd="${run_plink_qc}" --tag="Array QC" --instance-type "mem1_ssd1_v2_x36"\
   --destination="/Data/array_qc/" --brief --yes
