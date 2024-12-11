#!/usr/bin/perl 
=head1 Description
	sequence assembly
=head1 Usage
	perl reads_assembly.pl [options]
	general input and output:
	-fl  <a file>       list of fastq from 01.QC(file suffix can be ".fq.gz"), one strain per line, PE read seperated by ",", and different by "\n"
	-type               assembly_type, default 'metaspades_athena' [metaspades and athene-meta]
	-o   <a directory>  output dir, default current directory [./02.Assembly]
	-thd <num>          thread for dsub
	-h                  show help
	-notrun             only write the shell, but not run
=head1 Example
	perl reads_assembly.pl  -fl fq.list -type  -o 

=head1 Version
        Author: guchaoyang0826@163.com
        Date: 2022-08-18
=cut

use strict;
use warnings;
use Getopt::Long;
use File::Basename;
use FindBin qw($Bin $Script);
use Cwd qw/abs_path/;

my ($fqlist,$assemblytype,$outdir,$thd,$help,$notrun);

GetOptions (
	"fl:s"=>\$fqlist,
	"type:s"=>\$assemblytype,
	"o:s"=>\$outdir,
	"h"=>\$help,
	"notrun"=>\$notrun
);
die `pod2text $0` if ($help || !$fqlist);

unless ($outdir) {
	$outdir="./02.Assembly";
}

unless (-e $outdir) {
	mkdir $outdir;
}

unless ($thd){
	$thd=8;
}

$outdir=abs_path($outdir);

#============================================================================================================================================================

if (!$fqlist){
	print "No input read files\n";
	exit;
}

if (!$assemblytype){
        print "No input read type: 'human' or 'mice' or 'none'\n";
        exit;
}

my $cutadapt="/datapool/bioinfo/guchaoyang/software/cutadapt-4.1/bin/cutadapt";
my $fastq_pair="/datapool/bioinfo/guchaoyang/software/fastq-pair-1.0/build/fastq_pair";
my $metaspades="/datapool/software/anaconda3/bin/metaspades.py";
my $bwa="/datapool/bioinfo/guchaoyang/software/bwa-0.7.17/bwa";
my $samtools="/datapool/bioinfo/guchaoyang/software/samtools-1.10/samtools";
my $athena="/datapool/software/anaconda3/envs/qiime1/bin/athena-meta";
my $seqkit="/datapool/software/anaconda3/envs/qiime2/bin/seqkit";

open (OUT, ">$outdir/assembly.sh")||die;
open (OUT1,">$outdir/pick_1k_sequence.sh")||die;
#open (OUT1, ">$outdir/athena_assembly.sh")||die;
if ($fqlist && $assemblytype eq "metaspades_athena"){
#	print OUT1 "\#\$ \-S /bin/bash\nexport PATH=\"/datapool/software/anaconda3/envs/qiime1/bin/\:\$PATH\"\n";	
	(-d "$outdir/pick_1k_sequence") || `mkdir "$outdir/pick_1k_sequence"`;
	open (IN,$fqlist)||die;
	open (LIST,">$outdir/assembly.list") || die;
	while(<IN>){
		chomp;
		my $sample=(split/\t/,$_)[0];
		my $dir="$outdir/$sample";
        	(-d $dir) || `mkdir $dir`;
		(-d "$dir/athena") || `mkdir "$dir/athena"`;
		my $sample_fq1=(split/\,/,((split/\t/,$_)[-1]))[0];
		my $sample_fq2=(split/\,/,((split/\t/,$_)[-1]))[1];
		open (Config,">$dir/athena/$sample.config") || die;
		print Config "\{\n    \"input_fqs\"\: \"$dir/$sample.interleaved.clean.fq\"\,\n    \"ctgfasta_path\"\: \"$dir/metaspades/contigs.fasta\"\,\n    \"reads_ctg_bam_path\"\: \"$dir/metaspades/align-reads.metaspades-contigs.bam\"\n\}\n";
		print LIST "$sample\t$dir/$sample.unmap.clean.1.fq.paired.fq,$dir/$sample.unmap.clean.2.fq.paired.fq\t$dir/metaspades/contigs.fasta\t$dir/athena/results/olc/athena.asm.fa\t$outdir/pick_1k_sequence/$sample.fa\n";		

		my $cmd="cd $dir\nzcat $sample_fq1 |sed \'N\;N\;N \;s\/\\n\/\\t\_\|\_\/g\'|grep -v \'0\_0\_0\' > $sample.unmap.clean.tmp.1.fq\nsort -k 2 $sample.unmap.clean.tmp.1.fq |sed \'s\/\\t\\_\|\\_\/\\n\/g\' >$sample.unmap.clean.1.fq\nzcat $sample_fq2 |sed \'N\;N\;N \;s\/\\n\/\\t\_\|\_\/g\'|grep -v \'0\_0\_0\' > $sample.unmap.clean.tmp.2.fq\nsort -k 2 $sample.unmap.clean.tmp.2.fq |sed \'s\/\\t\\_\|\\_\/\\n\/g\' >$sample.unmap.clean.2.fq\n$fastq_pair $sample.unmap.clean.1.fq $sample.unmap.clean.2.fq\n$cutadapt  -o $sample.interleaved.clean.fq  --interleaved $sample.unmap.clean.1.fq.paired.fq $sample.unmap.clean.2.fq.paired.fq\n$metaspades -t 40 -1 $sample.unmap.clean.1.fq.paired.fq -2 $sample.unmap.clean.2.fq.paired.fq  --only-assembler  -o $dir/metaspades\ncd $dir/metaspades\n$bwa  index  contigs.fasta\n$bwa  mem -t 10 -C  contigs.fasta $dir/$sample.unmap.clean.1.fq.paired.fq  $dir/$sample.unmap.clean.2.fq.paired.fq \| $samtools  sort -o align-reads.metaspades-contigs.bam \-\n$samtools index align-reads.metaspades-contigs.bam\n";
		$cmd.="\#\$ \-S /bin/bash\nexport PATH=\"/datapool/software/anaconda3/envs/qiime1/bin/\:\$PATH\"\ncd $dir/athena\n$athena --config $dir/athena/$sample.config  --threads 60 > athena.log\n$seqkit  seq -m 1000  $dir/athena/results/olc/athena.asm.fa > $outdir/pick_1k_sequence/$sample.fa\n#rm $sample.unmap.clean.tmp.1.fq\n#rm $sample.unmap.clean.1.fq\n#rm $sample.unmap.clean.tmp.2.fq\n####rm $sample.unmap.clean.2.fq\n";
 		print OUT $cmd."\n";
		my $cmd_1="$seqkit  seq -m 1000  $dir/athena/results/olc/athena.asm.fa > $outdir/pick_1k_sequence/$sample.fa";
		print OUT1 $cmd_1."\n";
	}

}

