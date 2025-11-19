process EXPRS_CLASS {
    tag "${smpl_id}"
    label "process_low"
    
    input:
        tuple val(smpl_id), path(quants)
    
    output:
        tuple val(smpl_id), path("*.salmon.expr"), emit: goi_quant
        tuple val(smpl_id), path("*.expr.classified"), emit: exprs_class
        path("versions.yml"), emit: versions
    
   when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        def args2 = task.ext.args2 ?: ''
        def args3 = task.ext.args3 ?: ''

        """
        extract_expression_fusion_ny.R \\
            ${args} \\
            ${quants} \\
            ${args2} \\
            ${smpl_id}.salmon.expr

        fusion_classifier_report_ny.R \
            ${smpl_id} \\
            ${quants} \\
            ${args3} \\
            ${smpl_id}.expr.classified

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            R_version: \$(R --version | grep "R version" | cut -d' ' -f 3)
        END_VERSIONS
        """

    stub:
        """
        touch ${smpl_id}.salmon.expr
        touch ${smpl_id}.expr.classified
        echo "Parameters: ${task.ext.args ?: ''} ${task.ext.args2 ?: ''} ${task.ext.args3 ?: ''}" > parameters.txt

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            R_version: \$(R --version | grep "R version" | cut -d' ' -f 3)
        END_VERSIONS
        """
}
