include { BINNING_REFINER                } from '../modules/binning_refiner'
include { CHECKM2 as CHECKM2_REFINE      } from '../modules/checkm2'

workflow REFINE {
    take:
    name
    binner1
    binner2
    binner3
    checkm2_db

    main:

    ch_versions = Channel.empty()

    BINNING_REFINER( name, binner1, binner2, binner3 )
    refined = BINNING_REFINER.out.refined_bins
    ch_versions = ch_versions.mix( BINNING_REFINER.out.versions.first() )

    CHECKM2_REFINE( name, refined, checkm2_db )
    //ch_versions = ch_versions.mix( CHECKM2_REFINE.out.versions.first() )

    emit:
    refined = refined
    filtered_bins = CHECKM2_REFINE.out.filtered_genomes
    filtered_bins_stats = CHECKM2_REFINE.out.filtered_stats
    versions = ch_versions
}