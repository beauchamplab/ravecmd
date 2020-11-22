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

for(cmdname in cmds){
  info <- cmdlist[[cmdname]]
  tryCatch({
    utils::download.file(info$url)
  })
}

