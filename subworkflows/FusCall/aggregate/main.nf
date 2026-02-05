include { AGGREGATE_FUSION } from '../../../modules/aggregatefusion/main.nf'

workflow aggFusionWorkflow {
    take:
    fusionCatcher
    arribaFusion
    starFusion
    exonskip

    main:
    AGGREGATE_FUSION(fusionCatcher, arribaFusion, starFusion, exonskip)  
    
    emit:
    aggregate = AGGREGATE_FUSION.out
}
