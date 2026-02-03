# SMD-Bioinformatics Lund - `nextflow_rnaseqfus`

### RNA Fusion Detection Pipeline (WTS & Fusion Panels)

## Overview

This documentation describes how to run the nextflow_rnaseqfus pipeline for:

- Whole Transcriptome Sequencing (WTS)
- Fusion gene panel analysis

on the SMD Bioinformatics SLURM clusters - Hopper and Grace

It also explains how the pipeline integrates with the SMD automated processing infrastructure.

The main workflow entry point is:

```css
main.nf

```

Detailed documentation for the bioinformatics tools used in the workflow is available in the [documentaion](./doc/)

## Purpose

This document helps users to:

- Launch and manage pipeline runs on the clusters
- Configure the pipeline correctly for different assay types
- Understand how the workflow integrates with automation and downstream systems

## Compute Environment

The pipelines runs on the SLURM-based clusters in hopper and grace

Before running:

1. Ensure `nextflow.config` matches the server environment
2. Select the correct assays configuration
   - WTS_RNA_FUSION
   - TWIST_RNA_FUSION
   - GMS_ST_RNA_FUSION

## Running the pipeline Manually

Load required modules:

```bash

module load singularity Java nextflow/21.10.6

```

### WTS

```bash
nextflow run main.nf \
  -c nextflow.config \
  --csv sample.csv \
  -profile WTS_RNA_FUSION \
  -with-report work/reports/sample.report.html \
  -with-trace work/reports/sample.trace.txt \
  -with-timeline work/reports/sample.timeline.html \
  -work-dir work/nextflow_tmp

```

### TWIST_RNA_FUSION

```bash
nextflow run main.nf \
  -c nextflow.config \
  --csv sample.csv \
  -profile TWIST_RNA_FUSION \
  -with-report work/reports/sample.report.html \
  -with-trace work/reports/sample.trace.txt \
  -with-timeline work/reports/sample.timeline.html \
  -work-dir work/nextflow_tmp

```

### Test / Minimal Profile

```bash
nextflow run main.nf \
  -c nextflow.config \
  --csv sample.csv \
  -profile TEST_PROFILE \
  -with-report work/reports/sample.report.html \
  -with-trace work/reports/sample.trace.txt \
  -with-timeline work/reports/sample.timeline.html \
  -work-dir work/nextflow_tmp
```

## Integration with the SMD Automated Pipeline System

In production, pipeline execution is automated using the bnf-infrastructure system.

Key Components

1. start_nextflow_analysis.pl

A monitoring script that automatically triggers pipeline runs when new CSV files become available from the Bjorn system.

2. pipeline_files.config

Defines:

- Pipeline path
- Container
- Cluster settings
- profile
- Nextflow and Singularity versions

Example Configuration

```bash
[rnaseq-fusion]
pipeline =  /fs1/saile/prj/pipeline_test/nextflow_rnaseqfus/main.nf  --profile profile WTS_RNA_FUSION
container = /production_pipeline/resources/containers/rnaseqfus_active.sif
singularity_version = 3.8.0
nextflow_version = 21.04.2
executor = slurm
cluster = grace
queue = normal

[twistrnafusionv1-0]
pipeline =  /fs1/saile/prj/pipeline_test/nextflow_rnaseqfus/main.nf  --profile profile TWIST_RNA_FUSION
container = /production_pipeline/resources/containers/rnaseqfus_active.sif
singularity_version = 3.8.0
nextflow_version = 21.04.2
executor = slurm
cluster = grace
queue = normal

```
