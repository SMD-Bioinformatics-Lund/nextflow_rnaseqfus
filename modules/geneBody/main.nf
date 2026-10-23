process GENEBODY {
    tag "$sample"
    label "process_medium"

    input:
        tuple val(sample), path(bam), path(bai)
        path(ref_rseqc_bed)
        path(hg_sizes)

    output:
        tuple val(sample), file("${sample}.geneBodyCoverage.txt"), emit: gene_body_coverage
        path "versions.yml", emit: versions  // Emit version information in YAML format

    script:
    // Actual script
    """
    cp ${bai} ${bam}.bai
    samtools view -@ ${task.cpus - 1} -b -o ${sample}.primary.bam ${bam} {1..22} X Y
    samtools index -@ ${task.cpus - 1} ${sample}.primary.bam

    awk '\$1 ~ /^([0-9]+|X|Y)\$/' ${hg_sizes} > primary.chrom.sizes

    bam2wig.py -s primary.chrom.sizes -i ${sample}.primary.bam -o ${sample} -u
    geneBody_coverage2.py -i ${sample}.bw -r ${ref_rseqc_bed} -o ${sample}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bam2wig: \$(bam2wig.py --version 2>&1 | sed "s/bam2wig.py //g")
        geneBody_coverage: \$(geneBody_coverage2.py --version 2>&1 | sed -e "s/geneBody_coverage2.py //g")
    END_VERSIONS
    """

    // Stub section for simplified testing
    stub:
    """
    touch ${sample}.geneBodyCoverage.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bam2wig: \$(bam2wig.py --version | sed "s/bam2wig.py //g")
        geneBody_coverage: \$(geneBody_coverage2.py --version 2>&1 | sed -e "s/geneBody_coverage2.py //g")
    END_VERSIONS
    """
}
