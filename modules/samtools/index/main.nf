process SAMTOOLS_INDEX {
    tag "$sampleId"
    label 'process_medium'

    input:
        tuple val(sampleId), path(bam)

    output: 
        path('*bam.bai')

    """
    samtools \\
        index \\
        -@ ${task.cpus-1} \\
        ${bam} 
    """
}