# Running the RStudio/Bioconductor Container

This document is delivered "As-Is". Notwithstanding anything to the contrary, DNAnexus will have no warranty, support, liability or other obligations with respect to Materials provided hereunder.

[MIT License](https://github.com/dnanexus/UKB_RAP/blob/main/LICENSE) applies to this document.

Note: these instructions are based on the [RStudio Instructions here](https://documentation.dnanexus.com/getting-started/developer-tutorials/web-app-let-tutorials/running-rstudio-server).

## Why Do this?

Bioconductor is a big and complicated install, involving many packages, many of which need compilation. If you don't want to deal with that, you can use the latest Bioconductor docker image by following these instructions.

Note that this is the free version of RStudio; so some features that are in Workbench may not be in the free version.

## Steps to Running In ttyd

Open ttyd. In the terminal, run the following:

```
docker run \
  -p 443:8787  \
  -v /mnt/project/:/mnt/project \
  -v /home/dnanexus:/home/rstudio/dnanexus \
  -e DISABLE_AUTH=true \
  --detach \
  bioconductor/bioconductor_docker:RELEASE_3_15
```

When the job launches, find the relevant `<job id>`. Then go to:

https://`<job-id>`.dnanexus.cloud

## Terminating Your Job
In UI, please go to the Monitor section and terminate ttyd job.

In your local terminal, login to the UKB RAP, and type `dx terminate <job id>`
