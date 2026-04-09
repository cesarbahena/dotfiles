BEGIN {
  BLUE="#[fg=colour39]"
  GREY="#[fg=colour249]"
  Z="#[fg=default]"
}

{
  path = $0
  home = ENVIRON["HOME"]

  if (path == home) {
    printf "%s~%s", BLUE, Z
    exit
  }

  if (index(path, home) == 1) {
    path = "~" substr(path, length(home) + 1)
  }

  n = split(path, parts, "/")
  if (n > 1) {
    parent = ""
    for (i = 1; i < n; i++) {
      parent = parent "/" parts[i]
    }
    printf "%s%s%s%s %s%s%s", GREY, parent, "/", BLUE, parts[n], Z
  } else {
    printf "%s%s%s", BLUE, path, Z
  }
}