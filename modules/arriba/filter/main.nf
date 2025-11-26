process ARRIBAFILTER {
        // Filter the fusion variants identified based on the gene list provided and proritized variants annonated in the functional events.
        // to create the fusion specific to  the ALL there is a gene list that is selected as fusion.panel.selected.AL and which is sorted to give as  sorted.gene.fusion.panel.AL Finally the list is given as grep -f sorted.gene.fusion.panel.AL  fusion.panel.AL > genefusion.panel.AL

        // At this current version, remeber that the fusion that are in either high confidence or medium confidence from arriba are directly ouputted and drawn using the arribaDraw script. Only the filter is applied to the fusion that are low confidence and only restricted to the ones that the present in both genes. Yes this is a strict module but the rationale here in is there is potentially loads of false positive and we would like only few for the intrepreation for decreasing the search space

        publishDir "$OUTDIR/fusion", mode: 'copy'

        when:
                params.arriba

        input:
                set val(smpl_id),  path(tsv) from prelim_list_arriba_ch

        output:
                set val(smpl_id),  path("${smpl_id}_arriba_fusions.tsv") into final_list_arriba_ch, fusion_vis_arriba_ch


        script:

        """
        head -n 1 ${smpl_id}.combined.tsv > header.txt
        filterFusionGene.py --g ${params.genefusion.panel.AL} --f ${tsv}
        uniq Selected.fusion.tsv > uniq_fusion.tsv
        cat header.txt uniq_fusion.tsv > ${smpl_id}_arriba_fusions.tsv
        """
}