#!/bin/bash

# install gsutil
# https://cloud.google.com/sdk/docs/downloads-interactive


datadir=$(jq -r .datadir config.json)

echo $datadir
echo $(ls $datadir)

p=$(pwd)
mkdir -p ${datadir}/dl
cd ${datadir}/dl

gsutil ls gs://finngen-public-data-r5/summary_stats/ | grep -v tbi$ | grep -v manifest > dllist.txt 

while IFS= read -r line
do
nom=$(basename $line)
echo $nom
gsutil cp $line $nom
# zcat $nom | cut -f 1,2,3,4,6,7,8,9 > temp
# gzip -c temp > $nom
# rm temp
done < dllist.txt

manifest=$(gsutil ls gs://finngen-public-data-r5/summary_stats/ | grep -v tbi$ | grep manifest)
gsutil cp $manifest $(basename $manifest)
