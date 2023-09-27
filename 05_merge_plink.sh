# cohort dataset
source "/well/lindgren-ukbb/projects/ukbb-11867/flassen/projects/KO/wes_ko_ukbb_nexus/utils/dx_utils.sh"

# keep track of updates to rscript
remote_dir="wes_ko_ukbb/scripts"
rscript_local="05_merge_plink.R"
rscript_remote="${remote_dir}/05_merge_plink.R"
dx_update_remote ${rscript_remote} ${rscript_local}

set -o errexit
set -o nounset

gene_map="/mnt/project/genesets/220524_hgnc_ensg_enst_chr_pos.txt.gz"
out_dir="/wes_ko_ukbb/data/saige/step2/binary"

dx mkdir -p ${out_dir}

for splice_suffix in "50.am"; do
  in_dir="/mnt/project/wes_ko_ukbb/data/saige/step2/binary/spliceai${splice_suffix}"
  input_pattern="UKB.*.txt.gz"
  out_prefix="UKB.auto.saige_combined.spliceai${splice_suffix}"
  dx run app-swiss-army-knife \
    -iimage_file="/docker/rsuite.tar.gz"\
    -icmd="
     Rscript /mnt/project/${rscript_remote} \
       --out_prefix '${out_prefix}' \
       --input_dir '${in_dir}' \
       --pattern '${input_pattern}' \
       --gene_map_path '${gene_map}' &&
       echo 'ok'
    "\
  --instance-type mem1_ssd1_v2_x4 \
  --folder=".${out_dir}" \
  --priority high \
  --name merge_plink -y               
done


