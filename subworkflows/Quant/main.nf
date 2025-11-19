include { SALMON } from '../../modules/salmon/main.nf'
include { EXPRS_CLASS }	from '../../modules/extract_expression/main.nf'

workflow quantWorkflow {

    take:
        reads_ch

    main:
  		ch_versions = Channel.empty()

        SALMON(reads_ch)
		ch_versions = ch_versions.mix(SALMON.out.versions)

      	EXPRS_CLASS( SALMON.out.quant)
        ch_versions = ch_versions.mix(EXPRS_CLASS.out.versions)


    emit:
        expr            = EXPRS_CLASS.out.goi_quant
        cls             = EXPRS_CLASS.out.exprs_class
		versions        = ch_versions
}