# Subsampler

A snakemake subsampling pipeline for the pandora analysis pipeline. It subsamples Nanopore data based on 
[filtlong](https://github.com/rrwick/Filtlong) (biased subsampling) or [rasusa](https://github.com/mbhall88/rasusa) 
(random subsampling), and Illumina data based on [rasusa](https://github.com/mbhall88/rasusa) 
(random subsampling) only.

The version used in the pandora paper has tag `pandora_paper_tag1`.

# Running

## Requirements

### Dependencies
* python 3.6+;
* singularity;

### Setting up virtualenv
```
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

## Running on the sample example:

1. Download and extract sample data (TODO: add link)
2. `bash scripts/run_pipeline_local.sh -j8`

## Running on the paper data:

1. `git checkout pandora_paper_tag1`

### If you want to run local:

2. `bash scripts/run_pipeline_local.sh -j <NB_OF_THREADS> --configfile config_pandora_paper_tag1.yaml`

### If you want to run on an LSF cluster:

2. `bash scripts/submit_lsf.sh --configfile config.pandora_paper_tag1.yaml`

