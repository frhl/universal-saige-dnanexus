#!/bin/bash

main() {
    
    git clone https://github.com/BRaVa-genetics/universal-saige

    mv universal-saige/* .

    bash download_resources.sh --saige-image --plink
    
    mkdir out
    mkdir in

    cd in

    if [[ $GENETIC_DATA_FORMAT == "plink" && $GENETIC_DATA_TYPE == "genotype" ]]; then
        echo "Downloading genotype data.."
        for chr in {1..22}; do
            echo "Downloading genotype chr${chr} from flassen.."
            dx download "project-GBvkP10Jg8Jpy18FPjPByv29:/wes_ko_ukbb/data/saige/step0/filter_array/UKB.chr${chr}.array.eur.isc_phased.bed"
            dx download "project-GBvkP10Jg8Jpy18FPjPByv29:/wes_ko_ukbb/data/saige/step0/filter_array/UKB.chr${chr}.array.eur.isc_phased.bim"
            dx download "project-GBvkP10Jg8Jpy18FPjPByv29:/wes_ko_ukbb/data/saige/step0/filter_array/UKB.chr${chr}.array.eur.isc_phased.fam"
        done
    else
        echo "Format data-type pair not supported"
        return 1
    fi

    echo "Downloading sample IDs"
    dx download "$sample_ids" -o sample_ids.txt
    mkdir sample_ids
    mv sample_ids.txt sample_ids/

    cd ..

    out=$output_prefix

    mkdir -p ~/out/plink_for_var_ratio_bed/
    mkdir -p ~/out/plink_for_var_ratio_bim/
    mkdir -p ~/out/plink_for_var_ratio_fam/
    mkdir -p ~/out/GRM/
    mkdir -p ~/out/GRM_samples/

    if [[ $GENERATE_VR_PLINK == "true" && $GENERATE_GRM == "false" ]]; then
        bash 00_step0_VR_and_GRM.sh \
            --geneticDataDirectory "in/" \
            --geneticDataFormat $GENETIC_DATA_FORMAT \
            --geneticDataType $GENETIC_DATA_TYPE \
            --outputPrefix $out \
            --sampleIDs ~/in/sample_ids/sample_ids.txt \
            --generate_plink_for_vr

        mv "${out}.plink_for_var_ratio.bed" ~/out/plink_for_var_ratio_bed/
        mv "${out}.plink_for_var_ratio.bim" ~/out/plink_for_var_ratio_bim/
        mv "${out}.plink_for_var_ratio.fam" ~/out/plink_for_var_ratio_fam/

    elif [[ $GENERATE_VR_PLINK == "false" && $GENERATE_GRM == "true" ]]; then
        bash 00_step0_VR_and_GRM.sh \
            --geneticDataDirectory "in/" \
            --geneticDataFormat $GENETIC_DATA_FORMAT \
            --geneticDataType $GENETIC_DATA_TYPE \
            --outputPrefix $out \
            --sampleIDs ~/in/sample_ids/* \
            --generate_GRM 

        mv "${out}_relatednessCutoff_0.05_5000_randomMarkersUsed.sparseGRM.mtx" ~/out/GRM/
        mv "${out}_relatednessCutoff_0.05_5000_randomMarkersUsed.sparseGRM.mtx.sampleIDs.txt" ~/out/GRM_samples/

    elif [[ $GENERATE_VR_PLINK == "true" && $GENERATE_GRM == "true" ]]; then
        bash 00_step0_VR_and_GRM.sh \
            --geneticDataDirectory "in/" \
            --geneticDataFormat $GENETIC_DATA_FORMAT \
            --geneticDataType $GENETIC_DATA_TYPE \
            --outputPrefix $out \
            --generate_plink_for_vr \
            --sampleIDs ~/in/sample_ids/* \
            --generate_GRM 
        
        mv "${out}_relatednessCutoff_0.05_5000_randomMarkersUsed.sparseGRM.mtx" ~/out/GRM/
        mv "${out}_relatednessCutoff_0.05_5000_randomMarkersUsed.sparseGRM.mtx.sampleIDs.txt" ~/out/GRM_samples/

        mv "${out}.plink_for_var_ratio.bed" ~/out/plink_for_var_ratio_bed/
        mv "${out}.plink_for_var_ratio.bim" ~/out/plink_for_var_ratio_bim/
        mv "${out}.plink_for_var_ratio.fam" ~/out/plink_for_var_ratio_fam/
    fi

    dx-upload-all-outputs
    return 0
}

