process QUALIMAP_QC {
    tag "$sampleId"
    label "process_low"

    input:
        path (gtf)
        tuple val(sampleId), path(bam)
        
    output:
        tuple val(sampleId), path("${prefix}")
        
    script:
    def prefix = "${sampleId}"
    def paired_end = '-pe' // change if needed for single end reads
    def memory = task.memory.toGiga() + "G"
    def strandedness = 'strand-specific-reverse'

    """
    unset DISPLAY
    mkdir tmp
    export _JAVA_OPTIONS=-Djava.io.tmpdir=./tmp
    qualimap \\
        --java-mem-size=$memory \\
        rnaseq \\
        -bam $bam \\
        -gtf $gtf \\
        -p $strandedness \\
        $paired_end \\
        -outdir $prefix
    """
}
