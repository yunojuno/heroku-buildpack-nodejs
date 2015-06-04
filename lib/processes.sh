smallindent() {
  c='s/^/  /'
  case $(uname) in
    Darwin) sed -l "$c";; # mac/bsd sed: -l buffers on line boundaries
    *)      sed -u "$c";; # unix/gnu sed: -u unbuffered (arbitrary) chunks of data
  esac
}

default_process_types() {
  local build_dir=${1:-}

  if [ -f $build_dir/Procfile ]; then
    cat $build_dir/Procfile | smallindent
  elif [ -f $build_dir/package.json ]; then
    printf "  web: npm start\n"
  elif [ -f $build_dir/server.js ]; then
    printf "  web: node server.js\n"
  else
    printf "{}"
  fi
}
