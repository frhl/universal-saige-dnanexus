dx build -f saige-universal-step-2

source "/well/lindgren-ukbb/projects/ukbb-11867/flassen/projects/KO/wes_ko_ukbb_nexus/utils/dx_utils.sh"

set -o errexit
set -o nounset

pheno_dir="/well/lindgren-ukbb/projects/ukbb-11867/flassen/projects/KO/wes_ko_ukbb_nexus/data/phenotypes"

step0_dir="/wes_ko_ukbb/data/saige/step0"
step1_dir="/wes_ko_ukbb/data/saige/step1/binary"
out_dir="/wes_ko_ukbb/data/saige/step2/binary/by_chrom"
exome_dir="/wes_ko_ukbb/data/phased/calls/encoded/spliceai50"
test_type="variant"

dx mkdir -p ${out_dir}


# since we encode autosomes and sex-chromosomes seperately
# need to grab them depending on the input chromosome
get_chr_type () {
  if [[ "${chr}" == "X" ]]; then echo "chrx"; else echo "auto"; fi
}

for anc in eur; do
   bin_phenos="${pheno_dir}/bin_matrix_eur_header.txt"
   for pheno in $(cat $bin_phenos | head -n100); do
      for anno in "pLoF_damaging_missense"; do
         for mode in "recessive"; do
            for af in "01"; do
               for pp in "0.90"; do
                  for chr in {1..22}; do
                     chr_type=$(get_chr_type ${chr}) 
                     exome_prefix="${exome_dir}/UKB.${chr_type}.${mode}.${anc}.af${af}.pp${pp}.${anno}"
                     out_prefix="UKB.${chr}.${pheno}.${mode}.${anc}.af${af}.pp${pp}.${anno}"
                     if [[ $(dx_file_exists "${out_dir}/${out_prefix}.txt.gz") -eq "0" ]]; then
                       dx run saige-universal-step-2 \
                                -i chrom="chr${chr}" \
                                -i output_prefix="${out_prefix}" \
                                -i model_file="${step1_dir}/${pheno}_${anc}.rda" \
                                -i variance_ratio="${step1_dir}/${pheno}_${anc}.varianceRatio.txt" \
                                -i test_type=$test_type \
                                -i vcf_file="${exome_prefix}.vcf.gz" \
                                -i vcf_index_file="${exome_prefix}.vcf.gz.csi" \
                                -i GRM="${step0_dir}/ukb_array_400k_eur_relatednessCutoff_0.05_5000_randomMarkersUsed.sparseGRM.mtx" \
                                -i GRM_samples="${step0_dir}/ukb_array_400k_eur_relatednessCutoff_0.05_5000_randomMarkersUsed.sparseGRM.mtx.sampleIDs.txt" \
                                --instance-type "mem3_ssd1_v2_x8" --priority low --destination "${out_dir}" -y --name "c${chr}_${pheno}_${anc}"
                     else 
                        >&2 echo "${out_prefix}.txt.gz"
                     fi
                  done
               done
            done
         done
      done
   done
done


