# Changelog

All notable changes to the Eyrie sample management system will be documented in this file.

### v2.0.1
- Updated the README.md to reflect the changes in the pipeline and the profiles
- Fixed the issue with the fusion gene list for rescuing Hematological malignancies with 0 supporting reads being included in the final output
- Fixed the issue with the aggregate script for integer values for the counts in the fusions were typed as strings which caused issues with the downstream analysis and filtering
- Update arriba modueles to get the right format of the output for the fusion gene list for rescuing Hematological malignancies


### v2.0.0

### Major release

- WTS and fusion gene panel remerged into same pipeline
- Assay based profile (WTS, TWIST-RNA_fusion, GMS-ST)
- Fusion gene list for rescuing Hematological malignancies for rare fusions
- Optimized DUX4-IGH parameters set for the FusionCatcher
- Towards DSL2 nextflow format
- Batch-start for all profiles

### v1.0.1

- Added the CHANGELOGS
- Update the .gitignore files to suppress the unwanted files

### v1.0

- Default branch changed from master to main
- Merged the old production version to the updated v1.0.0
- Released he adhoc version as v1.0.0

## 2024-04-16 [Unreleased]
