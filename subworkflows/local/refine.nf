include { BINNING_REFINER                } from '../../modules/local/binning_refiner'
include { CHECKM2 as CHECKM2_REFINE      } from '../../modules/local/checkm2'

workflow REFINE {
    take:
      name
      binners
      checkm2_db

    main:

    BINNING_REFINER( name, binners )
    //CHECKM2_REFINE( name, BINNING_REFINER.out.refined_bins, checkm2_db )

    //emit:

    //filtered_bins = CHECKM2_REFINE.out.filtered_genomes
    //filtered_bins_stats = CHECKM2_REFINE.out.filtered_stats
}