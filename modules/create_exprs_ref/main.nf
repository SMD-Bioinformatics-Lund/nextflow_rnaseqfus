process CREATE_EXPR_REF {

    publishDir "${params.refbase}/extract_expr_ref", mode: 'copy'

    when:
        params.create_exprRef

    output:
        path("reference_expression.all.tsv")
        path("genes_of_interest.tsv")
        path("versions.yml")

    script:
    """
    extract_expression_fusion_ny.R create-reference

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        extract_expression_fusion_ny: "$( extract_expression_fusion_ny.R --version 2>/dev/null || echo unknown )"
        perl: "$( echo $(perl -v 2>&1) | sed 's/.*(v//; s/).*//' )"
    END_VERSIONS
    """
	
    stub:
    """
    touch reference_expression.all.tsv
    touch genes_of_interest.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        extract_expression_fusion_ny: "stub_version"
        perl: "\$( echo \$(perl -v 2>&1) | sed 's/.*(v//; s/).*//' )"
    END_VERSIONS
    """


}