if ($fqlist && $assemblytype eq "metaspades"){
	(-d "$outdir/pick_1k_sequence") || `mkdir "$outdir/pick_1k_sequence"`;
        open (IN,$fqlist)||die;
	open (LIST,">$outdir/assembly.list") || die;
        while (<IN>){
	        chomp;
		my $sample=(split/\t/,$_)[0];
	        my $dir="$outdir/$sample";
		(-d $dir) || `mkdir $dir`;
		my $sample_fq1=(split/\,/,((split/\t/,$_)[-1]))[0];
        	my $sample_fq2=(split/\,/,((split/\t/,$_)[-1]))[1];

	       	my $cmd="cd $dir\nzcat $sample_fq1 |sed \'N\;N\;N \;s\/\\n\/\\t\_\|\_\/g\'|grep -v \'0\_0\_0\' > $sample.unmap.clean.tmp.1.fq\nsort -k 2 $sample.unmap.clean.tmp.1.fq |sed \'s\/\\t\\_\|\\_\/\\n\/g\' >$sample.unmap.clean.1.fq\nzcat $sample_fq2 |sed \'N\;N\;N \;s\/\\n\/\\t\_\|\_\/g\'|grep -v \'0\_0\_0\' > $sample.unmap.clean.tmp.2.fq\nsort -k 2 $sample.unmap.clean.tmp.2.fq |sed \'s\/\\t\\_\|\\_\/\\n\/g\' >$sample.unmap.clean.2.fq\n$fastq_pair $sample.unmap.clean.1.fq $sample.unmap.clean.2.fq\n$cutadapt  -o $sample.interleaved.clean.fq  --interleaved $sample.unmap.clean.1.fq.paired.fq $sample.unmap.clean.2.fq.paired.fq\n$metaspades  -t 40  -1 $sample.unmap.clean.1.fq.paired.fq -2 $sample.unmap.clean.2.fq.paired.fq  --only-assembler  -o $dir/metaspades\ncd $dir/metaspades\n$bwa  index  contigs.fasta\n$bwa  mem -t 10  -C  contigs.fasta $dir/$sample.unmap.clean.1.fq.paired.fq  $dir/$sample.unmap.clean.2.fq.paired.fq \| $samtools  sort -o align-reads.metaspades-contigs.bam \-\n$samtools index align-reads.metaspades-contigs.bam\n$seqkit  seq -m 1000 $dir/metaspades/contigs.fasta > $outdir/pick_1k_sequence/$sample.fa\nrm $sample.unmap.clean.tmp.1.fq\n#rm $sample.unmap.clean.1.fq\n#rm $sample.unmap.clean.tmp.2.fq\n####rm $sample.unmap.clean.2.fq\n";
		print OUT $cmd."\n";
		print LIST "$sample\t$sample.unmap.clean.1.fq.paired.fq,$sample.unmap.clean.2.fq.paired.fq\t$dir/metaspades/contigs.fasta\n";        
		my $cmd_1="$seqkit  seq -m 1000 $dir/metaspades/contigs.fasta > $outdir/pick_1k_sequence/$sample.fa";
                print OUT1 $cmd_1."\n";


	}

}


	close IN;
	close OUT;
	close OUT1;
	close Config;
	`perl $Bin/dsub_batch2.pl -thd 10 -mem 4 $outdir/assembly.sh`;

$notrun && exit;
