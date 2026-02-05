process STAR_ALIGNMENT {
    tag "$sample_id"
    label "process_medium"

    input:
        tuple val(sample_id), path(r1), path(r2)

    output:
        tuple val(sample_id), path("${sample_id}.Aligned.sortedByCoord.out.bam"), emit: alignedBam
        tuple val (sample_id), path ("${sample_id}.Log.final.out"), emit:  alignmentLog
        path "versions.yml", emit: versions

    script:
    """
    STAR \
        --runThreadN ${task.cpus} \
        --genomeDir ${params.refbase} \
        --readFilesIn $r1 $r2 \
        --readFilesCommand zcat \
        --outSAMtype BAM SortedByCoordinate \
        --outFileNamePrefix ${sample_id}. \
        --outSAMattrRGline ID:$sample_id SM:$sample_id PL:ILLUMINA LB:lib1 PU:${sample_id}_PU
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        star: \$(STAR --version 2>&1 | sed -e "s/STAR //g")
    END_VERSIONS    
    """

    // Stub section for simplified testing
    stub:
    """
    touch ${sample_id}.Aligned.sortedByCoord.out.bam
    touch ${sample_id}.Log.out
    touch ${sample_id}.Log.final.out
    touch ${sample_id}.SJ.out.tab

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        star: \$(STAR --version 2>&1 | sed -e "s/STAR //g")
    END_VERSIONS 
    """
}