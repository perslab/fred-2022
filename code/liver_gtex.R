## Script to prepare GTEx human liver samples for analysis 
# author: Jonatan Thompson / Pers Lab, rkm916@ku.dk

######################################################################
########################## FUNCTIONS #################################
######################################################################

source(file="/projects/jonatan/tools/functions-src/utility_functions.R")

######################################################################
########################## CONSTANTS #################################
######################################################################

dirOut = "/projects/jonatan/tmp-liver/"
prefixOut = "GTEx_liver_1"
pathData = '/data/rna-seq/gtex'
pathSeuratObj = '/data/rna-seq/gtex/v7-seurat_objs/gtex.seurat_obj.gene_tpm.RData'
pathSrc = '/raid5/projects/timshel/sc-genetics/sc-genetics/src/GE-gtex/load_gtex_to_seurat.Rmd'
pathSrc2 = '/raid5/projects/timshel/sc-genetics/sc-genetics/src/GE-gtex/extract_hypothalamus_samples_from_gtex.R'
pathAnnotSample <- 
pathAnnotSampleDict <- '/data/rna-seq/gtex/v7/GTEx_Analysis_v7_Annotations_SampleAttributesDD.xlsx'	#5.4M	A data dictionary that describes each variable in the GTEx_v7_Annotations_SampleAttributesDS.txt
pathAnnotPhenoDict <-'/data/rna-seq/gtex/v7/GTEx_Analysis_v7_Annotations_SubjectPhenotypesDD.xlsx'#	11K	A data dictionary that describes each variable in the GTEx_v7_Annotations_SubjectPhenotypesDS.txt.
pathAnnotSample <- '/data/rna-seq/gtex/v7/GTEx_v7_Annotations_SampleAttributesDS.txt'	#7.9M	A de-identified, open access version of the sample annotations available in dbGaP.
pathAnnotPheno <- '/data/rna-seq/gtex/v7/GTEx_v7_Annotations_SubjectPhenotypesDS.txt'#	16K	A de-identified, open access version of the subject phenotypes available in dbGaP.

######################################################################
########################### PACKAGES #################################
######################################################################

ipak(c("dplyr", "Matrix", "parallel", "readr", "Seurat", "readxl"))
stopifnot(packageVersion("Seurat")=='3.0.0.9000')

######################################################################
############################ SET OPTIONS #############################
######################################################################

options(stringsAsFactors = F, use="pairwise.complete.obs")

######################################################################
############################ CONSTANTS ###############################
######################################################################

# if specified output directory doesn't exist, create it 
if (!file.exists(dirOut)) {
  dir.create(dirOut) 
  message("dirOut not found, new one created")
}

dirPlots = paste0(dirOut,"plots/")
if (!file.exists(dirPlots)) dir.create(dirPlots) 

dirTables = paste0(dirOut,"tables/")
if (!file.exists(dirTables)) dir.create(dirTables)

dirRObjects = paste0(dirOut,"RObjects/")
if (!file.exists(dirRObjects)) dir.create(dirRObjects)

dirLog = paste0(dirOut,"log/")
if (!file.exists(dirLog)) dir.create(dirLog)

flagDate = substr(gsub("-","",as.character(Sys.Date())),3,1000)

randomSeed = 12345

######################################################################
########################### LOAD DATA ################################
######################################################################

message("Loading data")

seuratObjAll <- load_obj(pathSeuratObj)
annotSample <- read.delim(pathAnnotSample, header = T, sep = "\t")
annotPheno <- read.delim(pathAnnotPheno, header = T, sep = "\t")
  
if (seuratObjAll@version!='3.0.0.9000') seuratObjAll <- Seurat::UpdateSeuratObject(object = seuratObjAll) 


######################################################################
########################## INSPECT DATA ##############################
######################################################################

filterExprs <- c(SMTS=="Liver")

