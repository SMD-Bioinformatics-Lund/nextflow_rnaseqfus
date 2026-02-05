process FUSIONCATCHER {
    tag "$sampleId"
    label "process_high"

    input:
        path refFusioncatcher
        tuple val(sampleId), path(read1), path(read2)
    
    output:
        tuple val(sampleId), path("${sampleId}.final-list_candidate-fusion-genes.txt"), emit: results
        path "versions.yml", emit: versions  // Emit version information in YAML format
    
    script:
    def option =  "${read1},${read2}"

    // Actual script
    """
    fusioncatcher.py -d ${refFusioncatcher} -i ${option} -p ${task.cpus} --limitSjdbInsertNsj 50000000 --limitOutSJcollapsed 2000000  -o .
    mv final-list_candidate-fusion-genes.txt ${sampleId}.final-list_candidate-fusion-genes.txt
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fusioncatcher: \$(fusioncatcher.py --version 2>&1 | sed -e "s/fusioncatcher.py //g")
    END_VERSIONS
    """
    
    // Stub section for simplified testing
    stub:
    """
    touch ${sampleId}.final-list_candidate-fusion-genes.txt
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fusioncatcher: \$(fusioncatcher.py --version 2>&1 | sed -e "s/fusioncatcher.py //g")
    END_VERSIONS
    """
}
