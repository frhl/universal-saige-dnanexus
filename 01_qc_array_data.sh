# author: Frederik Lassen

set -eu

# static
array_dir="/Phasing/PhasingWES/step0_merge/support"
mnt_array_dir="/mnt/project${array_dir}"
samples_dir="/mnt/project/wes_ko_ukbb/data/samples"
samples="${samples_dir}/UKB.chr21.samples.eur.txt"
out_dir="/wes_ko_ukbb/data/saige/step0/filter_array"

instance_type="mem2_ssd1_v2_x16"
missing="0.10"
threads="16"
priority="normal"

for CHR in {1..22}; do
    array_prefix="${mnt_array_dir}/UKB.chr${CHR}.qc.array"
    out_prefix=UKB.chr${CHR}.array.eur.isc_phased
    out_expt="${out_dir}/${out_prefix}.bed"
    if [[ "$(dx ls ${out_expt} | wc -l)" -eq "0" ]]; then
      dx run app-swiss-army-knife -icmd="
        plink2 --threads ${threads} --bfile ${array_prefix} --keep ${samples} --geno ${missing} --hwe 1e-50 --make-bed --out ${out_prefix} &&
        rm ${out_prefix}.log
      " \
      --instance-type ${instance_type} \
      --folder=".${out_dir}" \
      --name array_filter_chr${CHR} \
      --priority ${priority} -y
   else
     >&2 echo "${out_expt} already exists! Skipping."
   fi

done

