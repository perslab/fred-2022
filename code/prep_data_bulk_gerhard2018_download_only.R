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
#### RAW DATA ####
#
# ~~NCBI SRA Raw sequence: https://www.ncbi.nlm.nih.gov/bioproject/512027~~
#
# ~~NCBI download page: https://www.ncbi.nlm.nih.gov/home/download/~~
# ~~NCBI SRA handbook: https://www.ncbi.nlm.nih.gov/books/NBK47528/~~
#
# European Nucleotide Archive sequence: https://www.ebi.ac.uk/ena/browser/text-search?query=PRJNA512027
# ENA browser tools: https://github.com/enasequence/enaBrowserTools # MUST BE INSTALLED!!
#
#### metadata ####
#
# via email from Johanna DiStefano
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

#library("rentrez")
# ======================================================================= #
# ========================== Download ================================ #
# ======================================================================= #
### You only need to run this step once

# RAW DATA

# get sample identifiers
# /projects/jonatan/tools/enaBrowserTools/python3/enaGroupGet -g wgs -d . -m PRJNA512027


dir_download_data <- "/data/pub-others/gerhard-j_endocrine_soc-2018/"
path_enaGroupTool <- "/projects/jonatan/tools/enaBrowserTools/python3/enaGroupGet"
# using ena browser tools - must be installed (see above link)

if (!dir.exists(paste0(dir_download_data,"PRJNA512027"))) {
  timeStart <- Sys.time()
  system2(command = path_enaGroupTool,args = c("-f fastq", paste0("-d ",dir_download_data), "PRJNA512027"))
  timeDelta <- difftime(time1 = Sys.time(), time2 = timeStart, units = c("auto"))
}
message(paste0("Download time elapsed: ", timeDelta))
