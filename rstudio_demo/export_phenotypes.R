#!/usr/bin/env Rscript

#This code is delivered "As-Is". Notwithstanding anything to the contrary, DNAnexus will have no warranty, support, liability or other obligations with respect to Materials provided hereunder.
#[MIT License](https://github.com/dnanexus/UKB_RAP/blob/main/LICENSE) applies to this code.

debug <- FALSE
### EXAMPLE RUNNING COMMANDS FROM RSTUDIO TERMINAL

# Rscript --default-packages=optparse,readr --vanilla export_phenotypes.R
# Rscript --default-packages=optparse,readr --vanilla export_phenotypes.R -h
# Rscript --default-packages=optparse,readr --vanilla export_phenotypes.R -d record-XXX -i datalist.csv

### HARDCODED VALUES FOR INPUT PARAMETERS ###

dataset <- "record-GB70X38Jq0pXZYjZPP6vB7G5"
input_csv <- "datalist.csv" # first row (header) should contain "field_title", then followed by individual field titles on the next rows

### INSTALL (IF NEEDED) AND LOAD REQUIRED R PACKAGES ###

# Uncomment the install commands if you are comfortable with the library license and want to install and run the code that depend on the library.

#install.packages("optparse", repos = "http://cran.us.r-project.org")
#install.packages("readr", repos = "http://cran.us.r-project.org")
#install.packages("rjson", repos = "http://cran.us.r-project.org")
#install.packages("glue", repos = "http://cran.us.r-project.org")

library(optparse)
library(readr)
library(rjson)
library(glue)

### PARSE INPUT PARAMETERS ###

option_list = list(
  make_option(c("-d", "--dataset"), type="character", default=NULL,
              help="Dataset or Cohort or Dashboard", metavar="character"),
  make_option(c("-f", "--format"), type="character", default="FIELD-NAME",
              help="Header Style [default= %default]", metavar="character"),
  make_option(c("-i", "--input"), type="character", default=NULL,
              help="CSV file with field titles, one field title per row", metavar="character")
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

if (is.null(opt$dataset)){
  #opt$dataset <- dataset
  stop("No dataset argument - set using --dataset <dataset-id>")
}

if (is.null(opt$input)){
  #opt$input <- input_csv
  stop("No list of fields - set using --input <csv_file_name>")
}

list_of_fields <- readr::read_csv(opt$input)

### Run a system cmd, wait synchronously and return the result of system command to a variable #

dataset <- opt$dataset
field_list <- list_of_fields$field_title
json_list <- list(dataset_or_cohort_or_dashboard =
                    list(`$dnanexus_link` = dataset),
                  field_titles=field_list,
                  header_style = "FIELD-NAME")
json_string <- rjson::toJSON(json_list)

cmd <- "dx run app-table-exporter -ientity=participant --brief --wait --watch -y -j '{json_string}'"

out_cmd <- glue::glue(cmd)

# Do not start job, just print dx run command if debug is TRUE
if(debug){
  print(json_string)
  print(out_cmd)
}

if(debug==FALSE){

  res <- system(out_cmd, intern = TRUE, ignore.stdout = FALSE, ignore.stderr = FALSE, wait = TRUE)
  print(res)

  print(res[length(res)][1]) # Extract and print the job output, i.e. ID of the exported csv file

  output_id <- strsplit(res[length(res)][1], split = " ")[[1]][7]
  system(paste("dx download -f", output_id, collapse = ''), intern = TRUE, ignore.stdout = FALSE, ignore.stderr = FALSE, wait = TRUE) # Download the output CSV file to the instance storage from which the applet was called
}
