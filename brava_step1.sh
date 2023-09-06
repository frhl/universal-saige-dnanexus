dx build -f saige-universal-step-1

for anc in AFR SAS EAS AMR EUR
do

    # binary (all sex)
    phenos="pheno1 pheno2 pheno3"

    for pheno in $phenos
    do
        dx run saige-universal-step-1 \
                -i output_prefix="out/${pheno}_${anc}" \
                -i sample_ids="/brava/inputs/ancestry_sample_ids/qced_${anc}_sample_IDs.txt" \
                -i genotype_bed="/brava/outputs/step0/brava_${anc}.plink_for_var_ratio.bed" \
                -i genotype_bim="/brava/outputs/step0/brava_${anc}.plink_for_var_ratio.bim" \
                -i genotype_fam="/brava/outputs/step0/brava_${anc}.plink_for_var_ratio.fam" \
                -i pheno_list=/brava/inputs/phenotypes/brava_with_covariates.tsv \
                -i pheno="$pheno" \
                -i GRM="/brava/outputs/step0/brava_${anc}_relatednessCutoff_0.05_5000_randomMarkersUsed.sparseGRM.mtx" \
                -i GRM_samples="/brava/outputs/step0/brava_${anc}_relatednessCutoff_0.05_5000_randomMarkersUsed.sparseGRM.mtx.sampleIDs.txt" \
                -i covariates="age,age2,age_sex,age2_sex,sex,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10" \
                -i categorical_covariates="sex" \
                -i trait_type="binary" \
                --instance-type "mem3_ssd1_v2_x4" --priority low --destination /brava/outputs/step1/ -y --name "step1_${pheno}_${anc}"
    done

    # binary (female)
    phenos="pheno4 pheno5"
    sex="F"

    for pheno in $phenos
    do
        dx run saige-universal-step-1 \
                -i output_prefix="out/${pheno}_${anc}_${sex}" \
                -i sample_ids="/brava/inputs/ancestry_sample_ids/qced_${anc}_sample_IDs_${sex}.txt" \
                -i genotype_bed="/brava/outputs/step0/brava_${anc}.plink_for_var_ratio.bed" \
                -i genotype_bim="/brava/outputs/step0/brava_${anc}.plink_for_var_ratio.bim" \
                -i genotype_fam="/brava/outputs/step0/brava_${anc}.plink_for_var_ratio.fam" \
                -i pheno_list=/brava/inputs/phenotypes/brava_with_covariates.tsv \
                -i pheno="$pheno" \
                -i GRM="/brava/outputs/step0/brava_${anc}_relatednessCutoff_0.05_5000_randomMarkersUsed.sparseGRM.mtx" \
                -i GRM_samples="/brava/outputs/step0/brava_${anc}_relatednessCutoff_0.05_5000_randomMarkersUsed.sparseGRM.mtx.sampleIDs.txt" \
                -i covariates="age,age2,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10" \
                -i categorical_covariates="" \
                -i trait_type="binary" \
                --instance-type "mem3_ssd1_v2_x4" --priority low --destination /brava/outputs/step1/ -y --name "step1_${pheno}_${anc}_${sex}"
    done

    # continuous (all sex)
    phenos="pheno6"

    for pheno in $phenos
    do
        dx run saige-universal-step-1 \
                -i output_prefix="out/${pheno}_${anc}" \
                -i sample_ids="/brava/inputs/ancestry_sample_ids/qced_${anc}_sample_IDs.txt" \
                -i genotype_bed="/brava/outputs/step0/brava_${anc}.plink_for_var_ratio.bed" \
                -i genotype_bim="/brava/outputs/step0/brava_${anc}.plink_for_var_ratio.bim" \
                -i genotype_fam="/brava/outputs/step0/brava_${anc}.plink_for_var_ratio.fam" \
                -i pheno_list=/brava/inputs/phenotypes/brava_with_covariates.tsv \
                -i pheno="$pheno" \
                -i GRM="/brava/outputs/step0/brava_${anc}_relatednessCutoff_0.05_5000_randomMarkersUsed.sparseGRM.mtx" \
                -i GRM_samples="/brava/outputs/step0/brava_${anc}_relatednessCutoff_0.05_5000_randomMarkersUsed.sparseGRM.mtx.sampleIDs.txt" \
                -i covariates="age,age2,age_sex,age2_sex,sex,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10" \
                -i categorical_covariates="sex" \
                -i trait_type="quantitative" \
                --instance-type "mem3_ssd1_v2_x4" --priority low --destination /brava/outputs/step1/ -y --name "step1_${pheno}_${anc}"
    done
done
