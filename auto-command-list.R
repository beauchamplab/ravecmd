# File to generate yaml 

root_url <- "https://raw.githubusercontent.com/beauchamplab/ravecmd/main/common/"

fs <- list.files("common/", recursive = TRUE, all.files = FALSE, full.names = FALSE)

list <- lapply(fs, function(f){
  
  s <- readLines(file.path("common", f))
  s <- stringr::str_trim(s)
  idx <- which(stringr::str_detect(s, "^#---"))
  
  tmpf <- tempfile()
  
  map <- dipsaus::fastmap2()
  tryCatch({
    s <- stringr::str_remove(s[seq(idx[1] + 1, idx[2] - 1)], "^#")
    writeLines(s, tmpf)
    map <- raveio::load_yaml(tmpf, map = map)
    stopifnot(.subset2(map, "has")("name"))
    map$name
  }, error = function(e){
    map$name <- stringr::str_match(f, "([^/\\\\]+)\\.[a-zA-Z0-9]+$")[,2]
  })
  map$path <- f
  map$url <- sprintf("%s%s", root_url, f)
  as.list(map)
})

names(list) <- vapply(list, '[[', FUN.VALUE = "", "name")

raveio::save_yaml(list, "command-list.yaml")
