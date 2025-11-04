process FILTER_FUSION {
    tag "$sample"
    label "process_low"

    input:
        tuple val(sample), path (aggregatefusion) 
        path geneList
    
    output:
        tuple val(sample), path("${sample}.agg.filtered.vcf"), emit: filteredfusion
        path "versions.yml", emit: versions  // Emit version information in YAML format
    
    script:
    // Actual script
    """
    filter_ST_genes.py --input  ${aggregatefusion} --genes ${geneList} --out ${sample}.agg.filtered.vcf
        
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version 2>&1| sed -e 's/Python //g')
    END_VERSIONS
    """

    // Stub section for simplified testing
    stub:
    """
    touch ${sample}.agg.filtered.vcf
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version 2>&1| sed -e 's/Python //g')
    END_VERSIONS
    """
}
