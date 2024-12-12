# Identifying Multidrug-Resistant Bacteria through Metagenomic Co-barcode Sequencing (MECOS) Analysis  

##
  
## Step1: Processing of raw reads data: de-splice and de-host (human/mouse) -derived DNA 
Software：SOAPfilter_v2.2, bowtie2  
Directory: 01.QC  
Input: sample.list  
Output: fq.list
```{sh}
sh step1.sh  
```
## Step2: Reads data were assembled to obtain contig 
Software：fastq_pair, cutadapt, metaspades, bwa, samtools, athena-meta  
Directory: 02.Assembly  
Input: 01.QC/fq.list  
Output: assembly.list 
```{sh}
sh step2.sh
```

## Step3: Perform binning of contigs to obtain Metagenome-Assembled Genomes (MAGs) and assess their quality.  
Software：metabat2, bowtie2, samtools, checkm  
Directory: 03.Binning  
Input: 02.Assembly/assembly.list  
Output: 03.Binning/*/metabat2/*.fa  
```{sh}
sh step3.sh  
```

## Step4: Taxonomic classification on MAGs 
Software：gtdbtk-1.7.0  
Directory: 04.gtdb  
Input: bin_contig/*.fa (cp 03.Binning_new/*/metabat2/*.fa )  
Output: classify/gtdbtk.bac120.summary.tsv  
```{sh}
 sh step4.sh  
```

## Step5: Antimicrobial resistance (AMR) genes analysis on MAGs
Software：abricate  
Directory: 05.abricate  
Input: bin.list (04.gtdb/bin_contig/*.fa)  
Output: resfinder_new/summary.tab  
```{sh}
 sh step5.sh  
```

## Step6: Network analysis between bacterial taxonomy and AMR genes  
Software：perl pipeline  
Directory: 06.result  
Input: 04.gtdb/classify/gtdbtk.bac120.summary.tsv; 05.abricate/resfinder_new/summary.tab  
Output: combine_result.txt  
```{sh}
 sh step6.sh
```

## Reference  
Han K, Li J, Yang D, Zhuang Q, Zeng H, Rong C, Yue J, Li N, Gu C, Chen L, Chen C. Detecting horizontal gene transfer with metagenomics co-barcoding sequencing. Microbiol Spectr. 2024 Mar 5;12(3):e0360223. doi: 10.1128/spectrum.03602-23. Epub 2024 Feb 5. PMID: 38315121; PMCID: PMC10913427.
