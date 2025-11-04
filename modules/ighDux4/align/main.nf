process IGHDUX4_ALIGN {
    tag "$sampleId"
    label "process_high"

    input:
        path (star_ref)
        tuple val(sampleId), path (read1), path(read2)  
        
    output:
        tuple val(sampleId), path ("${sampleId}.Aligned.sortedByCoord.out.bam")
        
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
    """
}

