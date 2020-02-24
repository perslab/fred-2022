# Liver correlation analysis


######################################################################
########################### SOURCE ##################################
######################################################################

source(file="/projects/jonatan/tools/functions-src/utility_functions.R")
source(file="/projects/jonatan/tools/functions-src/functions_sc.R")
dirCurrent = paste0(LocationOfThisScript(), "/")

######################################################################
############################# OPTIONS ################################
######################################################################

options(stringsAsFactors = F)

######################################################################
############################# PACKAGES ###############################
######################################################################

ipak(c("WGCNA", "Matrix", "dplyr", "reshape", "reshape2", "readr"))

######################################################################
############################# CONSTANTS ##############################
######################################################################
pvalThreshold <- 0.05
prefixData <- "liver"
prefixRun <- "wgcna_1"
prefixOut <- "assoc"
dirProject <- "/projects/jonatan/tmp-liver/"

dirRObjects = paste0(dirProject, "/RObjects/")
dirPlots = paste0(dirProject, "/plots/")
dirLog = paste0(dirProject, "/log/")
dirTables = paste0(dirProject, "/tables/")

######################################################################
################################ DATA ################################
######################################################################

mat_embed <- load_obj("/projects/jonatan/tmp-liver/tables/liver_wgcna_1_kIM_cellModEmbed.csv.gz")
metadata <- load_obj("/projects/jonatan/tmp-liver/data/metadataCombinedCell.csv")

######################################################################
############################# ANALYSIS ###############################
######################################################################

cell_clusters <- sort(unique(mat_embed[["cell_cluster"]]))
list_mat_embed <- lapply(cell_clusters, function(clustr) {
  mat_sub <- mat_embed[mat_embed[["cell_cluster"]]==clustr, grepl(clustr, colnames(mat_embed))]
  rownames(mat_sub) <- mat_embed[["cell_id"]][mat_embed[["cell_cluster"]]==clustr]
  mat_sub
})
names(list_mat_embed) <- sort(unique(mat_embed[["cell_cluster"]]))

list_df_metadata <- lapply(cell_clusters, function(clustr) {
  metadata[rownames(metadata) %in% rownames(list_mat_embed[[clustr]]),]
})

# Get correlations
list_mat_modMetadataRho <- mapply(function(mat_embedSub,df_metadataSub) WGCNA::cor(x=mat_embedSub, 
                                                                      y=df_metadataSub, 
                                                                      method = c("pearson"), 
                                                                      use = 'pairwise.complete.obs'), 
                              mat_embedSub=list_mat_embed, 
                              df_metadataSub=list_df_metadata,  
                              SIMPLIFY = F) 

list_mat_modMetadataP <- mapply(function(mat_modMetadataRho, df_metadata) {
  WGCNA::corPvalueStudent(
    cor = mat_modMetadataRho,
    nSamples = nrow(df_metadata))
  }, 
  mat_modMetadataRho =list_mat_modMetadataRho, 
  df_metadata  = list_df_metadata,
  SIMPLIFY=F)

mat_modMetadataRho <- Reduce(f=rbind, x=list_mat_modMetadataRho)
mat_modMetadataP <- Reduce(f=rbind, x=list_mat_modMetadataP)

# adjust p-values
mat_modMetadataQ <- apply(X=mat_modMetadataP, MARGIN=2, FUN =  p.adjust, method="fdr")

# Find modules that are significantly correlated with NASH
vec_logicNASHSignif <- mat_modMetadataQ[,"NASH"] < pvalThreshold

df_modFilter <- data.frame("module"=rownames(mat_modMetadataRho), 
                           "NASHsignif" = vec_logicNASHSignif)

write_csv(x=df_modFilter, path = paste0(dirTables, prefixOut, "_NASHmodFilter.csv"))

message("Script done!")