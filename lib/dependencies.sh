install_node_modules() {
  local build_dir=${1:-}
  cd $build_dir
  echo "installing node modules"
  npm install --unsafe-perm --userconfig $build_dir/.npmrc 2>&1
}

rebuild_node_modules() {
  local build_dir=${1:-}
  cd $build_dir
  echo "rebuilding any native modules"
  npm rebuild 2>&1
  echo "installing any new modules"
  npm install --unsafe-perm --userconfig $build_dir/.npmrc 2>&1
}
