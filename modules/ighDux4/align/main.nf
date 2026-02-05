process IGHDUX4_ALIGN {
    tag "$sampleId"
    label "process_high"

    input:
        path (star_ref)
        tuple val(sampleId), path (read1), path(read2)  
        
    output:
        tuple val(sampleId), path ("${sampleId}.Aligned.sortedByCoord.out.bam"), emit: dux4Bam
        path "versions.yml", emit: versions
        
    script:
    def prefix = "${sampleId}" + "."
    
    """
    STAR  \\
        --genomeDir  ${star_ref} \\
        --readFilesIn ${read1} ${read2} \\
        --runThreadN ${task.cpus} \\
        --outSAMtype BAM SortedByCoordinate \\
        --readFilesCommand zcat  \\
        --limitBAMsortRAM 10000000000 \\
        --outFileNamePrefix ${prefix} \\
        --outFilterMultimapNmax 200  

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        star: \$(STAR --version 2>&1 | sed -e "s/STAR //g")
    END_VERSIONS    
    """

    stub:
    """
    touch ${sampleId}.Aligned.sortedByCoord.out.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        star: \$(STAR --version 2>&1 | sed -e "s/STAR //g")
    END_VERSIONS
    """
}
