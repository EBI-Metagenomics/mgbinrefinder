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
include { CHECKM2 as CHECKM2_BINNER1                                       } from '../modules/checkm2'
include { CHECKM2 as CHECKM2_BINNER2                                       } from '../modules/checkm2'
include { CHECKM2 as CHECKM2_BINNER3                                       } from '../modules/checkm2'
include { CHECKM2 as CHECKM_FINAL                                          } from '../modules/checkm2'
include { RENAME_AND_CHECK_SIZE_BINS as RENAME_AND_CHECK_SIZE_BINS_BINNER1 } from '../modules/utils'
include { RENAME_AND_CHECK_SIZE_BINS as RENAME_AND_CHECK_SIZE_BINS_BINNER2 } from '../modules/utils'
include { RENAME_AND_CHECK_SIZE_BINS as RENAME_AND_CHECK_SIZE_BINS_BINNER3 } from '../modules/utils'
include { REFINE as REFINE12                                               } from '../subworkflows/refine'
include { REFINE as REFINE13                                               } from '../subworkflows/refine'
include { REFINE as REFINE23                                               } from '../subworkflows/refine'
include { REFINE as REFINE123                                              } from '../subworkflows/refine'
include { CONSOLIDATE_BINS                                                 } from '../modules/consolidate_bins'
/*
    ~~~~~~~~~~~~~~~~~~
     Run workflow
    ~~~~~~~~~~~~~~~~~~
*/
workflow REFINEMENT {

    ch_versions = Channel.empty()
    empty_output = tuple([id: name], [])
    binner1 = tuple([id: name], binner1_files)
    binner2 = tuple([id: name], binner2_files)
    binner3 = tuple([id: name], binner3_files)

    RENAME_AND_CHECK_SIZE_BINS_BINNER1( "binner1", binner1 )
    RENAME_AND_CHECK_SIZE_BINS_BINNER2( "binner2", binner2 )
    RENAME_AND_CHECK_SIZE_BINS_BINNER3( "binner3", binner3 )

    // collect by meta
    renamed_binner1 = RENAME_AND_CHECK_SIZE_BINS_BINNER1.out.renamed.ifEmpty(empty_output)
    renamed_binner2 = RENAME_AND_CHECK_SIZE_BINS_BINNER2.out.renamed.ifEmpty(empty_output)
    renamed_binner3 = RENAME_AND_CHECK_SIZE_BINS_BINNER3.out.renamed.ifEmpty(empty_output)

    REFINE12( "binner12", renamed_binner1, renamed_binner2, empty_output, ref_checkm )
    REFINE13( "binner13", renamed_binner1, renamed_binner3, empty_output, ref_checkm )
    REFINE23( "binner23", renamed_binner2, renamed_binner3, empty_output, ref_checkm )
    REFINE123( "binner123", renamed_binner1, renamed_binner2, renamed_binner3, ref_checkm )

    binners = REFINE12.out.filtered_bins
        .join(REFINE13.out.filtered_bins)
        .join(REFINE23.out.filtered_bins)
        .join(REFINE123.out.filtered_bins)
    binners.view()
}