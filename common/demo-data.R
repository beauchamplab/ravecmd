#!/usr/local/bin/Rscript --no-save --no-restore
#---
#name: rave-demo-data
#description: Download some large files (demo data, template brain, etc)
#---

cat("Installing template brain")

rave::finalize_installation(upgrade = 'always')

Sys.sleep(10)

fs <- list.files(tempdir(), pattern = '\\.dstate$', full.names = TRUE)

while(length(fs)){
  cat("\n--------------------------------", length(fs), "jobs left...\n")
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
