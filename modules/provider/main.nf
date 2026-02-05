process PROVIDER {
    tag "$sample"
    label "process_low"

    input:
        path(ref_bed)
        path(ref_bedXY)
        tuple val(sample), path(bam), path(bai)
    
    output:
        tuple val(sample), path("${sample}.genotypes"), emit: genotypes
        path "versions.yml", emit: versions  // Emit version information in YAML format
        
    script:
    // Actual script
    """
    provider.pl --out ${sample} \\
        --bed ${ref_bed} \\
        --bam ${bam} \\
        --bedxy ${ref_bedXY}
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        perl: \$( echo \$(perl -v 2>&1) |sed 's/.*(v//; s/).*//')
    END_VERSIONS

    """

    // Stub section for simplified testing
    stub:
    """
    touch ${sample}.genotypes

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        perl: \$( echo \$(perl -v 2>&1) |sed 's/.*(v//; s/).*//')
    END_VERSIONS
    """

}
