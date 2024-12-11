less 04.gtdb/classify/gtdbtk.bac120.summary.tsv |cut -f 1,2 > 06.result/taxonomy.list
less 05.abricate/resfinder_new/summary.tab |sed s'/#FILE/user_genome/'g >06.result/AMR_gene.list
perl bin/my_join.pl -b 06.result/taxonomy.list -a 06.result/AMR_gene.list > 06.result/combine_result.txt
