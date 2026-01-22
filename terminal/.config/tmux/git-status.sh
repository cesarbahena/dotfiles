git status --porcelain=v1 -b | awk '
BEGIN {
  GRAY="#[fg=colour240]"
  GREEN="#[fg=colour46]"
  YELLOW="#[fg=colour226]"
  RED="#[fg=colour196]"
  BLUE="#[fg=colour39]"
  Z="#[fg=default]"
}
NR==1 {
  sub(/^## /,"",$0)

  ahead=behind=""
  if (match($0,/\[.*\]/)) {
    meta=substr($0,RSTART,RLENGTH)
    if (match(meta,/ahead ([0-9]+)/,m))  ahead="a" m[1]
    if (match(meta,/behind ([0-9]+)/,m)) behind="b" m[1]
    sub(/ \[.*\]$/,"",$0)
  }

  split($0,a,"\\.\\.\\.")
  local=a[1]; remote=a[2]

  if (remote == "") out=local ":?"
  else {
    if (index(remote,"origin/") == 1) remote=substr(remote,8)
    out=(remote!=local)? local ":" remote : local
  }

  printf "%s%s%s", BLUE, out, Z
  if (ahead)  printf " %s%s%s", GREEN, ahead, Z
  if (behind) printf " %s%s%s", RED, behind, Z
  next
}
{
  x=substr($0,1,1)
  y=substr($0,2,1)

  if (x=="?" && y=="?") {
    c["??"]++
    next
  }

  xi=(x==" " ? "·" : x)
  yi=(y==" " ? "·" : y)

  c[xi yi]++
}
END {
  for (k in c) {
    if (k == "??") {
      printf " %s%d??%s", GRAY, c[k], Z
      continue
    }

    x = substr(k,1,1)
    y = substr(k,2,1)

    if (x != "·" && y == "·") {        # index only
      tok = x
      col = GREEN
    } else if (x == "·" && y != "·") { # WT only
      tok = y
      col = YELLOW
    } else {                           # both
      tok = x y
      col = RED
    }

    printf " %s%d%s%s", col, c[k], tok, Z
  }
  print ""
}'
