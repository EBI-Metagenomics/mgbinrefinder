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

/*
    ~~~~~~~~~~~~~~~~~~
     Run workflow
    ~~~~~~~~~~~~~~~~~~
*/
workflow REFINEMENT {
    CHECKM_1(channel.value("binner1"), binner1, ref_checkm)
    CHECKM_2(channel.value("binner2"), binner2, ref_checkm)
    CHECKM_3(channel.value("binner3"), binner3, ref_checkm)
    CHECKM_12(channel.value("binner12"), binner1.combine(binner2), ref_checkm)
    CHECKM_23(channel.value("binner23"), binner2.combine(binner3), ref_checkm)
    CHECKM_13(channel.value("binner13"), binner3.combine(binner1), ref_checkm)
    CHECKM_123(channel.value("binner123"), binner1.combine(binner2).combine(binner3), ref_checkm)
}
