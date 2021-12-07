#!/bin/bash

set -eux

#
# SECTION: Download bam files
# ------------------
# Use dx download to download the bam file. $mappings_bam is a dx_link
# containing the file_id of that file. By default, when we download a file,
# we will keep the filename of the object on the platform.
#
dx download "${mappings_cram}"

#
# SECTION: Run samtools view
# -----------------
# Here, we use the bash helper variable $mappings_cram_name. For file inputs,
# we will set a bash variable [VARIABLE]_name which holds a string representing
# the filename of the object on the platform. Because we have downloaded the
# file by default above, this will be the filename of the object on this
# worker as well. We further use [VARIABLE]_prefix, which will be the filename
# of the object, removing any suffixes specified in patterns. In this case,
# the pattern if '["*.bam"]', so it will remove the trailing ".bam".
#
# In the case that the filename of the file mappings_bam is "my_mappings.bam",
# mappings_bam_prefix will be "my_mappings"


outfile=${mappings_cram_prefix}.counts.txt
samtools view -c ${mappings_cram_name} > $outfile

#
# SECTION: Upload result
# -------------
# We now upload the data to the platform. This will upload it into the
# job container, a temporary project which holds onto files associated
# with the job. when running upload with --brief, it will return just the
# file-id.

counts_txt_id=$(dx upload ${outfile} --brief)

#
# SECTION: Associate with output
# ---------------------
# Finally, we tell the system what file should be associated with the output
# named counts_txt (which was specified in the dxapp.json). The system will then
# move this output into whatever folder was specified at runtime in the project
# running the job.
#
dx-jobutil-add-output counts_txt "${counts_txt_id}" --class=file
