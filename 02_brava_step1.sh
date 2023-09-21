dx build -f saige-universal-step-1


pheno_dir="/well/lindgren-ukbb/projects/ukbb-11867/flassen/projects/KO/wes_ko_ukbb_nexus/data/phenotypes"
plink_dir="/wes_ko_ukbb/data/saige/step0"
sample_dir="/wes_ko_ukbb/data/samples"
out_dir="/wes_ko_ukbb/data/saige/step1/"

for anc in eur; do

    sample_id_path="${sample_dir}/UKB.chr21.samples.${anc}.txt"
    out_prefix="ukb_array_400k_${anc}"

    # binary (all sex)
    bin_phenos="${pheno_dir}/bin_matrix_eur_header.txt"
    #bin_phenos="spiro_primary_malignancy_stomach"

    for pheno in $(cat $bin_phenos)
    do
        dx run saige-universal-step-1 \
                -i output_prefix="out/${pheno}_${anc}" \
                -i sample_ids="${sample_id_path}" \
                -i genotype_bed="${plink_dir}/ukb_array_400k_eur.plink_for_var_ratio.bed" \
                -i genotype_bim="${plink_dir}/ukb_array_400k_eur.plink_for_var_ratio.bim" \
                -i genotype_fam="${plink_dir}/ukb_array_400k_eur.plink_for_var_ratio.fam" \
                -i pheno_list=/wes_ko_ukbb/data/phenotypes/bin_matrix_eur.txt \
                -i pheno="$pheno" \
                -i GRM="${plink_dir}/ukb_array_400k_eur_relatednessCutoff_0.05_5000_randomMarkersUsed.sparseGRM.mtx" \
                -i GRM_samples="${plink_dir}/ukb_array_400k_eur_relatednessCutoff_0.05_5000_randomMarkersUsed.sparseGRM.mtx.sampleIDs.txt" \
                -i covariates="age,age2,age_sex,age2_sex,sex,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10" \
                -i categorical_covariates="sex" \
                -i trait_type="binary" \
                --instance-type "mem3_ssd1_v2_x4" --priority low --destination ".${out_dir}" -y --name "step1_${pheno}_${anc}"
    done

  #  # binary (female)
  #  phenos="pheno4 pheno5"
  #  sex="F"

   # for pheno in $phenos
   # do
   #     dx run saige-universal-step-1 \
   #             -i output_prefix="out/${pheno}_${anc}_${sex}" \
   #             -i sample_ids="/brava/inputs/ancestry_sample_ids/qced_${anc}_sample_IDs_${sex}.txt" \
   #             -i genotype_bed="/brava/outputs/step0/brava_${anc}.plink_for_var_ratio.bed" \
   #             -i genotype_bim="/brava/outputs/step0/brava_${anc}.plink_for_var_ratio.bim" \
    #            -i genotype_fam="/brava/outputs/step0/brava_${anc}.plink_for_var_ratio.fam" \
    #            -i pheno_list=/brava/inputs/phenotypes/brava_with_covariates.tsv \
    #            -i pheno="$pheno" \
    #            -i GRM="/brava/outputs/step0/brava_${anc}_relatednessCutoff_0.05_5000_randomMarkersUsed.sparseGRM.mtx" \
    #            -i GRM_samples="/brava/outputs/step0/brava_${anc}_relatednessCutoff_0.05_5000_randomMarkersUsed.sparseGRM.mtx.sampleIDs.txt" \
    #            -i covariates="age,age2,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10" \
    #            -i categorical_covariates="" \
    #            -i trait_type="binary" \
    #            --instance-type "mem3_ssd1_v2_x4" --priority low --destination /brava/outputs/step1/ -y --name "step1_${pheno}_${anc}_${sex}"
    #done
    #
    # continuous (all sex)
    #phenos="pheno6"
    #
    #for pheno in $phenos
    #do
    #    dx run saige-universal-step-1 \
    #            -i output_prefix="out/${pheno}_${anc}" \
    #            -i sample_ids="/brava/inputs/ancestry_sample_ids/qced_${anc}_sample_IDs.txt" \
    #            -i genotype_bed="/brava/outputs/step0/brava_${anc}.plink_for_var_ratio.bed" \
    #            -i genotype_bim="/brava/outputs/step0/brava_${anc}.plink_for_var_ratio.bim" \
    #            -i genotype_fam="/brava/outputs/step0/brava_${anc}.plink_for_var_ratio.fam" \
    #            -i pheno_list=/brava/inputs/phenotypes/brava_with_covariates.tsv \
    #            -i pheno="$pheno" \
    #            -i GRM="/brava/outputs/step0/brava_${anc}_relatednessCutoff_0.05_5000_randomMarkersUsed.sparseGRM.mtx" \
    #            -i GRM_samples="/brava/outputs/step0/brava_${anc}_relatednessCutoff_0.05_5000_randomMarkersUsed.sparseGRM.mtx.sampleIDs.txt" \
    #            -i covariates="age,age2,age_sex,age2_sex,sex,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10" \
    #            -i categorical_covariates="sex" \
    #            -i trait_type="quantitative" \
    #            --instance-type "mem3_ssd1_v2_x4" --priority low --destination /brava/outputs/step1/ -y --name "step1_${pheno}_${anc}"
    #done
done
