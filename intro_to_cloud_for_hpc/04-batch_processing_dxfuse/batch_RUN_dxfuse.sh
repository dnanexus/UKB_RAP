#!/bin/bash
#This script is run on your home machine
#It will transfer files into each worker
export project=`dx pwd`

for i in {1..3}; do
  dx run swiss-army-knife \
      -iin="${project}scripts/plink_script_dxfuse.sh" \
      -icmd="bash plink_script_dxfuse.sh ${i}" \
      --name="plink_script_dxfuse ${i}" \
      --instance-type "mem1_ssd1_v2_x16" \
      --destination="${project}results/" \
      -y
done
