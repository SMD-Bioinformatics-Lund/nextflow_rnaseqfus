process ARRIBA_ALIGN {
    tag "$sampleId"
    label "process_high"

    input:
        path (star_ref)
        tuple val(sampleId), path (read1), path(read2)  
        
    output:
        tuple val(sampleId), path ("${sampleId}.Aligned.out.bam"), emit: bam
        tuple val(sampleId), path('*Log.out'), path('*Log.final.out'), path('*SJ.out.tab'), emit: logs 
        path "versions.yml", emit: versions
        
    script:
    def prefix = "${sampleId}" + "."
    
    """
    STAR --runThreadN ${task.cpus} \\
        --genomeDir  ${star_ref} \\
        --genomeLoad NoSharedMemory \\
        --readFilesIn ${read1} ${read2} \\
        --readFilesCommand zcat  \\
        --outFileNamePrefix ${prefix} \\
        --outSAMtype BAM Unsorted \\
        --outSAMunmapped Within \\
        --outBAMcompression 0 \\
        --outFilterMultimapNmax 200 \\
        --peOverlapNbasesMin 10 \\
        --alignSplicedMateMapLminOverLmate 0.5 \\ --alignSJstitchMismatchNmax 5 -1 5 5 \\
        --chimSegmentMin 10 \\
        --chimOutType WithinBAM SoftClip \\
        --chimJunctionOverhangMin 10 \\
        --chimScoreDropMax 30 \\
        --chimScoreJunctionNonGTAG 0 \\
        --chimScoreSeparation 1 \\
        --chimSegmentReadGapMax 3 \\
        --chimMultimapNmax 50   

        
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        star: \$(STAR --version 2>&1 | sed -e "s/STAR //g")
    END_VERSIONS    
    """

    // Stub section for simplified testing
    stub:
    """
    touch ${sampleId}.Aligned.out.bam
    touch ${sampleId}.Log.out
    touch ${sampleId}.Log.final.out
    touch ${sampleId}.SJ.out.tab

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        star: \$(STAR --version 2>&1 | sed -e "s/STAR //g")
    END_VERSIONS 
    """
}