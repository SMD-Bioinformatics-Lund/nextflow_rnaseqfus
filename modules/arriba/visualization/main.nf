process ARRIBA_VISUALIZATION {
    tag "$sampleId"
    label "process_medium"

    input:
        tuple val(sampleId), path(bam), path(bai), path(fusion)
        path gtf
        path cytobands
        path proteinDomains
        
    output:
        tuple val(sampleId), path("*.pdf"), emit: visualization
        path "versions.yml", emit: versions  // Emit version information in YAML format
        
    script:
    def prefix = "${sampleId}"

    // Actual script
    """
    draw_fusions.R \\
        --fusions=$fusion \\
        --alignments=$bam \\
        --output=${prefix}.pdf \\
        --annotation=${gtf} \\
        --cytobands=${cytobands} \\
        --proteinDomains=${proteinDomains}
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        R_version: \$(R --version | grep "R version" | cut -d' ' -f 3)
    END_VERSIONS
    """

        // Stub section for simplified testing
    stub:
    """
    touch ${sampleId}.pdf
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        R_version: \$(R --version | grep "R version" | cut -d' ' -f 3)
    END_VERSIONS
    """
}
