
include { CDM_REGISTER } from '../../modules/CDM/main.nf'

workflow cdmWorkflow {
    take:
        cdm
        output
        
    main:
        CDM_REGISTER(cdm, output)

    emit:
        CDM = CDM_REGISTER.out
}