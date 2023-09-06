dx build -f saige-universal-step-0

for anc in EUR AFR SAS EAS AMR
do
    dx run saige-universal-step-0 \
            -i GENETIC_DATA_FORMAT="plink" \
            -i GENETIC_DATA_TYPE="genotype" \
            -i GENERATE_VR_PLINK="true" \
            -i GENERATE_GRM="true" \
            -i sample_ids="/brava/inputs/ancestry_sample_ids/${anc}_sample_IDs.txt" \
            -i output_prefix="brava_${anc}" \
            --instance-type "mem3_ssd1_v2_x96" --priority high --destination /brava/outputs/step0/ -y --name "brava-step0-${anc}"
done