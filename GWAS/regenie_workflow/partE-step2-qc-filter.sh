#!/bin/bash

# Requirements: 
# 0-4 - please refer to readme.md
# 5. Must have executed: 
# - partB-merge-files-dx-fuse.sh 
# - partC-step1-qc-filter.sh
# - partD-step1-regenie.sh

# How to Run:
# Run this shell script using: 
#   sh partE-step2-qc-filter.sh 
# on the command line on your own machine

# Inputs:
# Note that you can adjust the output directory by setting the data_file_dir variable
# - /Data/diabetes_wes_200k.phe - from part A (please refer to notebook & slides)

# for each chromosome, you will run a separate worker
# - /{exome_file_dir}/ukb23155_c1_b0_v1.bed - Chr1 file for 200k release
# - /{exome_file_dir}/ukb23155_c1_b0_v1.bim 
# - /{exome_file_dir}/ukb23155_c1_b0_v1.bam 
# - /Data/ukb22418_c1_22_merged.bed - from part B
# - /Data/ukb22418_c1_22_merged.bed - from part B

# Outputs (for each chromosome):
# - /Data/WES_c1_snps_qc_pass.id  
# - /Data/WES_c1_snps_qc_pass.snplist - used in Part F 
# - /Data/WES_c1_snps_qc_pass.log


#set this to the exome sequence directory that you want (should contain PLINK formatted files)
exome_file_dir="/Bulk/Exome sequences/Population level exome OQFE variants, PLINK format - interim 200k release/"
#set this to the exome data field for your release
data_field="ukb23155"
data_file_dir="/Data/"

for i in {1..22}; do
    run_plink_wes="plink2 --bfile ukb${data_field}_c${i}_b0_v1\
      --no-pheno --keep diabetes_wes_200k.phe --autosome\
      --maf 0.01 --mac 20 --geno 0.1 --hwe 1e-15 --mind 0.1\
      --write-snplist --write-samples --no-id-header\
      --out WES_c${i}_snps_qc_pass"

    dx run swiss-army-knife -iin="${exome_file_dir}/${data_field}_c${i}_b0_v1.bed" \
     -iin="${exome_file_dir}/${data_field}_c${i}_b0_v1.bim" \
     -iin="${exome_file_dir}/${data_field}_c${i}_b0_v1.fam"\
     -iin="${data_file_dir}/diabetes_wes_200k.phe" \
     -icmd=${run_plink_wes} --tag="Step2" --instance-type "mem1_ssd1_v2_x16"\
     --destination="${project}:/Data/" --brief --yes
done