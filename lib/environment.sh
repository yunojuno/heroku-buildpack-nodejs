list_node_config() {
  printenv | grep ^NPM_CONFIG_ || true
  printenv | grep ^NODE_ || true
}

export_env_dir() {
  local env_dir=$1
  if [ -d "$env_dir" ]; then
    local whitelist_regex=${2:-''}
    local blacklist_regex=${3:-'^(PATH|GIT_DIR|CPATH|CPPATH|LD_PRELOAD|LIBRARY_PATH)$'}
    if [ -d "$env_dir" ]; then
      for e in $(ls $env_dir); do
        echo "$e" | grep -E "$whitelist_regex" | grep -qvE "$blacklist_regex" &&
        export "$e=$(cat $env_dir/$e)"
        :
      done
    fi
  fi
}

write_profile() {
  local bp_dir="$1"
  local build_dir="$2"
  mkdir -p $build_dir/.profile.d
  echo "export PATH=\"\$HOME/.heroku/node/bin:\$HOME/bin:\$HOME/node_modules/.bin:\$PATH\"" > $build_dir/.profile.d/nodejs.sh
  echo "export NODE_HOME=\"\$HOME/.heroku/node\"" >> $build_dir/.profile.d/nodejs.sh
  cat $bp_dir/lib/concurrency.sh >> $build_dir/.profile.d/nodejs.sh
}

write_export() {
  local bp_dir="$1"
  local build_dir="$2"
  echo "export PATH=\"$build_dir/.heroku/node/bin:$build_dir/node_modules/.bin:\$PATH\"" > $bp_dir/export
  echo "export NODE_HOME=\"$build_dir/.heroku/node\"" >> $bp_dir/export
}
