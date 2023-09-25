# cohort dataset
source "/well/lindgren-ukbb/projects/ukbb-11867/flassen/projects/KO/wes_ko_ukbb_nexus/utils/dx_utils.sh"

# keep track of updates to rscript
remote_dir="wes_ko_ukbb/scripts"
rscript_local="05_qq.R"
rscript_remote="${remote_dir}/04_qq.R"
dx_update_remote ${rscript_remote} ${rscript_local}

set -o errexit
set -o nounset

pheno_dir="/well/lindgren-ukbb/projects/ukbb-11867/flassen/projects/KO/wes_ko_ukbb_nexus/data/phenotypes"



in_dir="/mnt/project/wes_ko_ukbb/data/saige/step2/binary"
out_dir="/wes_ko_ukbb/data/saige/step2/plots"

dx mkdir -p ${out_dir}

for anc in eur; do
   bin_phenos="${pheno_dir}/bin_matrix_eur_header.txt"
   for pheno in $(cat $bin_phenos | head -n1); do
      for anno in "pLoF_damaging_missense"; do
         for mode in "recessive"; do
            for af in "01"; do
               for pp in "0.90"; do
                 #out_prefix="UKB.merged.${mode}.${anc}.af${af}.pp${pp}.${anno}"
                 regex_annotation=${anno}
                 regex_mode="${mode}"
                 regex_af_cutoff="af${af}"
                 regex_pp_cutoff="pp${pp}"
                 min_ac="10"
                 out_prefix="test"
                 dx run app-swiss-army-knife \
                  -iimage_file="/docker/rsuite.tar.gz"\
                  -icmd="
                   Rscript /mnt/project/${rscript_remote} \
                     --out_prefix '${out_prefix}' \
                     --input_dir '${in_dir}' \
                     --min_allele2_ac '${min_ac}' \
                     --regex_mode '${regex_mode}' \
                     --regex_annotation '${regex_annotation}' \
                     --regex_af_cutoff '${regex_af_cutoff}' \
                     --regex_pp_cutoff '${regex_pp_cutoff}' &&
                     echo 'OK - done'
                "\
                --instance-type mem1_ssd1_v2_x4 \
                --folder=".${out_dir}" \
                --priority high \
                --name qq -y               
               done
            done
         done
      done
   done
done



