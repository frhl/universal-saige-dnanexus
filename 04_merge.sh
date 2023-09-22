# cohort dataset
source "/well/lindgren-ukbb/projects/ukbb-11867/flassen/projects/KO/wes_ko_ukbb_nexus/utils/dx_utils.sh"

# keep track of updates to rscript
remote_dir="wes_ko_ukbb/scripts"
rscript_local="04_merge.R"
rscript_remote="${remote_dir}/04_merge.R"
dx_update_remote ${rscript_remote} ${rscript_local}

set -o errexit
set -o nounset

pheno_dir="/well/lindgren-ukbb/projects/ukbb-11867/flassen/projects/KO/wes_ko_ukbb_nexus/data/phenotypes"



gene_map="/mnt/project/genesets/220524_hgnc_ensg_enst_chr_pos.txt.gz"
in_dir="/mnt/project/wes_ko_ukbb/data/saige/step2/binary/by_chrom"
out_dir="/wes_ko_ukbb/data/saige/step2/binary"

dx mkdir -p ${out_dir}

for anc in eur; do
   bin_phenos="${pheno_dir}/bin_matrix_eur_header.txt"
   for pheno in $(cat $bin_phenos | head -n1); do
      for anno in "pLoF_damaging_missense"; do
         for mode in "recessive"; do
            for af in "01"; do
               for pp in "0.90"; do
                 chr_type=$(get_chr_type ${chr})
                 pattern="UKB.${chr}.${mode}.${anc}.af${af}.pp${pp}.${anno}"
                 out_prefix="UKB.merged.${mode}.${anc}.af${af}.pp${pp}.${anno}"
                 info="${anno}|${mode}|${af}|${pp}|${anc}"
                 dx run app-swiss-army-knife \
                  -iimage_file="/docker/rsuite.tar.gz"\
                  -icmd="
                   Rscript /mnt/project/${rscript_remote} \
                     --input_dir ${in_dir} \
                     --pattern ${pattern} \
                     --gene_map_path ${gene_map} \
                     --column_info ${column_new} \
                     --out_prefix ${out_prefix}
                 "\
                --instance-type mem1_ssd1_v2_x4 \
                --folder=".${out_dir}" \
                --priority normal \
                --name merge_saige -y               
               done
            done
         done
      done
   done
done


