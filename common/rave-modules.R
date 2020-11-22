#!/usr/bin/env -S Rscript --no-restore --no-save --no-site-file --no-init-file 
#---
#name: rave-module
#description: Download and update current RAVE modules
#---

library(docopt)

## configuration for docopt
doc <- "Usage: rave-module [-h] [-b] [-m] [-d] [-g] [PACKAGE ...]
-h --help         show this help text
-m --minimal      avoid downloading large meta data
-b --binary       download compiled version
-d --dependence   also update package dependence
-g --github       download from github instead of CRAN

Description: 
  Download RAVE modules and update module lists. 'package' can be a CRAN
  package name, a Github repository name, or blank

Examples:
  rave-module -h              (display this doc)
  rave-module threeBrain      (update threeBrain from CRAN and update data)
  rave-module -m threeBrain   (update threeBrain but do not update data)
  rave-module --github dipterix/threeBrain beauchamplab/ravebuiltins
                              (update two packages from Github)
"
opt <- docopt(doc)

minimal <- opt$minimal
binary <- ifelse(opt$binary, "binary", "source")
github <- opt$github
packages <- opt$PACKAGE
upgrade <- ifelse(opt$dependence, "always", "never")
libpath <- normalizePath(Sys.getenv('R_LIBS_USER'), mustWork=FALSE)
if(!dir.exists(libpath)){
  dir.create(libpath, recursive = TRUE)
}

inst <- function(pkg){
  if(github){
    remotes::install_github(
      pkg,
      upgrade = upgrade,
      force = TRUE,
      type = binary,
      lib = libpath
    )
    pkg <- stringr::str_match(pkg, "/([^@]+)")[1,2]
  } else {
    utils::install.packages(pkg, lib = libpath, 
                            repos = "https://cloud.r-project.org", type = binary)
  }
  return(pkg)
}


if(!length(packages)){
  cat("No packages specified... (just arrange module list)\n")
  pkgs <- NULL
} else {
  
  # download packages
  pkgs <- lapply(packages, function(p){
    cat("Installing package -", p, "\n")
    inst(p)
  })
  
}

rave::arrange_modules(refresh = TRUE)

# finalize installation
if(!minimal && length(pkgs)) {
  cat("Updating meta data files\n")
  fs_old <- list.files(tempdir(), pattern = '\\.dstate$', full.names = TRUE)
  rave::finalize_installation(pkgs, upgrade = "always")
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
  
}






