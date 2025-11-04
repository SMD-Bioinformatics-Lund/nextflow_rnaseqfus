/*
Import modules according to the subworkflow of the RNA pipelines
*/

include { COYOTE } from '../../modules/coyote/main.nf'


workflow coyoteWorkflow {
    take:
        allFusCalls
        qcData
        metaCoyote
        cronDir

    main:
        COYOTE (allFusCalls, qcData, metaCoyote, cronDir)

    emit:
        coyote = COYOTE.out.coyote_output
        
}