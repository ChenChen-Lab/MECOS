#流程目的：从单分子长片段测序（stLFR）数据中识别多重耐药菌  

##Step1: 处理原始reads数据：去接头、去宿主（人/鼠）来源的DNA  
使用软件：SOAPfilter_v2.2, bowtie2  
文件夹: 01.QC  
Input: sample.list  
Output: fq.list  

##Step2: 拼接reads数据，得到contig  
使用软件：fastq_pair, cutadapt, metaspades, bwa, samtools, athena-meta  
文件夹: 02.Assembly  
Input: 01.QC/fq.list  
Output: assembly.list  

##Step3: 将contig分bin，得到MAG，并评估质量  
使用软件：metabat2, bowtie2, samtools, checkm  
文件夹: 03.Binning  
Input: 02.Assembly/assembly.list  
Output: 03.Binning/*/metabat2/*.fa  

##Step4: 对MAG进行物种注释  
使用软件：gtdbtk-1.7.0  
文件夹: 04.gtdb  
Input: bin_contig/*.fa (由03.Binning_new/*/metabat2/*.fa 整个cp过来)  
Output: classify/gtdbtk.bac120.summary.tsv  

##Step5: 对MAG进行耐药基因注释  
使用软件：abricate  
文件夹: 05.abricate  
Input: bin.list (由04.gtdb/bin_contig/*.fa统计而来)  
Output: resfinder_new/summary.tab  

##Step6: 汇总物种和耐药基因结果，得到多耐药菌list  
使用软件：本地perl流程  
文件夹: 06.result  
Input: 04.gtdb/classify/gtdbtk.bac120.summary.tsv; 05.abricate/resfinder_new/summary.tab  
Output: combine_result.txt  

