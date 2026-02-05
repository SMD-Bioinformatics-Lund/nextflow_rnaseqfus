process SUBSAMPLE {
    tag "$sampleId"
    label "process_high"

    input:
        val(ReadNum)
        tuple val(sampleId), path(read1), path(read2)
    
    output:
        tuple val(sampleId), path("*_read1_sub.fastq.gz"), path("*_read2_sub.fastq.gz"), emit: sample
        path "versions.yml", emit: versions  // Output as a single YAML file

    script:
    
    // Script for actual execution
    """
    n_reads="\$(zcat $read1 | grep  '@'|wc -l)" 
    echo "Number of reads:" \${n_reads} 
    if [[ \${n_reads} -ge ${ReadNum} ]]
    then
        seqtk sample -s100 ${read1} ${ReadNum} > read1_sub.fastq
        seqtk sample -s100 ${read2} ${ReadNum} > read2_sub.fastq
    
        pigz read1_sub.fastq  
        pigz read2_sub.fastq 
        mv read1_sub.fastq.gz  ${sampleId}_read1_sub.fastq.gz
        mv read2_sub.fastq.gz  ${sampleId}_read2_sub.fastq.gz
    
    else
        mv ${read1} ${sampleId}_read1_sub.fastq.gz
        mv ${read2} ${sampleId}_read2_sub.fastq.gz
    fi

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        seqtk: \$(echo \$(seqtk 2>&1) | sed 's/.*Version: //; s/ .*//')
        pigz: \$(pigz --version 2>&1 | sed -e "s/pigz //g")
    END_VERSIONS
    
    """
    stub:
    """
    touch ${sampleId}_read1_sub.fastq.gz
    touch ${sampleId}_read2_sub.fastq.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        seqtk: \$(echo \$(seqtk 2>&1) | sed 's/.*Version: //; s/ .*//')
        pigz: \$(pigz --version 2>&1 | sed -e "s/pigz //g")
    END_VERSIONS
    """
}
