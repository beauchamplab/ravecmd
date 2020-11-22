#!/usr/bin/env -S Rscript --no-restore --no-save
#---
#name: rave-demo-data
#description: Download some large files (demo data, template brain, etc)
#---

library(docopt)

## configuration for docopt
doc <- "Usage: rave-demo-data [-h] [-s] [PACKAGE ...]

-h --help           show this help text
-s --skip-if-exist  whether to skip if data exists to save time

Description: 
  Finalizes installation for given RAVE module packages.

Examples:
  rave-demo-data -h
  rave-demo-data -s .
  rave-demo-data ravebuiltins threeBrain
"
opt <- docopt(doc)

upgrade <- ifelse(opt$skip_if_exist, "never", "always")
packages <- unlist(opt$PACKAGE)

fs_old <- list.files(tempdir(), pattern = '\\.dstate$', full.names = TRUE)

if(length(packages)){
  rave::finalize_installation(packages, upgrade = upgrade)
} else {
  rave::finalize_installation(upgrade = upgrade)
}
Sys.sleep(3)

fs <- list.files(tempdir(), pattern = '\\.dstate$', full.names = TRUE)
fs <- fs[!fs %in% fs_old]

while(length(fs)){
  cat("\r--", length(fs), "jobs left...\r")
  sel <- sapply(fs, function(f){
    if(!file.exists(f)){
      return(0)
    }
    re <- as.integer(readLines(f))
    re <- c(re, NA)[[1]]
    if(is.na(re) || !is.integer(re)){
      return(2)
    } 
    return(re)
  })
  
  fs <- fs[sel > 0]
  Sys.sleep(1)
}

cat("Finished.\n")
