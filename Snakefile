import os
import json

with open("config.json", "r") as f:
        config = json.load(f)

datadir = config['datadir']

files = os.listdir(datadir + "/dl")

os.makedirs(datadir + "/ready", exist_ok=True)
os.makedirs("job_reports", exist_ok=True)
os.makedirs(datadir + "/linecounts", exist_ok=True)

rule all:
        input:
                expand("{datadir}/ready/{files}", datadir=datadir, files=files),
                expand("{datadir}/linecounts/{files}.wc", datadir=datadir, files=files)
                "input.csv"

# Download all the files

rule dl:
        input:
                "{datadir}/dl/{files}"
        output:
                dataset="{datadir}/ready/{files}",
                wc="{datadir}/linecounts/{files}.wc"
        shell:
                "Rscript liftover.r {datadir} {wildcards.files}; zcat {input} | wc -l > {output.wc}"


rule organise_metadata:
        input:
                expand("{datadir}/linecounts/{files}.wc", datadir=datadir, files=files)
        output:
                "input.csv"
        shell:
                "Rscript organise_metadata.r"
