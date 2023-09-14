dx build -f saige-universal-step-0


qc_array_dir="/wes_ko_ukbb/data/saige/step0/filter_array/"
sample_dir="/wes_ko_ukbb/data/samples"
out_dir="/wes_ko_ukbb/data/saige/step0/"

for anc in eur; do
   qc_array_prefix="${qc_array_dir}/UKB"
   sample_id_path="${sample_dir}/UKB.chr21.samples.${anc}.txt"
   out_prefix="ukb_array_400k_${anc}"
   #dx build --overwrite saige-universal-step-0
   dx run saige-universal-step-0 \
      -i GENETIC_DATA_FORMAT="plink" \
      -i GENETIC_DATA_TYPE="genotype" \
      -i GENERATE_VR_PLINK="true" \
      -i GENERATE_GRM="true" \
      -i sample_ids="${sample_id_path}" \
      -i output_prefix="${out_prefix}" \
      --instance-type "mem3_ssd1_v2_x96" --priority high --destination ${out_dir} -y --name "brava-step0-${anc}"
done
