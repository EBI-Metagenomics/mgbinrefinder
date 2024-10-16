/*
    ~~~~~~~~~~~~~~~~~~
     Input validation
    ~~~~~~~~~~~~~~~~~~
*/
name = "${params.name}"
binner1_files = file("${params.binner1}/*", checkIfExists: true)
binner2_files = file("${params.binner2}/*", checkIfExists: true)
binner3_files = file("${params.binner3}/*", checkIfExists: true)
/*
    ~~~~~~~~~~~~~~~~~~
     DBs
    ~~~~~~~~~~~~~~~~~~
*/
ref_checkm = channel.fromPath("${params.checkm_ref_db}", checkIfExists: true)
/*
    ~~~~~~~~~~~~~~~~~~
     Steps
    ~~~~~~~~~~~~~~~~~~
*/
include { CUSTOM_DUMPSOFTWAREVERSIONS                                      } from '../modules/nf-core/custom/dumpsoftwareversions/main'
include { CHECKM2 as CHECKM2_BINNER1                                       } from '../modules/local/checkm2'
include { CHECKM2 as CHECKM2_BINNER2                                       } from '../modules/local/checkm2'
include { CHECKM2 as CHECKM2_BINNER3                                       } from '../modules/local/checkm2'
include { CHECKM2 as CHECKM_FINAL                                          } from '../modules/local/checkm2'
include { CONSOLIDATE_BINS                                                 } from '../modules/local/consolidate_bins'
include { RENAME_AND_CHECK_SIZE_BINS as RENAME_AND_CHECK_SIZE_BINS_BINNER1 } from '../modules/local/utils'
include { RENAME_AND_CHECK_SIZE_BINS as RENAME_AND_CHECK_SIZE_BINS_BINNER2 } from '../modules/local/utils'
include { RENAME_AND_CHECK_SIZE_BINS as RENAME_AND_CHECK_SIZE_BINS_BINNER3 } from '../modules/local/utils'
include { REFINE as REFINE12                                               } from '../subworkflows/local/refine'
include { REFINE as REFINE13                                               } from '../subworkflows/local/refine'
include { REFINE as REFINE23                                               } from '../subworkflows/local/refine'
include { REFINE as REFINE123                                              } from '../subworkflows/local/refine'

/*
    ~~~~~~~~~~~~~~~~~~
     Run workflow
    ~~~~~~~~~~~~~~~~~~
*/
workflow REFINEMENT {

    binner1 = tuple([id: name], binner1_files)
    binner2 = tuple([id: name], binner2_files)
    binner3 = tuple([id: name], binner3_files)

    RENAME_AND_CHECK_SIZE_BINS_BINNER1( "binner1", binner1 )
    RENAME_AND_CHECK_SIZE_BINS_BINNER2( "binner2", binner2 )
    RENAME_AND_CHECK_SIZE_BINS_BINNER3( "binner3", binner3 )

    // collect by meta
    renamed_binner1 = RENAME_AND_CHECK_SIZE_BINS_BINNER1.out.renamed
    renamed_binner2 = RENAME_AND_CHECK_SIZE_BINS_BINNER2.out.renamed
    renamed_binner3 = RENAME_AND_CHECK_SIZE_BINS_BINNER3.out.renamed

    // quality of input filtered bins
    CHECKM2_BINNER1( "binner1", renamed_binner1, ref_checkm )
    CHECKM2_BINNER2( "binner2", renamed_binner2, ref_checkm )
    CHECKM2_BINNER3( "binner3", renamed_binner3, ref_checkm )

    binners_all = renamed_binner1.join(renamed_binner2, remainder: true).join(renamed_binner3, remainder: true)
    // replace null (generated with remainder to [])
    binners = binners_all.map{ meta, b1, b2, b3 ->
                        result = [meta]
                        if (b1) { result.add(b1) } else { result.add([]) }
                        if (b2) { result.add(b2) } else { result.add([]) }
                        if (b3) { result.add(b3) } else { result.add([]) }
                        return result
    }
    refine12_input = binners.map{meta, b1, b2, b3 -> [meta, b1, b2, []]}
    refine13_input = binners.map{meta, b1, b2, b3 -> [meta, b1, b3, []]}
    refine23_input = binners.map{meta, b1, b2, b3 -> [meta, b2, b3, []]}
    REFINE12( "binner12", refine12_input, ref_checkm )
    REFINE13( "binner13", refine13_input, ref_checkm )
    REFINE23( "binner23", refine23_input, ref_checkm )
    REFINE123( "binner123", binners, ref_checkm )

    binners = CHECKM2_BINNER1.out.filtered_genomes
        .join(CHECKM2_BINNER2.out.filtered_genomes)
        .join(CHECKM2_BINNER3.out.filtered_genomes)
        .join(REFINE12.out.filtered_bins)
        .join(REFINE13.out.filtered_bins)
        .join(REFINE23.out.filtered_bins)
        .join(REFINE123.out.filtered_bins)

    stats = CHECKM2_BINNER1.out.filtered_stats
        .join(CHECKM2_BINNER2.out.filtered_stats)
        .join(CHECKM2_BINNER3.out.filtered_stats)
        .join(REFINE12.out.filtered_bins_stats)
        .join(REFINE13.out.filtered_bins_stats)
        .join(REFINE23.out.filtered_bins_stats)
        .join(REFINE123.out.filtered_bins_stats)

    CONSOLIDATE_BINS( binners, stats )

    //CHECKM_FINAL(channel.value("final"), CONSOLIDATE_BINS.out.dereplicated_bins, ref_checkm)

    CUSTOM_DUMPSOFTWAREVERSIONS(Channel.topic('versions').unique().collectFile(name: 'collated_versions.yml'))
    Channel.topic('logs').unique().collectFile(name: 'progress.log'))
}
