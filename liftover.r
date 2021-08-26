library(GwasDataImport)
library(data.table)

args <- commandArgs(T)
datadir <- args[1]
fn <- args[2]

a <- fread(file.path(datadir, "dl", fn))
a <- subset(a, select=c("#chrom", "pos", "ref", "alt", "rsids", "pval", "beta", "sebeta", "maf"))
a <- liftover_gwas(a, "38", "37", "#chrom", "pos", "rsids", "alt", "ref")
fwrite(a, file=file.path(datadir, "ready", fn), quote=FALSE, sep="\t")
