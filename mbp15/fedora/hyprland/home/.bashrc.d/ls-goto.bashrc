# ~/.bashrc.d/ls-goto.bashrc

__LS_GOTO_LASTDIR=""

function ls {
  command ls -a "$@"
  local rc=$?
  (( rc != 0 )) && return "$rc"

  # Last non-option argument
  local last="" arg=""
  for arg in "$@"; do
    case "$arg" in
      -*) ;;          # skip options
      *)  last="$arg" ;;
    esac
  done

  # Plain `ls` => don't change remembered directory
  [[ -z "$last" ]] && return 0

  local d="$last"

  # Strip trailing slash except for root
  if [[ "$d" != "/" ]]; then
    d="${d%/}"
  fi

  # If they listed a directory directly, remember it
  if [[ -d "$d" ]]; then
    __LS_GOTO_LASTDIR="$d"
    return 0
  fi

  # If they listed something like dir/* or /etc/*.conf, remember the parent dir
  local parent="${d%/*}"
  if [[ -z "$parent" && "$d" == /* ]]; then
    parent="/"
  fi
  if [[ -n "$parent" && -d "$parent" ]]; then
    __LS_GOTO_LASTDIR="$parent"
  fi

  return 0
}

function goto {
  if [[ -n "$__LS_GOTO_LASTDIR" && -d "$__LS_GOTO_LASTDIR" ]]; then
    cd -- "$__LS_GOTO_LASTDIR"
  else
    printf 'goto: no remembered directory (try: ls somedir/)\n' >&2
    return 1
  fi
}
