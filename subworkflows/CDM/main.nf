/*
Import modules according to the subworkflow of the RNA pipelines
*/
include { CDM_REGISTER } from '../../modules/CDM/main.nf'

workflow cdmWorkflow {
    take:
        samplecdm
        outputfile
        
    main:
        CDM_REGISTER(samplecdm, outputfile)

    emit:
        CDM = CDM_REGISTER.out
}