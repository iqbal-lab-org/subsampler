import pandas as pd
from snakemake.utils import min_version
min_version("5.22.1")

# ======================================================
# Config files
# ======================================================
configfile: "config.yaml"

samples_file = config["samples"]
samples = pd.read_csv(samples_file)
output_dir = config["output_dir"]
coverages = config["coverages"]
technologies = config["technologies"]
strategies = config["strategies"]
mean_q_weight = config["mean_q_weight"]
min_length = config["min_length"]
seed = config["seed"]
subsampler_container = config["container"]


# ======================================================
# Utility functions
# ======================================================
def get_illumina_reads(samples, sample_name, first_or_second):
    assert first_or_second in [1, 2]
    assert sample_name in samples.sample_id.to_list()
    sample_path = samples[samples.sample_id == sample_name]["sample_path"].tolist()[0]
    return f"{sample_path}/{sample_name}.illumina_{first_or_second}.fastq.gz"

def get_nanopore_reads(samples, sample_name):
    assert sample_name in samples.sample_id.to_list()
    sample_path = samples[samples.sample_id == sample_name]["sample_path"].tolist()[0]
    return f"{sample_path}/{sample_name}.nanopore.fastq.gz"

def get_assembly(samples, sample_name):
    assert sample_name in samples.sample_id.to_list()
    sample_path = samples[samples.sample_id == sample_name]["sample_path"].tolist()[0]
    return f"{sample_path}/{sample_name}.ref.fa"




# ======================================================
# Rules
# ======================================================
def get_subsampled_read_files_core(samples, coverages, strategies, technologies):
    return expand(output_dir+"/{sample}/{sample}.{coverage}x.{sub_strategy}.{technology}.fastq",
                  sample=samples,
                  coverage=coverages,
                  sub_strategy=strategies,
                  technology=technologies)
def get_subsampled_read_files(samples, coverages, strategies, technologies):
    subsampled_read_files = []
    for technology in technologies:
        if technology == "illumina":
            subsampled_read_files.extend(get_subsampled_read_files_core(
                samples, coverages, ["random"], ["illumina"]
            ))
        else:
            subsampled_read_files.extend(get_subsampled_read_files_core(
                samples, coverages, strategies, ["nanopore"]
            ))
    return subsampled_read_files

rule all:
    input:
        get_subsampled_read_files(samples.sample_id, coverages, strategies, technologies)


rule subsample_nanopore:
    input:
        reads=lambda wildcards: get_nanopore_reads(samples, wildcards.sample),
        ref=lambda wildcards: get_assembly(samples, wildcards.sample)
    output:
        subsampled_reads = output_dir +"/{sample}/{sample}.{coverage}x.{sub_strategy}.nanopore.fastq"
    threads: 1
    resources:
        mem_mb=lambda wildcards, attempt: 1000 * attempt
    singularity: subsampler_container
    log:
        "logs/subsample_nanopore/{sample}/{sample}.{coverage}x.{sub_strategy}.nanopore.log"
    shell:
        """
        bash scripts/downsample_reads.sh \
            nanopore \
            {input.reads} \
            {input.ref} \
            {wildcards.coverage} \
            {output.subsampled_reads} \
            {wildcards.sub_strategy} \
            {min_length} \
            {mean_q_weight} \
            {seed} 2> {log}  
        """


rule subsample_PE_illumina:
    input:
        reads_1=lambda wildcards: get_illumina_reads(samples, wildcards.sample, 1),
        reads_2=lambda wildcards: get_illumina_reads(samples, wildcards.sample, 2),
        ref=lambda wildcards: get_assembly(samples, wildcards.sample)
    output:
        subsampled_reads_1 = output_dir+"/{sample}/{sample}.{coverage}x.random.illumina.1.fastq",
        subsampled_reads_2 = output_dir+"/{sample}/{sample}.{coverage}x.random.illumina.2.fastq"
    threads: 1
    resources:
        mem_mb=lambda wildcards, attempt: 1000 * attempt
    log:
        "logs/subsample_PE_illumina/{sample}/{sample}.{coverage}x.random.illumina.log"
    singularity: subsampler_container
    shell:
        """
        bash scripts/downsample_reads.sh \
            illumina_PE \
            {input.reads_1} \
            {input.reads_2} \
            {input.ref} \
            {wildcards.coverage} \
            {output.subsampled_reads_1} \
            {output.subsampled_reads_2} \
            {seed}
        """


rule concat_both_subsampled_PE_illumina_reads:
    input:
         subsampled_reads_1 = rules.subsample_PE_illumina.output.subsampled_reads_1,
         subsampled_reads_2 = rules.subsample_PE_illumina.output.subsampled_reads_2
    output:
         subsampled_reads = output_dir+"/{sample}/{sample}.{coverage}x.random.illumina.fastq"
    threads: 1
    resources:
        mem_mb=lambda wildcards, attempt: 1000 * attempt
    log:
        "logs/concat_both_subsampled_PE_illumina_reads/illumina.{sample}.{coverage}x.log"
    shell:
        "cat {input.subsampled_reads_1} {input.subsampled_reads_2} > {output.subsampled_reads}"


