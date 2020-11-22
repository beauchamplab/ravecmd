#!/usr/bin/env -S Rscript --no-restore --no-save
#---
#name: rave
#description: Omnibus command to call RAVE
#---

library(docopt)

## configuration for docopt
doc <- "Usage: rave [CMD] [ARGUMENTS ...]
-h --help           show this help text
CMD                 command to launch; see below
ARGUMENTS           more arguments to pass; see below

1. CMD=\"main\", launch rave main app locally
  For example:
    $ rave
    $ rave main
    $ rave main port=8080 host=127.0.0.1 token=aaa
        
2. CMD=\"preprocess\", similar to rave main application, but launches 
preprocess modules
  For example:
    $ rave preprocess
    $ rave preprocess port=8080 ...

3. CMD=\"option\" launch settings panel
  For example:
    $ rave option
        
4. Other commands. Use `-h` to see details
  $ rave module [-h] [-b] [-m] [-d] [-g] [PACKAGE ...]
  $ rave demo-data [-h] [-s] [PACKAGE ...]
"
opt <- docopt(doc)

cmd <- opt$CMD
if(!length(cmd)){
  cmd <- "main"
}
args <- opt$ARGUMENTS

main_or_preproc <- function(){
  
  if(length(args)){
    args <- sapply(strsplit(args, "=", fixed = TRUE), I, simplify = TRUE)
    args <- structure(as.list(args[2,]), names = args[1,])
    if('port' %in% names(args)){
      args$port <- as.integer(args$port)
    }
  } else {
    args <- list()
  }
  if('launch.browser' %in% names(args)){
    args$launch.browser <- as.logical(args$launch.browser)
  } else {
    args$launch.browser <- TRUE
  }
  args
}


switch (cmd,
  'main' = {
    require(rave)
    args <- main_or_preproc(args)
    do.call(start_rave, args)
  },
  'preprocess' = {
    require(rave)
    args <- main_or_preproc(args)
    do.call(rave_preprocess, args)
  },
  'option' = {
    rave::rave_options(launch_gui = TRUE)
  }, {
    # get specific command lines
    os <- dipsaus:::get_os()
    local_path <- switch(
      os,
      "darwin" = {
        "/Applications/RAVE/bin"
      },
      {
        stop("Operating system not supported.")
      }
    )
    bin <- file.path(local_path, sprintf("rave-%s", cmd))
    if(!length(args)) {
      args <- "-h"
    }
    if(file.exists(bin)){
      subcmd <- sprintf("%s %s", bin, paste(args, collapse = ' '))
      system(subcmd)
    }
  }
)

