include { BINNING_REFINER } from '../modules/binning_refiner'
include { CHECKM2 } from '../modules/checkm2'
workflow REFINE {
    take:
        name
        binner1
        binner2
        binner3
        checkm_db
    main:
        BINNING_REFINER(name, binner1, binner2, binner3)
        CHECKM2(name, BINNING_REFINER.out.refined_bins, checkm_db)
    emit:
        refined = BINNING_REFINER.out.refined_bins
        filtered = CHECKM2.out.checkm2_results_filtered
}
