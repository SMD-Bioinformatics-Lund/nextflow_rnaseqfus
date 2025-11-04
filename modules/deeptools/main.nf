process DEEPTOOLS {
    tag "$sample"
    label "process_low"

    input:
        tuple val(sample), path(bam), path(bai)
    
    output:
        tuple val(sample), file("${sample}.tsv"), emit: fragment_size
        path "versions.yml", emit: versions  // Emit version information in YAML format
        
    script:

    // Actual script
    """
    bamPEFragmentSize -b ${bam} -hist ${sample}_fragmentSize.png \\
        --plotTitle "Fragment Size of ${sample} PE RNAseq data" \\
        --maxFragmentLength 0 \\
        --samplesLabel ${sample} \\
        --table ${sample}.tsv
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        deeptools: \$(deeptools --version | sed "s/deeptools //g")
    END_VERSIONS
    """

    // Stub section for simplified testing
    stub:
    """
    touch ${sample}.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        deeptools: \$(deeptools --version | sed "s/deeptools //g")
    END_VERSIONS
    """
}
