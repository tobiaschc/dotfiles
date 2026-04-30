# cdf - cd to selected directory
cdf() {
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune \
                  -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
}

# fh - search in your command history and execute selected command
fh() {
  local cmd
  cmd=$(
    ([ -n "$ZSH_NAME" ] && fc -l 1 || history) |
      fzf +s --tac |
      sed 's/ *[0-9]* *//'
  ) || return

  print -z -- "$cmd"
}
