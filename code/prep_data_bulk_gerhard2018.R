############### SYNOPSIS ###################
# Download and prepare Gerhard 2018 bulk liver dataset

### OUTPUT:
# ....

### REMARKS:
#' @note
# Johanna DiStefano:
# "It appears that samples DLDR_0037-46 and DLDR_61-62 are listed as normal, but are actually fibrotic (F4) samples.
# Please keep this in mind when you are analyzing the data."

### REFERENCE:
#
# Gerhard,...,DiStefano,2018, J Endocrine Soc, Transcriptomic Profiling of Obesity-Related
# Nonalcoholic Steatohepatitis Reveals a Core Set of Fibrosis-Specific Genes
# https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6018672/
#
# Leti,...DiStefano,2015, Trans. Res. High-throughput sequencing reveals altered expression of
# hepatic miRNAs in non-alcoholic fatty liver disease-related fibrosis
# https://www.sciencedirect.com/science/article/pii/S1931524415001401?via%3Dihub
#
# DiStefano,...,Gerhard, 2015, Acta Diabetol., Genome-wide analysis of hepatic lipid content
# in extreme obesity
# https://link.springer.com/article/10.1007%2Fs00592-014-0654-3
#
# Garhard,...,DiStefano, 2014, J. Obes., Identification of Novel Clinical Factors Associated with
# Hepatic Fat Accumulation in Extreme Obesity
# https://www.hindawi.com/journals/jobe/2014/368210/
#
# NCBI SRA Raw sequence: https://www.ncbi.nlm.nih.gov/bioproject/512027
#
# NCBI download page: https://www.ncbi.nlm.nih.gov/home/download/
# NCBI SRA handbook: https://www.ncbi.nlm.nih.gov/books/NBK47528/
#
# metadata: via email from Johanna DiStefano
#
# ======================================================================= #
# ================================ SETUP ================================ #
# ======================================================================= #

library("here")
library("data.table")
#library("tidyverse")
library("magrittr")
#library("SRAdb")
library("openxlsx")
library("rentrez")
# ======================================================================= #
# ========================== Download ================================ #
# ======================================================================= #
### You only need to run this step once


# 1 SRAdb
# timeStart <- proc.time()
# sqlfile <- getSRAdbFile()
# proc.time() - timeStart
#
# sra_con <- dbConnect(SQLite(),sqlfile)

# 2 using prefetch

# dir_download_data <- "/data/pub-others/gerhard-j_endocrine_soc-2018/"
#
# if (!length(dir(path_download_data))) {
#
#   system2(command = "prefetch", args = c(paste0("-O ", dir_download_data)),"SRS4194802")
#
# }

# 3 using rentrez


#path_download_data <- here("data", "")

# if (!file.exists(path_download_data)) {
#   # Download data
#   #downloadURL <-  ""
#   #system2(command = "prefetch", args = "PRJNA512027")
#   #download.file(downloadURL, destfile=path_download_data)
#   # getSRAfile(in_acc="PRJNA512027",
#   #            sra_con,
#   #            destDir = here("data"),
#   #            fileType = 'sra',
#   #            srcType = 'ftp',
#   #            makeDirectory = FALSE,
#   #            method = 'curl',
#   #            ascpCMD = NULL )
# }

path_metadata <- here("data", "Phenotype_Data_192_samples_RNASeq_Pitt.xlsx")

# ======================================================================= #
# ========================== Load into memory =========================== #
# ======================================================================= #

openxlsx::read.xlsx(xlsxFile = path_metadata) %>% setDT -> dt_metadata
dt_metadata
#     DCL.Patient.ID    SEX BMI_surg    Diagnosis Age
# 1:      DLDR_0104 Female 40.47744   Fibrosis 4  69
# 2:      DLDR_0073 Female 34.47184 Fibrosis 3/4  61
# 3:      DLDR_0096 Female 47.60789   Fibrosis 4  55
# 4:      DLDR_0032 Female 57.83960  STEATOSIS 3  54
# 5:      DLDR_0152 Female 43.78547 Lob Inflam 1  51


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
