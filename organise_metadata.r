library(jsonlite)
library(dplyr)
library(data.table)


config <- read_json("config.json")
dir.create(file.path(config$datadir, "ready"))
dat <- fread("R5_manifest.tsv", header=TRUE, stringsAsFactors=FALSE) %>% as_tibble()
dat$filename <- basename(dat$path_bucket)
all(file.exists(file.path(config$datadir, "dl", dat$filename)))

table(duplicated(dat$phenocode))
table(duplicated(dat$name))

nom <- dat$name[duplicated(dat$name)]
subset(dat, name == nom[1]) %>% str()

index <- dat$name %in% nom

dat$name[index] <- paste0(dat$name[index], " (", dat$phenocode[index], ")")
table(duplicated(dat$name))

fn <- file.path(config$datadir, "linecounts", paste0(basename(dat$path_bucket), ".wc"))
table(file.exists(fn))

nsnp <- tibble(phenocode=fn, nsnp=sapply(fn, scan)) %>%
	mutate(phenocode=basename(phenocode) %>% gsub(".gz.wc", "", .) %>% gsub("finngen_R5_", "", .))

dat <- inner_join(dat, nsnp)

a <- tibble(
	id = paste0("finn-b-", dat$phenocode),
	sample.size = dat$n_cases + dat$n_controls,
	ncase = dat$n_cases,
	ncontrol = dat$n_controls,
	sex =  "Males and females",
	category = "Binary",
	subcategory = NA,
	unit = "logOR",
	group_name = "public",
	build = "HG19/GRCh37",
	consortium = "FinnGen",
	year = 2021,
	population = "European",
	trait = dat$name,
	note = dat$phenocode,
	pmid = NA,
	filename = dat$filename,
	nsnp = dat$nsnp,
	delimiter = "tab",
	header = TRUE,
	mr = 1,
	chr_col = 0,
	pos_col = 1,
	oa_col = 2,
	ea_col = 3,
	snp_col = 4,
	pval_col = 5,
	beta_col = 6,
	se_col = 7,
	eaf_col = 8
)

write.csv(a, file="input.csv")
write.csv(a, file=file.path(config$datadir, "ready", "input.csv"))
