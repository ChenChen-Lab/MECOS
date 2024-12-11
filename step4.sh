cd 04.gtdbtk
ls ../03.Binning/TR*/metabat2/bin_input/*.fa|grep -v '*' >bin.fa.list
mkdir -p bin
less bin.fa.list |awk '{print "cp "$0" ./bin"}' >cp.sh
sh cp.sh
#sh gtdbtk-identify.sh &
#sh gtdbtk-align.sh &
sh gtdbtk.sh &
