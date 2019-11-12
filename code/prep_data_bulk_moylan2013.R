############### SYNOPSIS ###################
# Download and prepare Moylan 2013 bulk liver dataset

### OUTPUT:
# ....

### REMARKS:
# ....

### REFERENCE:
# GEO accession display https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE31803
#
# Murphy SK, Yang H, Moylan CA, Pang H et al. Relationship between methylome and transcriptome
# in patients with nonalcoholic fatty liver disease. Gastroenterology 2013 Nov;145(5):1076-87.
# PMID: 23916847 https://www.ncbi.nlm.nih.gov/pubmed/23916847
#
# Moylan CA, Pang H, Dellinger A, Suzuki A et al. Hepatic gene expression profiles differentiate
# presymptomatic patients with mild versus severe nonalcoholic fatty liver disease.
# Hepatology 2014 Feb;59(2):471-82. PMID: 23913408
# https://www.ncbi.nlm.nih.gov/pubmed/23913408

# GEO query package
# https://bioconductor.org/packages/release/bioc/vignettes/GEOquery/inst/doc/GEOquery.html


# Thermofisher Affymetrix Human Genome U133 Plus 2.0 Array documentation
# https://www.thermofisher.com/order/catalog/product/900470?SID=srch-srp-900470#/900470?SID=srch-srp-900470

# ======================================================================= #
# ================================ SETUP ================================ #
# ======================================================================= #

library("here")
library("data.table")
#library("tidyverse")
library("magrittr")
library("GEOquery")

# ======================================================================= #
# ========================== Download ================================ #
# ======================================================================= #
### You only need to run this step once


# Illumina HumanMethylation450 BeadChip (HumanMethylation450_15017482)
# path_download_GPL13534 <- here("data", "GSE31803-GPL13534_series_matrix.txt.gz")
#
# if (!file.exists(path_download_GPL13534)) {
#   # Download data
#   downloadURL <-  "ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE31nnn/GSE31803/matrix/GSE31803-GPL13534_series_matrix.txt.gz"
#   download.file(downloadURL, destfile=path_download_GPL13534)
# }

# [HG-U133_Plus_2] Affymetrix Human Genome U133 Plus 2.0 Array
path_download_GPL570 <- here("data", "GSE31803-GPL570_series_matrix.txt.gz")

if (!file.exists(path_download_GPL570)) {
  # Download data
  downloadURL <-  "ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE31nnn/GSE31803/matrix/GSE31803-GPL570_series_matrix.txt.gz"
  download.file(downloadURL, destfile=path_download_GPL570)
}

# Supplementary file
# path_download_GSE31803_raw <-  here("data","GSE31803_RAW.tar")
#
# if (!file.exists(path_download_GSE31803_raw)) {
#   # Download data
#   downloadURL <-  "ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE31nnn/GSE31803/suppl/GSE31803_RAW.tar"
#   download.file(downloadURL, destfile=path_download_GSE31803_raw)
#   system2(command = "tar",args = c("-xvf", path_download_GSE31803_raw))
# }

# ======================================================================= #
# ========================== Load into memory =========================== #
# ======================================================================= #

# ?getGEO
#  If the filename argument is used in combination with a GSEMatrix file, then the return value is a single ExpressionSet.

GPL570 <- getGEO(filename=path_download_GPL570)

# extract normalized expression data from ExpressionSet object
mat_datExpr <- GPL570@assayData$exprs
mat_datExpr[1000:1004,0:4]

# add feature names (genes) to expression matrix
all.equal(GPL570@featureData@data$ID, rownames(mat_datExpr))
# [1] TRUE


vec_entrez_gene_id <- GPL570@featureData@data[["ENTREZ_GENE_ID"]]
vec_gene_symbol <- GPL570@featureData@data[["Gene Symbol"]]

dt_mapping <- fread("/projects/jonatan/tools/data/gene_annotation_hsapiens.txt.gz")

table(vec_entrez_gene_id %in% dt_mapping[,entrezgene])
# FALSE  TRUE
# 15067 39608
table(vec_gene_symbol %in% dt_mapping[,hgnc_symbol])
# FALSE  TRUE
# 7403 47272
table(duplicated(vec_gene_symbol))
# FALSE  TRUE
# 23521 31154
table(duplicated(vec_entrez_gene_id))
# FALSE  TRUE
# 21880 32795
table(duplicated(vec_gene_symbol)&duplicated(vec_entrez_gene_id))
# FALSE  TRUE
# 23524 31151
table(duplicated(GPL570@featureData@data$ID))

# Thermofisher Affymetrix Human Genome U133 Plus 2.0 Array documentation:
#The primary goal in probe set selection is to select a probe set unique to a single transcript or common among a small set
# of similar transcript variants.
# A probe set name is appended with the "_s_at" extension when all the probes exactly match multiple transcripts.
# The probe set selection process generally favors probe sets measuring fewer transcripts.
# Probe sets with common probes among multiple transcripts (the "_s_at" probe sets), are frequent and are to be expected,
# due to alternative polyadenylation and alternative splicing. In most cases, "_s_at" probe sets represent transcripts from the same gene,
# but the same probe set can sometimes also represent transcripts from homologous genes. One transcript may be represented by both a unique
# and an "_s_at" probe set when the transcript variation is sufficient.

# massive duplication.
# use the gene symbols
cbind(vec_gene_symbol, mat_datExpr) %>% as.data.table -> dt_datExpr
colnames(dt_datExpr)[1] <- "gene"

# convert dt to numeric
strTmp <- colnames(dt_datExpr[,-"gene"])
dt_datExpr[, (strTmp) := lapply(.SD, as.numeric), .SDcols = strTmp]

# Take the mean of duplicates
dt_datExpr_mean <- dt_datExpr[, lapply(.SD, mean),by=gene,]

# clear up gene symbol names (annotations sometimes for two gene names, we keep the first)
dt_datExpr_mean[,gene:=gsub("\\ ","", gene)]
dt_datExpr_mean[,gene:=gsub("///.+","", gene)]
dt_datExpr_mean[,gene:=gsub("\\W","-",gene)]

dt_datExpr_mean[, gene] %>% head(.,50)

# extract metadata
pData(GPL570)[c("geo_accession","Stage:ch1")] %>% setDT -> dt_metadata

colnames(dt_metadata) <- gsub("\\W","_",colnames(dt_metadata))
dt_metadata[,fibrosis:= ifelse(grepl("advanced", Stage_ch1), "advanced", "mild")]
dt_metadata <- dt_metadata[,-"Stage_ch1"]

# ======================================================================= #
# ================================ EXPORT TO CSV ============================= #
# ======================================================================= #

file.out.data <- here("data","moylan2013.norm.expr.csv")
data.table::fwrite(dt_datExpr_mean , file=file.out.data,  # fwrite cannot write gziped files
                   nThread=24, verbose=T) # write file ---> write to scratch
R.utils::gzip(file.out.data, overwrite=TRUE) # gzip

### Write cell meta-data
file.out.meta <- here("data","moylan2013.metadata.csv")
data.table::fwrite(dt_metadata, file=file.out.meta,  # fwrite cannot write gziped files
                   nThread=24, verbose=T) # write file ---> write to scratch
