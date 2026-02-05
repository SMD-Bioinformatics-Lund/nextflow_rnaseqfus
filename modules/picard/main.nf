process ADD_READ_GROUPS {
    tag "$sample_id"
    label "process_low"

    input:
        tuple val(sample_id), path(bam)

    output:
        tuple val(sample_id), path("${sample_id}.rg.bam"), path("${sample_id}.rg.bai"), emit: rgBam
        path "versions.yml", emit: versions

    script:
    """
    java -Xmx10g -jar /usr/picard/picard.jar AddOrReplaceReadGroups \
        I=$bam \
        O=${sample_id}.rg.bam \
        RGID=$sample_id \
        RGLB=lib1 \
        RGPL=ILLUMINA \
        RGPU=${sample_id}_PU \
        RGSM=$sample_id \
        CREATE_INDEX=true
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        Picard AddOrReplaceReadGroups: \$(java -jar /usr/picard/picard.jar AddOrReplaceReadGroups --version | sed 's/Version://')
    END_VERSIONS
    """

    stub:
    """
    touch ${sample_id}.rg.bam 
    touch ${sample_id}.rg.bai

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        Picard AddOrReplaceReadGroups: \$(java -jar /usr/picard/picard.jar AddOrReplaceReadGroups --version | sed 's/Version://')
    END_VERSIONS
    """
}

process MARK_DUPLICATES {
    tag "$sample_id"
    label "process_high"

    input:
    tuple val(sample_id), path(bam), path(bai)

    output:
        tuple val(sample_id), path("${sample_id}.dedup.bam"), path("${sample_id}.dedup.bai"), emit: markedBam
        path "versions.yml", emit: versions

    script:
    """
    java -Xmx90g -jar /usr/picard/picard.jar MarkDuplicates \
        I=$bam \
        O=${sample_id}.dedup.bam \
        M=${sample_id}_dedup_metrics.txt \
        CREATE_INDEX=true \
        VALIDATION_STRINGENCY=LENIENT

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        Picard MarkDuplicates: \$(java -jar /usr/picard/picard.jar MarkDuplicates --version | sed 's/Version://')
    END_VERSIONS
    """

    stub:
    """
    touch ${sample_id}.dedup.bam 
    touch ${sample_id}.dedup.bai

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        Picard MarkDuplicates: \$(java -jar /usr/picard/picard.jar MarkDuplicates --version | sed 's/Version://')
    END_VERSIONS
    """
}

process COLLECT_INSERT_SIZE_METRICS {
    tag "$sample_id"
    label "process_low"

    input:
    tuple val(sample_id), path(bam), path(bai)

    output:
        tuple val(sample_id), path("${sample_id}.insert_size_metrics.txt"), path("${sample_id}.insert_size_histogram.pdf"), emit: insertMetrics
        tuple val(sample_id), path("${sample_id}.insert_size_metrics.tsv"), emit:insertStats
        path "versions.yml", emit: versions

    script:
    """
    java -Xmx20g -jar /usr/picard/picard.jar CollectInsertSizeMetrics \
        I=$bam \
        O=${sample_id}.insert_size_metrics.txt \
        H=${sample_id}.insert_size_histogram.pdf \
        M=0.5
        
    grep -A 1 MEDIAN_INSERT_SIZE ${sample_id}.insert_size_metrics.txt > ${sample_id}.insert_size_metrics.tsv 
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        Picard CollectInsertSizeMetrics: \$(java -jar /usr/picard/picard.jar CollectInsertSizeMetrics --version | sed 's/Version://')
    END_VERSIONS
    """

    stub:
    """
    touch ${sample_id}.insert_size_metrics.txt 
    touch ${sample_id}.insert_size_histogram.pdf
    touch ${sample_id}.insert_size_metrics.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        Picard CollectInsertSizeMetrics: \$(java -jar /usr/picard/picard.jar CollectInsertSizeMetrics --version | sed 's/Version://')
    END_VERSIONS
    """
}

process COLLECT_RNA_SEQ_METRICS {
    tag "$sample_id"
    label "process_low"

    input:
        tuple val(sample_id), path(bam), path(bai)

    output:
        tuple val(sample_id), path("${sample_id}_rnaseq_metrics.txt"), path("${sample_id}_gene_body_coverage.pdf"), emit: rnaseqMetrics
        path "versions.yml", emit: versions

    script:
    """
    java -Xmx20g -jar /usr/picard/picard.jar CollectRnaSeqMetrics \
        I=$bam \
        O=${sample_id}_rnaseq_metrics.txt \
        REF_FLAT=${params.ref_flat} \
        STRAND_SPECIFICITY=SECOND_READ_TRANSCRIPTION_STRAND \
        R=${params.fasta} \
        CHART_OUTPUT=${sample_id}_gene_body_coverage.pdf \
        VALIDATION_STRINGENCY=LENIENT
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        Picard CollectRnaSeqMetrics: \$(java -jar /usr/picard/picard.jar CollectRnaSeqMetrics --version | sed 's/Version://')
    END_VERSIONS
    """

    stub:
    """
    touch ${sample_id}_rnaseq_metrics.txt 
    touch ${sample_id}_gene_body_coverage.pdf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        Picard CollectRnaSeqMetrics: \$(java -jar /usr/picard/picard.jar CollectRnaSeqMetrics --version | sed 's/Version://')
    END_VERSIONS
    """
}

process COLLECT_HSMETRICS {
    tag "$sample_id"
    label "process_medium"

    input:
        tuple val(sample_id), path(bam), path(bai)

    output:
        tuple val(sample_id), path("${sample_id}_hs_metrics.txt"), emit: hsMetrics
        path "versions.yml", emit: versions

    script:
    """
    sentieon driver \
        -r ${params.fasta} \
        -t ${task.cpus} \
        -i ${bam} \
        --algo HsMetricAlgo \
        --targets_list ${params.probes}  \
        --baits_list ${params.targets} \
        ${sample_id}_hs_metrics.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sentieon: \$(echo \$(sentieon driver --version 2>&1) | sed -e "s/sentieon-genomics-//g")
    END_VERSIONS
    """
    stub:
    """
    touch ${sample_id}_hs_metrics.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sentieon: \$(echo \$(sentieon driver --version 2>&1) | sed -e "s/sentieon-genomics-//g")
    END_VERSIONS
    """
}


process INNER_DISTANCE {
    tag "$sample_id"
    label "process_medium"

    input:
    tuple val(sample_id), path(bam), path(bai)

    output:
    tuple val(sample_id), path("${sample_id}.inner_distance_metrics.tsv"), emit:insertStatsRseqc
    path "versions.yml", emit: versions

    script:
    """
    inner_distance.py \
        -i $bam \
        -o ${sample_id} \
        -r ${params.panel_bed} > output.txt
    
    head -n 2 output.txt > ${sample_id}.inner_distance_metrics.tsv
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        RSeqQC inner_distance.py: \$(inner_distance.py --version| sed 's/inner_distance.py //')
    END_VERSIONS
    """
    stub:
    """
    touch ${sample_id}.inner_distance_metrics.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        RSeqQC inner_distance.py: \$(inner_distance.py --version| sed 's/inner_distance.py //')
    END_VERSIONS
    """
}
    