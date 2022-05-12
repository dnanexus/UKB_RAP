# Scripts for UKB RAP for HPC Users

## Requirements

`dx-toolkit` must be installed on your own machine, and it is preferable if you have a `bash` shell available on your computer. For more information about installing it, please read [here](https://documentation.dnanexus.com/downloads).

## Contents of this Folder

### `01-run-SAK-on-CLI.sh`

This is a code example that you can run on your own machine to start a job on DNAnexus. Note that it has a fake file name - replace the file names with a real file name in your project to run it.

Start it with

```
bash 01-run-SAK-on-CLI.sh
```

### `02-run_SAK_in_name.sh`

This is a code example that you can run on your own machine that uses the special keywords `$in_name` and `$in_prefix` to generalize the script a little bit.

Again, this script has a fake file name. Replace it to run it with:

```
bash 02-run_SAK_in_name.sh
```

### `03-batch_processing`

This folder contains two scripts:

- `batch_RUN.sh` - This is the script that is run on your own machine to spawn multiple batch processes. It runs over the files in `Bulk/Exome sequences_Previous exome releases/Population level exome OQFE variants, PLINK format - interim 300k release/` and processes one chromosome file per job.

- `scripts/plink_script.sh` - PLINK script that runs on the files. This is the script that needs to be in your project, in a folder called `scripts/`.

You can run it with

```
bash 03-batch_processing/batch_RUN.sh
```

### `04-batch_processing_dxfuse`

This builds on the `03-batch_processing` script by utilizing the dxFUSE file system. It has two files:

- `batch_RUN_dxfuse.sh` - This is the script to run on your own machine
- `scripts/plink_script_dxfuse.sh` - This script needs to be in your project in a folder called `scripts`

You can run it with

```
bash 04-batch_processing/batch_RUN_dxfuse.sh
```

## Other Strategies/Approaches

### `dx generate-batch-inputs`

[This page](https://documentation.dnanexus.com/user/running-apps-and-workflows/running-batch-jobs) talks about using regular expressions to generate a TSV file that is then run with

`dx run --batch-tsv TSV_file.txt`

Each line of the batch file will be submitted as a single job.

### Writing python scripts to generate `dx run` statements

[This article](https://dnanexus.gitbook.io/uk-biobank-rap/science-corner/guide-to-analyzing-large-sample-sets) talks about an approach to submit multiple files within in a job by writing a Python script to write the `dx run` statements.

With this approach, you can submit 100 files per job and process them sequentially.
