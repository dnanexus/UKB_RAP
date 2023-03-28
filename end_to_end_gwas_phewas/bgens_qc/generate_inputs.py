#!/usr/bin/env python
# coding: utf-8

# In[ ]:





# # As-Is Software Disclaimer
# 
# This notebook is delivered "As-Is". Notwithstanding anything to the contrary, DNAnexus will have no warranty, support, liability or other obligations with respect to Materials provided hereunder.
# 
# [MIT License](https://github.com/dnanexus/UKB_RAP/blob/main/LICENSE) applies to this notebook.

# ## Jupyterlab app details (launch configuration)
# 
# Recommended configuration
# - Runtime: <5 min
# - Cluster configuration: `Single Node` or local
# - Recommended instance: `mem2_ssd1_v2_x16`
# - Cost: <£0.2

# ## Introduction
# 
# This notebook:
# - Prepares inputs in JSON format containing DNAnexus file IDs to use as an `-inputs` parameter for [dxCompiler](https://github.com/dnanexus/dxCompiler)
# 
# See [dxCompiler documentation for more details](https://github.com/dnanexus/dxCompiler/blob/develop/doc/ExpertOptions.md#inputs).

# In[1]:


import glob
import json
import subprocess
import os


# Set filepath to the data, phenotype file and PLINK options.

# In[2]:


output_file_prefix = "gel_impute_data_snps_qc_pass"


# In[3]:


plink_options = "--mac 10 --maf 0.0001 --hwe 1e-15 --mind 0.1 --geno 0.1"


# In[4]:


path_to_data = '/Bulk/Imputation/Imputation from genotype (GEL)/'


# In[ ]:


phenotype_folder = '/Data/'


# In[ ]:


phenotype_file = 'ischemia_df.phe'


# In[5]:


inputs = {
  "bgens_qc.extract_files": "Array[File]",
  "bgens_qc.ref_first": "Boolean (optional, default = true)",
  "bgens_qc.keep_file": "File? (optional)",
  "bgens_qc.output_prefix": "String",
  "bgens_qc.plink2_options": "String (optional, default = \"\")",
  "bgens_qc.geno_sample_files": "Array[File]+",
  "bgens_qc.geno_bgen_files": "Array[File]+"
}


# ## Get .bgen file IDs

# *Note: you need to log into the UKB RAP before running next cell.*

# In[6]:


cmd = ['dx', 'find', 'data', '--name', '*.bgen', '--path', path_to_data, '--brief',]
bgens =[f'dx://{item.decode("utf-8")}' for item in subprocess.check_output(cmd).splitlines()]
bgens


# ## Get .sample file IDs

# *Note: In case of TOPMed and GEL imputed data, you may need to generate new sample files, see [discussion in the community](https://community.dnanexus.com/s/question/0D5t000004CaydsCAB/have-questions-about-the-gel-or-topmed-impute-data-release-ask-them-here)*

# In[7]:


cmd = ['dx', 'find', 'data', '--name', '*.sample', '--path', path_to_data, '--brief',]
samples = [f'dx://{item.decode("utf-8")}' for item in subprocess.check_output(cmd).splitlines()]
samples


# ## Get phenotype file ID
# 
# *Note: you can omit this step if you do not have pheno file (e.i. provide a list of sample to select)*

# In[8]:


cmd = ['dx', 'find', 'data', '--name', phenotype_file, '--path', phenotype_folder, '--brief',]
pheno_file = [f'dx://{item.decode("utf-8")}' for item in subprocess.check_output(cmd).splitlines()][0]
pheno_file


# ## Assemble inputs

# In[9]:


# extract_files are not provided, therefore this key can be deleted
del inputs["bgens_qc.extract_files"]
inputs["bgens_qc.ref_first"] = True
inputs["bgens_qc.keep_file"] = pheno_file
inputs["bgens_qc.output_prefix"] = output_file_prefix
inputs["bgens_qc.plink2_options"] = plink_options
inputs["bgens_qc.geno_sample_files"] = samples
inputs["bgens_qc.geno_bgen_files"] = bgens


# In[10]:


inputs


# Example `inputs`
# ```
# {'bgens_qc.ref_first': True,
#  'bgens_qc.keep_file': 'dx://project-aaa:file-123',
#  'bgens_qc.output_prefix': 'gel_impute_data_snps_qc_pass',
#  'bgens_qc.plink2_options': '--mac 10 --maf 0.0001 --hwe 1e-15 --mind 0.1 --geno 0.1',
#  'bgens_qc.geno_sample_files': ['dx://project-aaa:file-124',
#   'dx://project-aaa:file-125',
#   'dx://project-aaa:file-126',
#   'dx://project-aaa:file-127',
#     ...
#   'dx://project-aaa:file-128',
#   'dx://project-aaa:file-129',
#   'dx://project-aaa:file-130'],
#  'bgens_qc.geno_bgen_files': ['dx://project-aaa:131',
#   'dx://project-aaa:file-132',
#   'dx://project-aaa:file-133',
#   'dx://project-aaa:file-134',
#     ...
#   'dx://project-aaa:file-135',
#   'dx://project-aaa:file-136',
#   'dx://project-aaa:file-137']}
# ```

# ## Save inputs as JSON

# In[11]:


with open('bgens_qc_input.json', 'w') as f:
    json.dump(inputs, f)


# In[ ]:




