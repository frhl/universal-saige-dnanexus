dx build -f saige-universal-step-2

test_type="group"

for anc in AFR AMR EAS SAS EUR
do

    # binary (all sex)
    phenos="pheno1 pheno2 pheno3"
    
    for pheno in $phenos
    do
        for chr in {{1..22},X}
            do
            dx run saige-universal-step-2 \
                    -i output_prefix="out/chr${chr}_${pheno}_${anc}" \
                    -i model_file="/brava/outputs/step1/${pheno}_${anc}.rda" \
                    -i variance_ratio="/brava/outputs/step1/${pheno}_${anc}.varianceRatio.txt" \
                    -i chrom="chr${chr}" \
                    -i group_file="/brava/inputs/annotations/v7/ukb_wes_450k.july.qced.brava_common_rare.v7.chr${chr}.saige.txt.gz" \
                    -i annotations="pLoF,damaging_missense_or_protein_altering,other_missense_or_protein_altering,synonymous,pLoF:damaging_missense_or_protein_altering,pLoF:damaging_missense_or_protein_altering:other_missense_or_protein_altering:synonymous" \
                    -i test_type=$test_type \
                    -i exome_bed=/Barney/wes/sample_filtered/ukb_wes_450k.qced.chr$chr.bed \
                    -i exome_bim=/Barney/wes/sample_filtered/ukb_wes_450k.qced.chr$chr.bim \
                    -i exome_fam=/Barney/wes/sample_filtered/ukb_wes_450k.qced.chr$chr.fam \
                    -i GRM="/brava/outputs/step0/brava_${anc}_relatednessCutoff_0.05_5000_randomMarkersUsed.sparseGRM.mtx" \
                    -i GRM_samples="/brava/outputs/step0/brava_${anc}_relatednessCutoff_0.05_5000_randomMarkersUsed.sparseGRM.mtx.sampleIDs.txt" \
                    --instance-type "mem3_ssd1_v2_x8" --priority low --destination /brava/outputs/step2/ -y --name "${chr}_${pheno}_${anc}"
        done
    done

    # binary (female)
    phenos="pheno4 pheno5"
    sex="F"

    for pheno in $phenos
    do
        for chr in {{1..22},X}
            do
            dx run saige-universal-step-2 \
                    -i output_prefix="out/chr${chr}_${pheno}_${anc}_${sex}" \
                    -i model_file="/brava/outputs/step1/${pheno}_${anc}_${sex}.rda" \
                    -i variance_ratio="/brava/outputs/step1/${pheno}_${anc}_${sex}.varianceRatio.txt" \
                    -i chrom="chr${chr}" \
                    -i group_file="/brava/inputs/annotations/v7/ukb_wes_450k.july.qced.brava_common_rare.v7.chr${chr}.saige.txt.gz" \
                    -i annotations="pLoF,damaging_missense_or_protein_altering,other_missense_or_protein_altering,synonymous,pLoF:damaging_missense_or_protein_altering,pLoF:damaging_missense_or_protein_altering:other_missense_or_protein_altering:synonymous" \
                    -i test_type=$test_type \
                    -i exome_bed=/Barney/wes/sample_filtered/ukb_wes_450k.qced.chr$chr.bed \
                    -i exome_bim=/Barney/wes/sample_filtered/ukb_wes_450k.qced.chr$chr.bim \
                    -i exome_fam=/Barney/wes/sample_filtered/ukb_wes_450k.qced.chr$chr.fam \
                    -i GRM="/brava/outputs/step0/brava_${anc}_relatednessCutoff_0.05_5000_randomMarkersUsed.sparseGRM.mtx" \
                    -i GRM_samples="/brava/outputs/step0/brava_${anc}_relatednessCutoff_0.05_5000_randomMarkersUsed.sparseGRM.mtx.sampleIDs.txt" \
                    --instance-type "mem3_ssd1_v2_x8" --priority low --destination /brava/outputs/step2/ -y --name "${chr}_${pheno}_${anc}_${sex}"
        done
    done

    # continuous (all sex)
    phenos="pheno7"
    
    for pheno in $phenos
    do
        for chr in {{1..22},X}
        do
            dx run saige-universal-step-2 \
                    -i output_prefix="out/chr${chr}_${pheno}_${anc}" \
                    -i model_file="/brava/outputs/step1/${pheno}_${anc}.rda" \
                    -i variance_ratio="/brava/outputs/step1/${pheno}_${anc}.varianceRatio.txt" \
                    -i chrom="chr${chr}" \
                    -i group_file="/brava/inputs/annotations/v7/ukb_wes_450k.july.qced.brava_common_rare.v7.chr${chr}.saige.txt.gz" \
                    -i annotations="pLoF,damaging_missense_or_protein_altering,other_missense_or_protein_altering,synonymous,pLoF:damaging_missense_or_protein_altering,pLoF:damaging_missense_or_protein_altering:other_missense_or_protein_altering:synonymous" \
                    -i test_type=$test_type \
                    -i exome_bed=/Barney/wes/sample_filtered/ukb_wes_450k.qced.chr$chr.bed \
                    -i exome_bim=/Barney/wes/sample_filtered/ukb_wes_450k.qced.chr$chr.bim \
                    -i exome_fam=/Barney/wes/sample_filtered/ukb_wes_450k.qced.chr$chr.fam \
                    -i GRM="/brava/outputs/step0/brava_${anc}_relatednessCutoff_0.05_5000_randomMarkersUsed.sparseGRM.mtx" \
                    -i GRM_samples="/brava/outputs/step0/brava_${anc}_relatednessCutoff_0.05_5000_randomMarkersUsed.sparseGRM.mtx.sampleIDs.txt" \
                    --instance-type "mem3_ssd1_v2_x8" --priority low --destination /brava/outputs/step2/ -y --name "${chr}_${pheno}_${anc}"
        done
    done
done
