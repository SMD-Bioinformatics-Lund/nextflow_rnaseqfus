process GENEBODY {
    tag "$sample"
    label "process_low"

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
    bam2wig.py -s ${hg_sizes} -i ${bam} -o ${sample} -u
    geneBody_coverage2.py -i ${sample}.bw -r ${ref_rseqc_bed} -o ${sample}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bam2wig: \$(bam2wig.py --version | sed "s/bam2wig.py //g")
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
