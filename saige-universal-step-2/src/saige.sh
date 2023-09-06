#!/bin/bash

main() {
    
    dx-download-all-inputs --parallel

    git clone https://github.com/BRaVa-genetics/universal-saige
    mv universal-saige/* .

    bash download_resources.sh --saige-image

    mkdir out

    ls -al

    if [ -d $HOME/in/exome_bed/ ]; then
        mv $HOME/in/exome_bed/* $HOME/in/exome.bed
        mv $HOME/in/exome_bim/* $HOME/in/exome.bim
        mv $HOME/in/exome_fam/* $HOME/in/exome.fam
        
        bash 02_step2_SPAtests_variant_and_gene.sh \
            --chr $chrom \
            --testType $test_type \
            --plink "in/exome" \
            --modelFile in/model_file/* \
            --varianceRatio in/variance_ratio/* \
            --groupFile in/group_file/* \
            --annotations $annotations \
            --outputPrefix $output_prefix \
            --isSingularity false \
            --sparseGRM in/GRM/* \
            --sparseGRMID in/GRM_samples/*
    elif [ -d $HOME/in/vcf_file/ ]; then
        mv $HOME/in/vcf_file/* $HOME/in/exome.vcf.bgz
        mv $HOME/in/vcf_index_file/* $HOME/in/exome.vcf.bgz.csi

        bash 02_step2_SPAtests_variant_and_gene.sh \
            --chr $chrom \
            --testType $test_type \
            --vcf "in/exome.vcf.bgz" \
            --modelFile in/model_file/* \
            --varianceRatio in/variance_ratio/* \
            --groupFile in/group_file/* \
            --annotations $annotations \
            --outputPrefix $output_prefix \
            --isSingularity false \
            --sparseGRM in/GRM/* \
            --sparseGRMID in/GRM_samples/*
    fi

    mkdir -p ~/out/associations/
    mkdir -p ~/out/associations_variant/

    gzip "${HOME}/${output_prefix}.txt"
    gzip "${HOME}/${output_prefix}.txt.singleAssoc.txt"

    mv "${HOME}/${output_prefix}.txt.gz" "${HOME}/out/associations/"
    mv "${HOME}/${output_prefix}.txt.singleAssoc.txt.gz" "${HOME}/out/associations_variant/"

    dx-upload-all-outputs
}
