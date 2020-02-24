## Find cluster markers

library(Seurat)
library(openxlsx)

## define constants
path_seuratObj_in = "/projects/jonatan/pub-perslab/18-liver-fred/output/liver_perslab_int_seurat_7_SCTint_perslab_labels_seuratObj_combat.RDS.gz"
path_seuratObj_out = "" # TODO
path_markers_out = ""
annotations = "cluster_perslab_coarse" 
# annotations ="cluster_perslab"

# load seuratObj
seuratObj <- readRDS(path_seuratObj_in)

# get unique cluster labels and set as seuratObj idents
clusters = seuratObj@meta.data[[annotations]] %>% table %>% names 
Idents(seuratObj) <-seuratObj@meta.data[[annotations]]

# for each cluster label, find markers
list_iterable = list("X"=clusters)
fun = function(cluster) {tryCatch({
  FindMarkers(seuratObj ,  
              #cells.1=colnames(seurat_obj)[Idents(seurat_obj)==cluster],
              #cells.2=NULL,
              ident.1 = cluster,
              only.pos = T,
              #ident.2 = clusters[clusters!=cluster],
              test.use  ="MAST",
              max.cells.per.ident=1000,
              random.seed=randomSeed,
              #latent.vars = if (!is.null(merge_specify) | !is.null(merge_group_IDs)) "sample_ID" else NULL,
              verbose = T)
}, 
error = function(err) {
  NA_character_
})}

list_markers=NULL
list_markers <- lapply(FUN=fun, "X"=list_iterable[[1]])

# add the gene and cluster as a column
list_markers <- mapply(function(df_markers, cluster) {
  if (!all(sapply(df_markers, is.na))) {
    cbind("gene" = rownames(df_markers), "cluster"=rep(cluster, nrow(df_markers)), df_markers)
  } else {
    NA_character_
  }
},
df_markers=list_markers, 
cluster=names(table(Idents(seuratObj))), SIMPLIFY=F)

# check for NAs from errors
list_markers <- list_markers[!sapply(list_markers, function(markers) all(is.na(markers)))]

# reduce list of dataframes to a single dataframe
df_markers <- Reduce(x=list_markers, f=rbind)
rownames(df_markers) <- NULL

# write out markers
write.xlsx(x = df_markers, file=path_markers_out)

# save seuratObj (only if needed!!)
saveRDS(object =seuratObj, file = path_seuratObj_out, compress="gzip")
