dx build -f saige-universal-step-2

source "/well/lindgren-ukbb/projects/ukbb-11867/flassen/projects/KO/wes_ko_ukbb_nexus/utils/dx_utils.sh"

set -o errexit
set -o nounset

pheno_dir="/well/lindgren-ukbb/projects/ukbb-11867/flassen/projects/KO/wes_ko_ukbb_nexus/data/phenotypes"
step0_dir="/wes_ko_ukbb/data/saige/step0"
step1_dir="/wes_ko_ukbb/data/saige/step1/binary"
test_type="variant"


for splice_suffix in "50.am"; do
  out_dir="/wes_ko_ukbb/data/saige/step2/binary/spliceai${splice_suffix}"
  exome_dir="/wes_ko_ukbb/data/phased/calls/encoded/spliceai${splice_suffix}"
  dx mkdir -p ${out_dir}
  for anc in eur; do
     bin_phenos="${pheno_dir}/bin_matrix_eur_header.txt"
     for pheno in $(cat $bin_phenos | head -n320); do
        for anno in "pLoF_damaging_missense"; do
           for mode in "recessive" "additive"; do
              for af in "01"; do
                 for pp in "0.90"; do
                     exome_prefix="${exome_dir}/UKB.auto.${mode}.${anc}.af${af}.pp${pp}.${anno}"
                     out_prefix="UKB.auto.${pheno}.${mode}.${anc}.af${af}.pp${pp}.${anno}"
                     if [[ $(dx_file_exists "${out_dir}/${out_prefix}.txt.gz") -eq "0" ]]; then
                       dx run saige-universal-step-2 \
                                -i chrom="1" \
                                -i output_prefix="${out_prefix}" \
                                -i model_file="${step1_dir}/${pheno}_${anc}.rda" \
                                -i variance_ratio="${step1_dir}/${pheno}_${anc}.varianceRatio.txt" \
                                -i test_type=$test_type \
                                -i exome_bed="${exome_prefix}.bed" \
                                -i exome_bim="${exome_prefix}.bim" \
                                -i exome_fam="${exome_prefix}.fam" \
                                -i GRM="${step0_dir}/ukb_array_400k_eur_relatednessCutoff_0.05_5000_randomMarkersUsed.sparseGRM.mtx" \
                                -i GRM_samples="${step0_dir}/ukb_array_400k_eur_relatednessCutoff_0.05_5000_randomMarkersUsed.sparseGRM.mtx.sampleIDs.txt" \
                                --instance-type "mem3_ssd1_v2_x8" --priority normal --destination "${out_dir}" -y --name "plink_${pheno}_${anc}"
                     else 
                        >&2 echo "${out_prefix}.txt.gz already exists. Skipping.."
                     fi
                 done
              done
           done
        done
     done
  done
done

