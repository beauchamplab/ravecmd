# Script to index RAVE commands. should not run directly

project_url <- "https://raw.githubusercontent.com/beauchamplab/ravecmd/main/"

# read in command-list

cmdlist <- yaml::read_yaml(sprintf("%s%s", project_url, "command-list.yaml"))

# for OSX, This should go to /Applications/RAVE/scripts/...

os <- dipsaus:::get_os()

local_path <- switch(
  os,
  "darwin" = {
    "/Applications/RAVE/bin"
  },
  {
    stop("Operating system not supported now")
  }
)

cmds <- names(cmdlist)

if(!dir.exists(local_path)) {
  dir.create(local_path, recursive = TRUE)
}

for(cmdname in cmds){
  info <- cmdlist[[cmdname]]
  target <- file.path(local_path, cmdname)
  cat(sprintf("Check out command `%s` ...", cmdname), end = "\b\b\b\b")
  tryCatch({
    utils::download.file(info$url, target, quiet = TRUE)
    stopifnot(file.exists(target))
    cat("    \n  =>", target, end = "\n")
  }, error = function(e){
    cat(" ... (Failed).", end = "\n")
  })
}

# Change file permission
system(sprintf('chmod -R 751 %s/rave*', local_path))

# Create command in /usr/local/bin/rave as omnibus command for RAVE

src <- normalizePath(file.path(local_path, "rave"), mustWork = FALSE)
if(file.exists(src) && os %in% c('darwin', 'linux') && !file.exists("/usr/local/bin/rave")) {
  file.symlink(src, "/usr/local/bin/rave")
}



