process AGGREGATE_FUSION_STD_CUSTOM {
    tag "$smpl_id"
    label "process_low"

    input:
        tuple val(smpl_id), path(fusionCatcher_file)
        tuple val(smpl_id), path(arriba_file)
        tuple val(smpl_id), path (starFusion_file) 
        tuple val(smpl_id), path (exonskip_file) 
       
    output:
        tuple val(smpl_id), path ("${smpl_id}.agg.vcf")

    script:    
    """
    aggregate_fusions.pl \\
        --fusioncatcher ${fusionCatcher_file} \\
        --arriba ${arriba_file} \\
        --starfusion ${starFusion_file} \\
        --exonskip ${exonskip_file} \\
        --priority fusioncatcher,arriba,starfusion,exonskip > ${smpl_id}.agg.vcf    
    """
}



