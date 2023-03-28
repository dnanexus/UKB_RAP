# How to run bgens_qc.wdl

1. Log into the UKB RAP platform in your command line. [Documentation](https://dnanexus.gitbook.io/uk-biobank-rap/getting-started/creating-an-account)
2. Run `generate_inputs.ipynb` to generate `bgens_qc_input.json`.
    1. In case of TOPMed and GEL imputed data, you may need to generate new sample files, see [discussion in the community](https://community.dnanexus.com/s/question/0D5t000004CaydsCAB/have-questions-about-the-gel-or-topmed-impute-data-release-ask-them-here)
3. Download the latest dxCompiler release from [here](https://github.com/dnanexus/dxCompiler/releases).
4. Compile WDL workflow into DNAnexus native workflow and load it into the platform.

    `java -jar <path_to_downloaded_dxCompiler>dxCompiler-2.XX.X.jar compile research_project/bgens_qc/bgens_qc.wdl -project project-XXX -inputs research_project/bgens_qc/bgens_qc_input.json -archive -folder '<path_to_folder_on_UKB_RAP>'`

    `-folder` takes filepath where you want to store workflow files

    This code assumes that you are in the UKB_RAP directory in the terminal on your local machine.

    This code will generate `bgens_qc_input.dx.json` in the working directory.

5. To run workflow, type the following command in the terminal:

    `dx run <path_to_folder_on_UKB_RAP>/bgens_qc -f research_project/bgens_qc/bgens_qc_input.dx.json`