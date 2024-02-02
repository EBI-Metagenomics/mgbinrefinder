include { BINNING_REFINER                } from '../modules/binning_refiner'
include { BINNING_REFINER3               } from '../modules/binning_refiner'
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
    empty_output = binner1.map{meta, _ -> return tuple(meta, [])}

    refined = Channel.empty()
    if ( binner3 ) {
        BINNING_REFINER3( name, binner1.join( binner2 ).join( binner3 ) )
        refined = BINNING_REFINER3.out.refined_bins.ifEmpty(empty_output)

        ch_versions = ch_versions.mix( BINNING_REFINER3.out.versions.first() )
    } else {
        BINNING_REFINER( name, binner1.join( binner2 ) )
        refined = BINNING_REFINER.out.refined_bins.ifEmpty(empty_output)

        ch_versions = ch_versions.mix( BINNING_REFINER.out.versions.first() )
    }

    CHECKM2_REFINE( name, refined, checkm2_db )

    ch_versions = ch_versions.mix( CHECKM2_REFINE.out.versions.first() )

    emit:
    refined = refined
    filtered_bins = CHECKM2_REFINE.out.filtered_genomes
    filtered_bins_stats = CHECKM2_REFINE.out.filtered_stats
    versions = ch_versions
}