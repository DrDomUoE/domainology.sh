#!/bin/sh
#PBS -V # export all environment variables to the batch job.
#PBS -d . # set working directory to .
#PBS -q pq # submit to the parallel queue
#PBS -l nodes=16 # nodes=number of nodes required. ppn=number of processors per node
#PBS -l walltime=168:00:00 # Maximum wall time for the job.
#PBS -A Research_Project-172722 # research project to submit under.
#PBS -m e -M d.wiredu-boakye@exeter.ac.uk # email me at job completion
#this script calculates fraction of protein sizes occupied by functional domains. it takes an hmmrscan parsed output as an input
#written by Dominic Wiredu Boakye
for filename in ./*.parsed
do
awk '{print $1,$3,$4,$8,$9}' "$filename" > "$filename".tight #extract column 1,3,4,8 and 9
done
for filename in ./*.tight
do
awk 'NR >= 1 { $6 = $5 - $4 } 1' "$filename" > "$filename".sub #subtract column 4 from 5 and insert answer in column 6
awk '{print >> $2; close($2)}' "$filename".sub #split file according to column 2
done
for filename in ./*_
do
sed 's/$/ 1/' < "$filename" > "$filename".domain_count
awk '!seen[$0]++' "$filename".domain_count | awk 'BEGIN {FS="[ ]"} {sum += $7} END {print sum}'> "$filename".split.domain_count #getting domain count
awk '{print FILENAME,$1}' "$filename".split.domain_count | sed s'#.split.domain_count # \/ #' | sed s'#^\.\/#s\/ #' | sed s'#$# \/#' > "$filename".split.domain_count_filename #attaching protein name to the 1st column and turning file to sed script
done
cat *.split.domain_count_filename > sed_file.txt
sed -f sed_file.txt < footprint_file_proteinID.txt > dominology_count_file
