# Import FinnGen R5 GWAS

https://r5.finngen.fi/

See foot for more info.

## Define data location

Create a config file called `config.json` which looks like:

```
{
  "datadir": "/path/to/data/dir"
}
```


## Download files

Get the meta-data from original authors and the file list from EBI.

```
bash dl.sh
```

## Liftover

Run the Snakemake pipeline:

```
module add languages/anaconda3/5.2.0-tflow-1.11
snakemake -prk \
-j 400 \
--cluster-config bc4-cluster.json \
--cluster "sbatch \
  --job-name={cluster.name} \
  --partition={cluster.partition} \
  --nodes={cluster.nodes} \
  --ntasks-per-node={cluster.ntask} \
  --cpus-per-task={cluster.ncpu} \
  --time={cluster.time} \
  --mem={cluster.mem} \
  --output={cluster.output}"
```

## Organise data

```
Rscript organise_metadata.r
```

Creates `/path/to/data/dir/ready/input.csv`, which defines the IDs for every file and column info etc.

```
Rscript organise_gwasdata.r
```

Updates the GWAS files to have SE etc and saves them to `/path/to/data/dir/ready/`.

## Run pipeline

At this point we have

1. All the files downloaded and formatted in `/path/to/data/dir/ready/`
2. A file called `/data/dir/ready/input.csv` which describes the data and specifies the metadata

We can now run the pipeline. Set it up:

```
module add languages/anaconda3/5.2.0-tflow-1.11
git clone --recurse-submodules git@github.com:MRCIEU/igd-hpc-pipeline.git
cd igd-hpc-pipeline/resources/gwas2vcf
python3 -m venv venv
source ./venv/bin/activate
./venv/bin/pip install -r requirements.txt
cd ../..
```



Some manual steps

```
datadir=$(jq -r .datadir ../config.json)

Rscript resources/metadata_to_json.r ${datadir}/ready/input.csv ${datadir}/ready ${datadir}/processed ${datadir}/ready/input_json.csv 8

Rscript resources/setup_directories.r ${datadir}/ready/input_json.csv 8

gwasdir="$(jq -r .datadir ../config.json)/processed"
echo `realpath ${gwasdir}` > gwasdir.txt
p=`pwd`
cd ${gwasdir}
ls --color=none -d * > ${p}/idlist.txt
cd ${p}
head idlist.txt
nid=`cat idlist.txt | wc -l`
echo "${nid} datasets"
```


Now run:

```
module add languages/anaconda3/5.2.0-tflow-1.11
snakemake -prk \
-j 400 \
--cluster-config bc4-cluster.json \
--cluster "sbatch \
  --job-name={cluster.name} \
  --partition={cluster.partition} \
  --nodes={cluster.nodes} \
  --ntasks-per-node={cluster.ntask} \
  --cpus-per-task={cluster.ncpu} \
  --time={cluster.time} \
  --mem={cluster.mem} \
  --output={cluster.output}"
```



## More info

Dear researcher,

Thanks for your interest in FinnGen data.
Below you can find the information on how to download the data.

Released FinnGen GWAS summary statistics can be downloaded from Google cloud storage free of charge.
______________________________________________________________

INSTRUCTIONS FOR WEB BROWSER-BASED ACCESS:
1) Open web browser (Google Chrome is recommended)
2) Navigate:
https://console.cloud.google.com/storage/browser/finngen-public-data-r5/summary_stats/
https://console.cloud.google.com/storage/browser/finngen-public-data-r5/finemapping/
or
https://console.cloud.google.com/storage/browser/finngen-public-data-r5/annotations/

3) Login with your google account
4) Select the files to be downloaded
5) Use ... at the right-hand side to start downloading

______________________________________________________________

INSTRUCTIONS FOR COMMAND-LINE ACCESS:
Using wget utility https://www.gnu.org/software/wget
Example:
wget https://storage.googleapis.com/finngen-public-data-r5/summary_stats/finngen_R5_AB1_ARTHROPOD.gz

Using curl utility https://curl.haxx.se/docs/
Example:
curl https://storage.googleapis.com/finngen-public-data-r5/summary_stats/finngen_R5_AB1_ARTHROPOD.gz -o finngen_R5_AB1_ARTHROPOD.gz

______________________________________________________________

INSTRUCTIONS FOR GOOGLE CLOUD-BASED ACCESS:
To install Google Cloud SDK follow directions https://cloud.google.com/sdk/install
1) List the files
gsutil ls gs://finngen-public-data-r5/summary_stats/

2) Copy the files
gsutil cp gs://finngen-public-data-r5/summary_stats/finngen_R5_AB1_ARTHROPOD.gz /path/to/your/incoming_folder/

______________________________________________________________

FURTHER INFORMATION:
The Manifest file with the link to all the downloadable summary statistics is available at: https://storage.googleapis.com/finngen-public-data-r5/summary_stats/R5_manifest.tsv

Linkage disequilibrium (LD) estimations data based on Finnish SISU panel v3 is available at:
https://console.cloud.google.com/storage/browser/finngen-public-data-ld/imputation_panel_v1/

Guidelines how to use ".bcor" LD data files is available:
https://finngen.gitbook.io/documentation/methods/genotype-imputation/ld-estimation#example-usage

More information about the data QC, PheWAS methodology can be obtained at: https://finngen.gitbook.io/documentation/

 

Explore the results at: http://r5.finngen.fi/ or http://r4.finngen.fi/

