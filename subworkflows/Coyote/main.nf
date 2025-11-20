/*
Import modules according to the subworkflow of the RNA pipelines
*/

include { COYOTE } from '../../modules/coyote/main.nf'

// include { COYOTE_TEST } from '../../modules/coyote/test.nf'

// workflow coyoteWorkflow {
//     take:
//         allFusCalls
//         qcData
//         metaCoyote
//         cronDir

//     main:
//         COYOTE (allFusCalls, qcData, metaCoyote, cronDir)

//     emit:
//         coyote = COYOTE.out.coyote_output
        
// }


workflow coyoteWorkflow {
    take:
        results
        metaCoyote

    main:
        COYOTE (results, metaCoyote)

    emit:
        coyote = COYOTE.out.coyote_output
        
}

