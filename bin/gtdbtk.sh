date>fin.log
source activate qiime2
export GTDBTK_DATA_PATH=/datapool/software/anaconda3/envs/qiime2/share/gtdbtk-1.7.0/db/release202/
/datapool/software/anaconda3/envs/qiime2/bin/gtdbtk  classify_wf --genome_dir bin --out_dir ./new_gtdb --extension fa --cpus 30
date>>fin.log
