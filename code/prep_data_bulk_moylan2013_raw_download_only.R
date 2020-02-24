############### SYNOPSIS ###################
# Download and prepare Moylan 2013 bulk liver dataset

### OUTPUT:
# ....

### REMARKS:
# ....

### REFERENCE:
# GEO accession display https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE49541
#
# Murphy SK, Yang H, Moylan CA, Pang H et al. Relationship between methylome and transcriptome
# in patients with nonalcoholic fatty liver disease. Gastroenterology 2013 Nov;145(5):1076-87.
# PMID: 23916847 https://www.ncbi.nlm.nih.gov/pubmed/23916847
#
# Moylan CA, Pang H, Dellinger A, Suzuki A et al. Hepatic gene expression profiles differentiate
# presymptomatic patients with mild versus severe nonalcoholic fatty liver disease.
# Hepatology 2014 Feb;59(2):471-82. PMID: 23913408
# https://www.ncbi.nlm.nih.gov/pubmed/23913408

# DO NOT RUN - microarray, no point

path_download_GSE49541_supp_raw <-  "/data/pub-others/moylan-hepatology-2013/GSE49541_RAW.tar"  #here("data","GSE49541_RAW.tar")
path_download_GSE49541_supp_filelist <-  "/data/pub-others/moylan-hepatology-2013/filelist.txt"  #here("data","GSE49541_RAW.tar")

if (!file.exists(path_download_GSE49541_supp_raw)) {
  # download supp data
  downloadURL <-  "ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE49nnn/GSE49541/suppl/GSE49541_RAW.tar"
  download.file(downloadURL, destfile=path_download_GSE49541_supp_raw)
  # untar
  system2(command = "tar",args = c("-xvf", path_download_GSE49541_supp_raw))
  # donwload file list
  downloadURL2 <-  "ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE49nnn/GSE49541/suppl/filelist.txt"
  download.file(downloadURL2, destfile=path_download_GSE49541_supp_filelist)
}
