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
        BINNING_REFINER.out.refined_bins.subscribe { println "Refinder: $name: $it.size().value" }

        CHECKM2(name, BINNING_REFINER.out.refined_bins, checkm_db)
        CHECKM2.out.checkm2_results_filtered.subscribe { println "Checkm2: $name: $it.size().value" }
    emit:
        refined = BINNING_REFINER.out.refined_bins
        filtered_bins = CHECKM2.out.checkm2_results_filtered
        filtered_bins_stats = CHECKM2.out.checkm2_results_filtered_stats
}
