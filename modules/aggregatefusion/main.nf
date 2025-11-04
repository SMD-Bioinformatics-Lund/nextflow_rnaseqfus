process AGGREGATE_FUSION {
    tag "$smpl_id"
    label "process_low"

    input:
        tuple val(smpl_id), path(fusionCatcher_file)
        tuple val(smpl_id), path(arriba_file)
        tuple val(smpl_id), path(starFusion_file)
        tuple val(smpl_id), path(exonskip_file)
       
    output:
        tuple val(smpl_id), path("${smpl_id}.agg.vcf"), emit: aggregated_vcf
        path "versions.yml", emit: versions  // Emit version information in YAML format

    script:


    // Actual script
    """
    aggregate_fusions.pl \\
        --fusioncatcher ${fusionCatcher_file} \\
        --arriba ${arriba_file} \\
        --starfusion ${starFusion_file} \\
        --exonskip ${exonskip_file} \\
        --priority fusioncatcher,arriba,starfusion,exonskip > ${smpl_id}.agg.vcf
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        perl: \$( echo \$(perl -v 2>&1) |sed 's/.*(v//; s/).*//')
    END_VERSIONS
    """

        // Stub section for simplified testing
    stub:
    """
    touch ${smpl_id}.agg.vcf
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        perl: \$( echo \$(perl -v 2>&1) |sed 's/.*(v//; s/).*//')
    END_VERSIONS
    """

}
