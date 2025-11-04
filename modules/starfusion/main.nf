process STARFUSION_FUSCALL {
    tag "$sampleId"
    label "process_high"

    input:
        path (star_fusion_ref)
        tuple val(sampleId), path (read1), path(read2)  
    
    output:
        tuple val(sampleId), path("*.star-fusion.fusion_predictions.tsv"), emit: results
        path "versions.yml", emit: versions // Emit version information in YAML format
        
    script:
    def option = "--left_fq ${read1} --right_fq ${read2}"

    // Actual script
    """
    STAR-Fusion --genome_lib_dir ${star_fusion_ref} ${option} --CPU ${task.cpus} --FusionInspector validate --verbose_level 2 --output_dir .

    mv  star-fusion.fusion_predictions.tsv ${sampleId}.star-fusion.fusion_predictions.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        STAR-Fusion: \$(STAR-Fusion --version 2>&1 | grep -i 'version' | sed 's/STAR-Fusion version: //')
    END_VERSIONS
    """
    
    // Stub section for simplified testing
    stub:
    """
    touch ${sampleId}.star-fusion.fusion_predictions.tsv
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        STAR-Fusion: \$(STAR-Fusion --version 2>&1 | grep -i 'version' | sed 's/STAR-Fusion version: //')
    END_VERSIONS
    """
}
