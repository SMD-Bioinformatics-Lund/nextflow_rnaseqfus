process EXTRACT_EXPRESSION {

    publishDir "${params.outdir}/finalResults", mode: 'copy'
    errorStrategy 'ignore'

    input:
        tuple val(smpl_id), path(quants)

    output:
        tuple val(smpl_id), path("${smpl_id}.salmon.expr")
        tuple val(smpl_id), path("${smpl_id}.expr.classified")
        path("versions.yml")

	script:
    """
    extract_expression_fusion_ny.R \
        ${params.genesOfIntrest} \
        ${quants} \
        ${params.reference_expression_all} \
        ${smpl_id}.salmon.expr

    fusion_classifier_report_ny.R \
        ${smpl_id} \
        ${quants} \
        ${params.hem_classifier_salmon} \
        ${params.ensembl_annotation} \
        ${smpl_id}.expr.classified

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        extract_expression_fusion_ny: "$( extract_expression_fusion_ny.R --version 2>/dev/null || echo unknown )"
        fusion_classifier_report_ny: "$( fusion_classifier_report_ny.R --version 2>/dev/null || echo unknown )"
        perl: "$( echo $(perl -v 2>&1) | sed 's/.*(v//; s/).*//' )"
    END_VERSIONS
    """

    stub:
    """
    touch ${smpl_id}.salmon.expr
    touch ${smpl_id}.expr.classified

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        extract_expression_fusion_ny: "stub_version"
        fusion_classifier_report_ny: "stub_version"
        perl: "\$( echo \$(perl -v 2>&1) | sed 's/.*(v//; s/).*//' )"
    END_VERSIONS
    """ 
}
