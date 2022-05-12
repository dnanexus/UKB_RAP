#!/bin/bash
#This script is run on your home machine
#It will transfer files into each worker
#output of this is going to be the project name followed by /:

export project=`dx pwd`

for i in {1..3}; do
  dx run swiss-army-knife \
      -iin="${project}scripts/plink_script.sh" \
      -iin="${project}Bulk/Exome sequences_Previous exome releases/Population level exome OQFE variants, PLINK format - interim 300k release/ukb23145_c${i}_b0_v1.fam" \
      -iin="${project}Bulk/Exome sequences_Previous exome releases/Population level exome OQFE variants, PLINK format - interim 300k release/ukb23145_c${i}_b0_v1.bim" \
      -iin="${project}Bulk/Exome sequences_Previous exome releases/Population level exome OQFE variants, PLINK format - interim 300k release/ukb23145_c${i}_b0_v1.bed" \
      -icmd="bash plink_script.sh ${i}" \
      --name="plink_script ${i}" \
      --instance-type "mem1_ssd1_v2_x16" \
      --destination="${project}results/" \
      -y
done
