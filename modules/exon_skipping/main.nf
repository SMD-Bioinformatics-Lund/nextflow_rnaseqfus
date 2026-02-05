process MET_EGFR {
    tag "$sample"
    label "process_low"

    input:
        path bedFile
        tuple val(sample), path(log), path(starfinal), path(junctionfile)
    
    output:
        tuple val(sample), path("${sample}_MET_EGFR.txt"), emit: result
        path "versions.yml", emit: versions  // Emit version information in YAML format
    
    script:
    // Actual script
    """
    exon_skipping.py --bed_file ${bedFile} --junction_file ${junctionfile} --result_file ${sample}_MET_EGFR.txt
        
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version 2>&1| sed -e 's/Python //g')
    END_VERSIONS
    """

    // Stub section for simplified testing
    stub:
    """
    touch ${sample}_MET_EGFR.txt
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version 2>&1| sed -e 's/Python //g')
    END_VERSIONS
    """
}
