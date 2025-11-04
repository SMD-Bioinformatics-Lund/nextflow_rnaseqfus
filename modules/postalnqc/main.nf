process QCEXTRACT {
    tag "$sample"
    label "process_low"

    input:
        tuple val(sample), path(log), path(starfinal), path(junctionfile)
        tuple val(sampleID), path(genotypes)
        tuple val(smpl_ID), path(geneBodyCoverage)
        tuple val(ID), path(tsv)
    
    output:
        tuple val(sample), path("${sample}.STAR.rnaseq_QC"), emit: rnaseq_qc
        path "versions.yml", emit: versions  // Emit version information in YAML format
        
    script:
    // Actual script
    """
     postaln_qc_fusion.r \\
        -s ${starfinal} \\
        -i ${sample}  \\
        -g ${geneBodyCoverage} \\
        -l ${tsv} > ${sample}.STAR.rnaseq_QC

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        R_version: \$(R --version | grep "R version" | cut -d' ' -f 3)
    END_VERSIONS
    """

        // Stub section for simplified testing
    stub:
    """
    touch ${sample}.STAR.rnaseq_QC

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        R_version: \$(R --version | grep "R version" | cut -d' ' -f 3)
    END_VERSIONS
    """
}


process QCEXTRACT_GMSV5 {
    tag "$sample"
    label "process_low"

    input:
        tuple val(sample), path(log), path(starfinal), path(junctionfile)
        tuple val(sampleID), path(genotypes)
        tuple val(smpl_ID), path(geneBodyCoverage)
        tuple val(ID), path(tsv)
    
    output:
        tuple val(sample), path("${sample}.STAR.rnaseq_QC"), emit: rnaseq_qc
        path "versions.yml", emit: versions  // Emit version information in YAML format
        
    script:
    // Actual script
    """
    postaln_qc_rd_rna.r \\
        -s ${starfinal} \\
        -i ${sample}  \\
        -g ${geneBodyCoverage} \\
        -l ${tsv} > ${sample}.STAR.rnaseq_QC

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        R_version: \$(R --version | grep "R version" | cut -d' ' -f 3)
    END_VERSIONS
    """

        // Stub section for simplified testing
    stub:
    """
    touch ${sample}.STAR.rnaseq_QC

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        R_version: \$(R --version | grep "R version" | cut -d' ' -f 3)
    END_VERSIONS
    """
}