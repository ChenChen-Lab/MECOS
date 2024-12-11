ls /datapool/stu/yuejl/stLFR/20230905/04.gtdb/bin_contig/*.fa > 05.abricate/bin.list 
perl bin/run_abricate.pl -abricate -sl ./05.abricate/bin.list -db resfinder_new -o 05.abricate
cd 05.abricate/resfinder_new/
sh summary.sh
sed -i s'/\.fa//'g summary.tab 
