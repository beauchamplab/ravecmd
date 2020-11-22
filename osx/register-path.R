# add rave to osx path

add_sh_profile <- function(path, cmd = 'export PATH=$PATH:/Applications/RAVE/bin'){
  # path <- '.profile'
  cat("\nAdd RAVE command-line tools to -", path, end = "")
  f <- file.path('~/', path)
  if(file.exists(f)){
    s <- readLines(f)
    if(any(s == cmd)) {
      return(invisible())
    }
  }
  s <- c(s, '', cmd, "")
  cat(" writing...")
  writeLines(s, f)
  invisible()
}

# Add files to commandline start-up scripts
print('1')
add_sh_profile('.profile')
add_sh_profile('.bash_profile')
add_sh_profile('.zshenv')
print('2')
add_sh_profile('.cshrc', 'set path = ( $path /Applications/RAVE/bin )')
add_sh_profile('.tcshrc', 'set path = ( $path /Applications/RAVE/bin )')
print('3')
cat("\nDone.")
