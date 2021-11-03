#!/bin/sh

# Requirements: 
# 0-4 - please refer to readme.md
# 5. Must have executed: 
# - partB-merge-files-dx-fuse.sh 
# - partC-step1-qc-filter.sh

# How to Run:
# Run this shell script using: 
#   sh partD-step1-qc-regenie.sh 
# on the command line on your own machine

# Inputs:
# Note that you can adjust the output directory by setting the data_file_dir variable
# - /Data/diabetes_wes_200k.phe - from part A (please refer to notebook & slides)
# - /Data/WES_array_snps_qc_pass.snplist - from part C
# - /Data/ukb22418_c1_22_merged.bed - from part B
# - /Data/ukb22418_c1_22_merged.bed - from part B
# - /Data/ukb22418_c1_22_merged.bed - from part B

# Outputs:
# - /Data/diabetes_results_1.loco.gz - Leave One Chromosome Out results (used in part F)
# - /Data/diabetes_results_pred.list - List of files generated this step (used in part F)
# - /Data/diabetes_results.log


#output directory - this should also be where the files in 02-step1-qc-filter.sh end up
data_file_dir="/Data/"

run_regenie_step1="regenie --step 1\
 --lowmem --out diabetes_results --bed ukb22418_c1_22_v1_merged\
 --phenoFile diabetes_wes_200k.phe --covarFile diabetes_wes_200k.phe\
 --extract 200K_WES_array_snps_qc_pass.snplist --phenoCol diabetes_cc\
 --covarCol age --covarCol sex --covarCol ethnic_group --covarCol ever_smoked\
 --bsize 1000 --bt --loocv --gz --threads 16";

dx run swiss-army-knife -iin="${data_file_dir}/ukb22418_c1_22_v1_merged.bed" \
   -iin="${data_file_dir}/ukb22418_c1_22_v1_merged.bim" \
   -iin="${data_file_dir}/ukb22418_c1_22_v1_merged.fam"\
   -iin="${data_file_dir}/diabetes_wes_200k.phe" \
   -icmd=${run_plink_wes} --tag="Step1" --instance-type "mem1_ssd1_v2_x16"\
   --destination="${project}:/Data/" --brief --yes;