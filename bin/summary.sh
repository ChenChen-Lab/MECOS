/datapool/software/anaconda3/bin/abricate --summary ./result/*.tab --nopath |grep -v 'result' > summary.tab
perl /datapool/stu/yuejl/genome-analysis-pipeline/bin/matrix_tr.pl summary.tab 75 > summary.matrix
