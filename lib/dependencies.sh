install_node_modules() {
  echo "Installing node modules"
  npm install --unsafe-perm --quiet --userconfig $BUILD_DIR/.npmrc 2>&1
}

rebuild_node_modules() {
  echo "Rebuilding any native modules"
  npm rebuild 2>&1
  echo "Installing any new modules"
  npm install --unsafe-perm --quiet --userconfig $BUILD_DIR/.npmrc 2>&1
}
