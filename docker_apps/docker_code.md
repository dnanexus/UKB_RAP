# Using Docker on RAP

## Pulling a docker image and saving as a snapshot

The following is the code we used to pull the samtools image from quay.io:

## Pull Docker Image

```
docker pull quay.io/biocontainers/samtools:1.15.1--h1170115_0
```

## Save Docker Snapshot File

```
docker save quay.io/biocontainers/samtools | gzip > samtools_image.tar.gz
```

## Upload Docker Snapshot File

```
dx upload samtools_image.tar.gz --destination /images
```

# Running Docker Using Swiss Army Knife

## Basic Recipe for Using a Docker Snapshot Using Swiss Army Knife

```
dx run app-swiss-army-knife \
  -icmd="samtools count * > counts.txt" \
  -iin="file-XXXXXXX" \
  -iimage_file="images/samtools_image.tar.gz"
```  
  
## Using `dx find files` to find data files with a field id

### Returning Bare File Names

```
dx find files --property field_id=23148 --brief
```

### Returning JSON and processing with `jq`

```
dx find data --property field_id=23148 --json | jq '.[].describe | select (.name | contains("vcf.gz")).id'
```

### Using xargs with `dx run`

Note this command is for running with `bcftools`, which is already installed with swiss-army-knife.

It will find all `.vcf.gz` files in field id 23148, and process each of them with `bcftools stats`. 

```
dx find data --property field_id=23148 --json | jq '.[].describe | select (.name | contains("vcf.gz")).id' | xargs -I% sh -c 'dx run app-swiss-army-knife -iin="%" -icmd="bcftools stats % > %.stats.txt"'
```
