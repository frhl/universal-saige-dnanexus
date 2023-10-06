# cohort dataset
source "/well/lindgren-ukbb/projects/ukbb-11867/flassen/projects/KO/wes_ko_ukbb_nexus/utils/dx_utils.sh"

# keep track of updates to rscript
remote_dir="wes_ko_ukbb/scripts"
rscript_local="06_qq.R"
rscript_remote="${remote_dir}/06_qq.R"
dx_update_remote ${rscript_remote} ${rscript_local}

set -o errexit
set -o nounset

pheno_dir="/well/lindgren-ukbb/projects/ukbb-11867/flassen/projects/KO/wes_ko_ukbb_nexus/data/phenotypes"



modality="binary"
in_dir="/mnt/project/wes_ko_ukbb/data/saige/step2/${modality}"
out_dir="/wes_ko_ukbb/data/saige/step2/plots/${modality}"

dx mkdir -p ${out_dir}

group="original"
for anno in "pLoF_damaging_missense"; do
   for mode in "additive" "recessive"; do
      for af in "0.05"; do
         for pp in "0.90"; do
           input_path="${in_dir}/UKB.auto.saige_combined.${modality}.${group}.txt.gz"
           min_ac="10"
           out_prefix="UKB.auto.saige_combined.${mode}.${modality}.${group}"
           dx run app-swiss-army-knife \
            -iimage_file="/docker/rsuite.tar.gz"\
            -icmd="
             Rscript /mnt/project/${rscript_remote} \
               --out_prefix '${out_prefix}' \
               --input_path '${input_path}' \
               --min_allele2_ac '${min_ac}' \
               --mode '${mode}' \
               --annotation '${anno}' \
               --af_cutoff '${af}' \
               --pp_cutoff '${pp}' &&
               echo 'OK -   '
          "\
          --instance-type mem1_ssd1_v2_x4 \
          --folder=".${out_dir}" \
          --priority high \
          --name qq -y               
         done
      done
   done
done



