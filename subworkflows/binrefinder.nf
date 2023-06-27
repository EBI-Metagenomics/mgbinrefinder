/*
    ~~~~~~~~~~~~~~~~~~
     Input validation
    ~~~~~~~~~~~~~~~~~~
*/
binner1 = channel.fromPath("${params.binner1}/*", checkIfExists: true)
binner2 = channel.fromPath("${params.binner2}/*", checkIfExists: true)
binner3 = channel.fromPath("${params.binner3}/*", checkIfExists: true)
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
include { CHECKM2 as CHECKM_1} from '../modules/checkm2'
include { CHECKM2 as CHECKM_2} from '../modules/checkm2'
include { CHECKM2 as CHECKM_3} from '../modules/checkm2'
include { CHECKM2 as CHECKM_12} from '../modules/checkm2'
include { CHECKM2 as CHECKM_13} from '../modules/checkm2'
include { CHECKM2 as CHECKM_23} from '../modules/checkm2'
include { CHECKM2 as CHECKM_123} from '../modules/checkm2'
include { RENAME_BINS as RENAME_BINNER1} from '../modules/utils'
include { RENAME_BINS as RENAME_BINNER2} from '../modules/utils'
include { RENAME_BINS as RENAME_BINNER3} from '../modules/utils'
/*
    ~~~~~~~~~~~~~~~~~~
     Run workflow
    ~~~~~~~~~~~~~~~~~~
*/
workflow REFINEMENT {
    RENAME_BINNER1(channel.value("binner1"), binner1)
    RENAME_BINNER2(channel.value("binner2"), binner2)
    RENAME_BINNER3(channel.value("binner3"), binner3)

    renamed_binner1 = RENAME_BINNER1.out.renamed.collect()
    renamed_binner2 = RENAME_BINNER2.out.renamed.collect()
    renamed_binner3 = RENAME_BINNER3.out.renamed.collect()

    CHECKM_1(channel.value("binner1"), renamed_binner1, ref_checkm)
    CHECKM_2(channel.value("binner2"), renamed_binner2, ref_checkm)
    CHECKM_3(channel.value("binner3"), renamed_binner3, ref_checkm)
    CHECKM_12(channel.value("binner12"), renamed_binner1.combine(renamed_binner2), ref_checkm)
    CHECKM_23(channel.value("binner23"), renamed_binner2.combine(renamed_binner3), ref_checkm)
    CHECKM_13(channel.value("binner13"), renamed_binner1.combine(renamed_binner3), ref_checkm)
    CHECKM_123(channel.value("binner123"), renamed_binner1.combine(renamed_binner2).combine(renamed_binner3), ref_checkm)
}
