# Problem:
BGEN could be compressed with either zlib or zstd, but Hail only supports BGEN that uses zlib. Currently, UKB supports BGEN using zlib (Phased and unphased imputed genotype data) and zstd (Whole exome sequence data) compression depending on the data type. 

# Solution:
Use [qctool](https://www.well.ox.ac.uk/~gav/qctool_v2/documentation/examples/converting.html) to convert BGEN files using zstd compression (WES) to zlib compression

# How to convert files:

## System notes
* Runtime: This can take 12 hours (chr22, 2.14 GB file) to 2.25 days (chr1, 9.59 GB file) to complete.
* Compute usage: 1 core, 1-2 GB of RAM

## Using UI
1. Open Tool library
2. Select Swiss-Army-Knife
3. On the Swiss-Army-Knife home page, click on the "Versions" tab and select 4.1.1
4. Click "Run"
5. Select project and files in pop-up menu
6. Set execution settings in the "Analysis Inputs 1" tab as the following:

Input files: 
<filename>.bgen
<filename>.sample

Command line: `qctool -g *.bgen -s *.sample -og <filename>_converted.bgen -os <filename>_converted.sample -ofiletype bgen -bgen-bits 8 -bgen-compression zlib -bgen-omit-sample-identifier-block`

## Using CLI
1. Run `dx login`
2. Run the following command:

```
dx run swiss-army-knife/4.1.1 -icmd="qctool -g \"/mnt/project/<file path>/<filename>.bgen\" -s \"/mnt/project/<file path>/<filename>.sample\" -og \"<filename>_converted.bgen\" -os \"<filename>_converted.sample\" -ofiletype bgen -bgen-bits 8 -bgen-compression zlib -bgen-omit-sample-identifier-block" --extra-args '{"timeoutPolicyByExecutable": {"app-GFxJgVj9Q0qQFykQ8X27768Y":{"*": {"hours": 72}}}}'
```
