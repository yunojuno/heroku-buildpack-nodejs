source $BP_DIR/lib/binaries.sh

create_signature() {
  echo "$(node --version); $(npm --version)"
}

save_signature() {
  echo "$(get_signature)" > $CACHE_DIR/node/signature
}

load_signature() {
  if test -f $CACHE_DIR/node/signature; then
    cat $CACHE_DIR/node/signature
  else
    echo ""
  fi
}

signature_changed() {
  if ! [ "$(create_signature)" == "$(load_signature)" ]; then
    return 1
  else
    return 0
  fi
}

get_cache_status() {
  if ! ${NODE_MODULES_CACHE:-true}; then
    echo "disabled"
  elif signature_changed; then
    echo "invalidated"
  else
    echo "valid"
  fi
}

get_cache_directories() {
  local dirs1=$(read_json "$BUILD_DIR/package.json" ".cacheDirectories | .[]?")
  local dirs2=$(read_json "$BUILD_DIR/package.json" ".cache_directories | .[]?")
  if [ -n "$dirs1" ]; then
    echo "$dirs1"
  else
    echo "$dirs2"
  fi
}

restore_cache_directories() {
  for dir in "$@"; do
    echo "- $dir"
  done
}

clear_cache() {
  rm -rf $CACHE_DIR/node
}

save_cache_directories() {
  mkdir -p $CACHE_DIR/node
  for dir in "$@"; do
    echo "- $dir"
  done
}
