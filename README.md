流程目的：从单分子长片段测序（stLFR）数据中识别多重耐药菌

流程	目的	使用软件	文件夹	Input	Output
Step1	处理原始reads数据：去接头、去宿主（人/鼠）来源的DNA	SOAPfilter_v2.2
bowtie2	01.QC	../sample.list	fq.list
Step2	拼接reads数据，得到contig	fastq_pair
cutadapt
metaspades
bwa
samtools
athena-meta	02.Assembly	./01.QC/fq.list	assembly.list
Step3	将contig分bin，得到MAG，并评估质量	metabat2
bowtie2
samtools
checkm
	03.Binning_new	./02.Assembly/assembly.list	03.Binning_new/*/metabat2/*.fa
Step4	对MAG进行物种注释	gtdbtk-1.7.0	04.gtdb	bin_contig/*.fa (由03.Binning_new/*/metabat2/*.fa 整个cp过来)	classify/gtdbtk.bac120.summary.tsv
Step5	对MAG进行耐药基因注释	abricate	05.abricate	bin.list （由04.gtdb/bin_contig/*.fa统计而来）	resfinder_new/summary.tab
Step6	汇总物种和耐药基因结果，得到多耐药菌list		06.result	04.gtdb/classify/gtdbtk.bac120.summary.tsv; 05.abricate/resfinder_new/summary.tab	combine_result.txt

