BEGIN {
  BLUE="#[fg=colour39]"
  GREEN="#[fg=colour46]"
  YELLOW="#[fg=colour226]"
  RED="#[fg=colour196]"
  DIM="#[fg=colour240]"
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
      ahead=tmp+0
    }
    if (match(meta,/behind [0-9]+/)) {
      tmp=substr(meta,RSTART,RLENGTH)
      sub(/behind /,"",tmp)
      behind=tmp+0
    }
    sub(/ \[.*\]$/,"",$0)
  }

  split($0,a,"\\.\\.\\.")
  local=a[1]; remote=a[2]

  if (remote == "") {
    printf "%s%s%s %s?%s", BLUE, local, Z, DIM, Z
  } else {
    if (index(remote,"origin/") == 1) remote=substr(remote,8)
    same_name = (remote == local)
    out = same_name ? local : local ":" remote

    if (ahead > 0 && behind > 0) {
      printf "%s%s%s %s%d %s!= %s%d%s", BLUE, out, Z, RED, ahead, RED, behind, RED, Z
    } else if (ahead > 0) {
      if (same_name) {
        if (ahead == 1) printf "%s%s%s %s>%s", BLUE, local, Z, GREEN, Z
        else printf "%s%s%s %s> %s%d%s", BLUE, local, Z, GREEN, GREEN, ahead, Z
      } else {
        if (ahead == 1) printf "%s%s%s %s> %s%s%s", BLUE, out, Z, GREEN, DIM, remote, Z
        else printf "%s%s%s %s> %s%d %s%s%s", BLUE, out, Z, GREEN, GREEN, ahead, DIM, remote, Z
      }
    } else if (behind > 0) {
      if (same_name) {
        if (behind == 1) printf "%s%s%s %s<%s", BLUE, local, Z, YELLOW, Z
        else printf "%s%s%s %s< %s%d%s", BLUE, local, Z, YELLOW, YELLOW, behind, Z
      } else {
        if (behind == 1) printf "%s%s%s %s< %s%s%s", BLUE, out, Z, YELLOW, DIM, remote, Z
        else printf "%s%s%s %s< %s%d %s%s%s", BLUE, out, Z, YELLOW, YELLOW, behind, DIM, remote, Z
      }
    } else {
      printf "%s%s%s", BLUE, out, Z
    }
  }
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
    printf " %s%d??%s", DIM, untracked, Z
  print ""
}
