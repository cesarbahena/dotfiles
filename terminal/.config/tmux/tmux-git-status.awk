BEGIN {
  BLUE="#[fg=colour39]"
  GREEN="#[fg=colour46]"
  YELLOW="#[fg=colour226]"
  RED="#[fg=colour196]"
  GRAY="#[fg=colour240]"
  Z="#[fg=default]"
}
NR==1 {
  sub(/^## /,"",$0)

  ahead=behind=""
  if (match($0,/\[.*\]/)) {
    meta=substr($0,RSTART,RLENGTH)
    if (match(meta,/ahead [0-9]+/)) {
      tmp=substr(meta,RSTART,RLENGTH)
      sub(/ahead /,"",tmp)
      ahead="a" tmp
    }
    if (match(meta,/behind [0-9]+/)) {
      tmp=substr(meta,RSTART,RLENGTH)
      sub(/behind /,"",tmp)
      behind="b" tmp
    }
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
    untracked++
    next
  }

  if (x!=" " && y==" ") {
    staged[x]++
  } else if (x==" " && y!=" ") {
    wt[y]++
  } else if (x!=" " && y!=" ") {
    both[x y]++
  }
}
END {
  for (s in staged)
    printf " %s%d%s%s", GREEN, staged[s], s, Z
  for (w in wt)
    printf " %s%d%s%s", YELLOW, wt[w], w, Z
  for (b in both)
    printf " %s%d%s%s", RED, both[b], b, Z
  if (untracked)
    printf " %s%d??%s", GRAY, untracked, Z
  print ""
}
