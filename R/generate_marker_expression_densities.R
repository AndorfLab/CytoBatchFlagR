#!/usr/bin/env R

###############################################################################################
########################~~~~ cytoFlagR marker expression densities ~~~~########################
###############################################################################################

suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(scales))
suppressPackageStartupMessages(library(tidyr))
suppressPackageStartupMessages(library(reshape2))
suppressPackageStartupMessages(library(readxl))
suppressPackageStartupMessages(library(readr))
suppressPackageStartupMessages(library(matrixStats))
suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(ggpubr))
suppressPackageStartupMessages(library(ggridges))
suppressPackageStartupMessages(library(MASS))
suppressPackageStartupMessages(library(RColorBrewer))
suppressPackageStartupMessages(library(cowplot))
suppressPackageStartupMessages(library(limma))
suppressPackageStartupMessages(library(ggrepel))
suppressPackageStartupMessages(library(circlize))
suppressPackageStartupMessages(library(progress))
suppressPackageStartupMessages(library(crayon))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(ggpmisc))
suppressPackageStartupMessages(library(viridis))
suppressPackageStartupMessages(library(grid))

###############################################################################################
########~~~~ Marker expression density distribution function, i.e., histogram plot ~~~~########
###############################################################################################

density_plots_w_thresholds<-function(df,marker,batch_list,control_list,cutf,axis_size=NULL) {
  
  mdf<-data.frame(df)
  mdf$reference<-"no"
  ### create reference
  ggd_bg<-mdf
  ggd_bg$batch<-"ref"
  ggd_bg$reference<-"yes"
  head(ggd_bg)
  
  ggd_plot<-rbind(mdf,ggd_bg)
  ggd_plot$control<-factor(ggd_plot$control,levels = control_list)
  ggd_plot$batch<-factor(ggd_plot$batch, levels = c(rev(batch_list),"ref"))
  
  ggplot() +
    geom_density_ridges(data = ggd_plot,
                        aes(x = expression, y = batch, color = reference, fill = reference),
                        alpha = 0.3,show.legend = F) +
    ggtitle(paste0("Expression densities for ",marker," with automated cutoff")) +
    geom_vline(xintercept = cutf,linewidth=1.0,colour="#121518") +
    facet_wrap( ~ control, nrow = 1) +
    xlab("Expression") +
    ylab("Batch") +
    theme_ridges(center_axis_labels = TRUE) +
    theme(axis.text.x = element_text(size = axis_size),axis.text.y = element_text(size = axis_size+7),
          axis.title = element_text(size = axis_size+9),
          plot.title = element_text(size = axis_size+9, face = "bold"),
          strip.text = element_text(size = axis_size+5, face = "bold"),
          legend.position = "none")
}

#### create long-form transformed dataframe for density plots ####
reshape_df<-function(df,sample_col_name,batch_col_name,markers) {
  
  molten_df<-melt(data.frame(df[,markers],sample_id = df[,"sample_id"]),
                  id.vars = "sample_id",variable.name = "marker",
                  value.name = "expression")
  mm<-match(molten_df$sample_id,df$sample_id)
  molten_df[,"batch"]<-df[,batch_col_name][mm]
  molten_df[,"control"]<-df[,sample_col_name][mm]
  
  return(molten_df)
}

##### Plot, print and save marker expression density plots ##### 
write_density_plot_per_marker<-function(marker_list, df, batch_list, control_list, 
                                        auto_cutoffs, batch_colm, control_colm, 
                                        output_dir, wd = 12, ht = 11, axis_size = 14, 
                                        file_name = "panel_marker_expression_densities"){
  
  cat("This process will take a long time, please be patient\n")
  colrSet<-crayon::make_style("#539DDD")
  total_iter<-length(marker_list)
  ### create progress bar
  pBar<-progress::progress_bar$new(
    
    format = paste0(colrSet("Plotting marker expression densities"),
                    " [",colrSet(":bar"),"] ",
                    colrSet(":percent")," | Marker: :current/:total ",
                    "| Elapsed: :elapsed | ETA: :eta"),
    total = total_iter,
    clear = FALSE,
    width = 80,
    complete = "=",
    incomplete = "-"
  )
  
  file_name<-paste0(file_name,".pdf")
  pdf_file_path<-file.path(output_dir, file_name)
  
  ### get sample id column if one doesn't exist
  if(is.null(df[,"sample_id"])) {
    df[,"sample_id"]<-paste0(df[,batch_colm],"_",df[,control_colm]) 
  }
  ### reshape dataframe for plotting
  cdf<-data.frame(reshape_df(df,control_colm,batch_colm,marker_list))
  
  # Open the PDF device
  pdf(pdf_file_path, width = wd, height = ht, useDingbats = FALSE)
  
  for (i in 1:length(marker_list)) {
    mk<-marker_list[i]
    
    ### update progress bar
    pBar$tick(tokens = list(current = i))
    
    mdf<-cdf[(cdf$marker==marker_list[i]),]
    mdf$marker<-as.character(mdf$marker)
    cutf<-as.numeric(auto_cutoffs[which(auto_cutoffs$marker==mk),"cutoff"])
    plot<-density_plots_w_thresholds(df = mdf,marker = mk,batch_list = batch_list,
                                     control_list = control_list,cutf = cutf,axis_size = axis_size)
    print(plot)
    cat(i, "of", length(marker_list), "markers plotted", "\n")
  }
  dev.off()
  
  # Notify user of completion
  cat("PDF saved as", pdf_file_path, "\n")
}

###############################################################################################
######################~~~~ marker expression density biaxial dotplots ~~~~#####################
###############################################################################################

