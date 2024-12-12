# Identifying Multidrug-Resistant Bacteria through Metagenomic Co-barcode Sequencing (MECOS) Analysis
  
## Step1: Processing of raw reads data: de-splice and de-host (human/mouse) -derived DNA 
Software：SOAPfilter_v2.2, bowtie2  
Directory: 01.QC  
Input: sample.list  
Output: fq.list  

## Step2: Reads data were assembled to obtain contig 
Software：fastq_pair, cutadapt, metaspades, bwa, samtools, athena-meta  
Directory: 02.Assembly  
Input: 01.QC/fq.list  
Output: assembly.list  

## Step3: Perform binning of contigs to obtain Metagenome-Assembled Genomes (MAGs) and assess their quality.  
Software：metabat2, bowtie2, samtools, checkm  
Directory: 03.Binning  
Input: 02.Assembly/assembly.list  
Output: 03.Binning/*/metabat2/*.fa  

## Step4: Taxonomic classification on MAGs 
Software：gtdbtk-1.7.0  
Directory: 04.gtdb  
Input: bin_contig/*.fa (由03.Binning_new/*/metabat2/*.fa 整个cp过来)  
Output: classify/gtdbtk.bac120.summary.tsv  

## Step5: Antimicrobial resistance (AMR) genes analysis on MAGs
Software：abricate  
Directory: 05.abricate  
Input: bin.list (由04.gtdb/bin_contig/*.fa统计而来)  
Output: resfinder_new/summary.tab  

## Step6: Network analysis between bacterial taxonomy and AMR genes  
Software：perl pipeline  
Directory: 06.result  
Input: 04.gtdb/classify/gtdbtk.bac120.summary.tsv; 05.abricate/resfinder_new/summary.tab  
Output: combine_result.txt  