##### kernel density function #####
get_density <- function(x, y, ...) {
  dens <- MASS::kde2d(x, y, ...)
  ix <- findInterval(x, dens$x)
  iy <- findInterval(y, dens$y)
  ii <- cbind(ix, iy)
  return(dens$z[ii])
}

##### biaxial dotplot function #####

biax_grid_plot<-function(df,ref_marker,select_marker,colrs,cutf,axis_size=NULL) {
  
  ggplot() +
    geom_point(data = df, aes(x = marker, y = ref, color = density), size=0.1) +
    facet_grid(batch~control) +
    geom_vline(xintercept = cutf, colour="#222528", linewidth=1.5) + ### marker cutoff
    xlab(select_marker)+
    ylab(ref_marker)+
    scale_color_gradientn(colours = colrs) +
    ggtitle(paste0("Biaxial density dot-plots of ",select_marker," against ",ref_marker)) +
    theme_bw() +
    theme(axis.text.y = element_text(size = axis_size+2),
          axis.text.x = element_text(size = axis_size),
          axis.title = element_text(size = axis_size+6,face = "bold"),
          strip.text.y = element_text(size = axis_size+6,face = "bold"),
          strip.text.x = element_text(size = axis_size+7, face = "bold"),
          legend.title = element_text(size = (axis_size-3)),
          legend.text = element_text(size = (axis_size-5)),
          plot.title = element_text(size = axis_size+8, face = "bold"))
}

##### downsampled dataframe for dotplot creation #####
subsample_for_biax_plot<-function(df,samps){
  
  ### get number of cells per sample and set sample size as min. cells per batch
  ncells<-data.frame(table(df$sample_id)) 
  colnames(ncells)<-c("sample_id","Freq")
  mm<-match(ncells$sample_id,df$sample_id)
  ncells$batch<-df$batch[mm]
  ncells<-ncells %>% group_by(batch) %>% mutate(min_per_batch = min(Freq))
  
  mm<-match(df$sample_id,ncells$sample_id)
  df$min_cells<-ncells$min_per_batch[mm]
  
  set.seed(3000)
  
  subsamp <- c()
  
  for(fi in 1:length(samps)){
    tmp <- which(df[,"sample_id"]==samps[fi])
    mc<-unique(df[which(df[,"sample_id"]==samps[fi]),"min_cells"])
    subsamp <- c(subsamp, tmp[sample(1:length(tmp), mc)])
  }
  rdf<-df[subsamp,]
  return(rdf)
  
}

##### Generate, print and save marker expression dot plots against reference marker ##### 

draw_biaxial_dotplots<-function(df, ref_marker, marker_list, control_list, 
                                batch_list, samps, auto_cutoffs, batch_col_name, control_col_name, 
                                wd = 4500, ht = 6000, axis_size = 20, output_dir){
  ### sanity check
  if(missing(output_dir)) {
    stop("output_dir parameter is required")
  }
  if (!dir.exists(output_dir)) {
    stop("Output directory does not exist: ", output_dir)
  }
  
  if(control_col_name!="control") {
    names(df)[names(df)==control_col_name]<-"control"
  }
  if(batch_col_name!="batch") {
    names(df)[names(df)==batch_col_name]<-"batch"
  }
  
  ### get sample id column if one doesn't exist
  if(is.null(df[,"sample_id"])) {
    df[,"sample_id"]<-paste0(df[,"batch"],"_",df[,"control"])
  }
  
  cat("This process will take a long time, please be patient\n")
  
  colrSet<-crayon::make_style("#539DDD")
  total_iter<-length(marker_list)
  ### create progress bar
  pBar<-progress::progress_bar$new(
    
    format = paste0(colrSet("Plotting density dotplots"),
                    " [",colrSet(":bar"),"] ",
                    colrSet(":percent")," | Marker: :current/:total ",
                    "| Elapsed: :elapsed | ETA: :eta"),
    total = total_iter,
    clear = FALSE,
    width = 80,
    complete = "=",
    incomplete = "-"
  )
  
  cdf<-subsample_for_biax_plot(df = df, samps = samps)
  
  #### colour vector to represent dense regions ###
  densColrs<-rev(RColorBrewer::brewer.pal(11, "RdYlBu"))
  
  for (i in 1:length(marker_list)) {
    mk<-marker_list[i]
    
    pdf_file_path<-file.path(output_dir, 
                             paste0("density_dotplot_",mk,"_vs_",ref_marker,"_reference_marker.png"))
    
    colms.to_use<-c(ref_marker, mk, "batch", "control")
    
    ### update progress bar
    pBar$tick(tokens = list(current = i))
    
    cutf<-as.numeric(auto_cutoffs[which(auto_cutoffs$marker==mk),"cutoff"])
    
    mdf<-cdf[,names(cdf) %in% colms.to_use]
    mdf$density<-get_density(mdf[,ref_marker], mdf[,mk], n = 100) ### get densities
    colnames(mdf)<-c("ref","marker","batch","control","density")
    mdf$control<-factor(mdf$control, levels = control_list)
    mdf$batch<-factor(mdf$batch, levels = batch_list)
    
    ### generate dotplot
    plotp<-biax_grid_plot(df = mdf, ref_marker = ref_marker, select_marker = mk, colrs = densColrs, 
                          cutf = cutf, axis_size=axis_size)
    
    tryCatch({
      # Open the PDF device
      png(pdf_file_path, width = wd, height = ht, res = 300)
      print(plotp)
      dev.off()
      
      cat(i, "of", length(marker_list), "markers plotted", "\n")
      
    }, error = function(r) {
      message("Error in plotting densities: ",r$message)
    })
  }

  # Notify user of completion
  cat("Plots saved in", output_dir, "\n")
}

###############################################################################################
