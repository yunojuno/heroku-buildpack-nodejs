get_os() {
  uname | tr A-Z a-z
}

get_cpu() {
  if [[ "$(uname -p)" = "i686" ]]; then
    echo "x86"
  else
    echo "x64"
  fi
}

os=$(get_os)
cpu=$(get_cpu)

read_json() {
  local file=$1
  local key=$2
  if test -f $file; then
    cat $file | $BP_DIR/vendor/jq-$os --raw-output "$key // \"\"" || return 1
  else
    echo ""
  fi
}

needs_resolution() {
  local semver=$1
  if ! [[ "$semver" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    return 0
  else
    return 1
  fi
}

list_engines() {
  local node_engine="$1"
  local iojs_engine="$2"
  local npm_engine="$3"

  if [ "$iojs_engine" == "" ]; then
    echo "engines.node (package.json):  ${node_engine:-unspecified}"
  else
    echo "engines.iojs (package.json):  $iojs_engine (iojs)"
  fi
  echo "engines.npm (package.json):   ${npm_engine:-unspecified (use default)}"
  echo ""
}

install_nodejs() {
  local version="$1"
  local dir="$2"

  if [ "$version" == "" ]; then return; fi

  if needs_resolution "$version"; then
    echo "Resolving node version ${version:-(latest stable)} via semver.io..."
    local version=$(curl --silent --get --data-urlencode "range=${version}" https://semver.herokuapp.com/node/resolve)
  fi

  echo "Downloading and installing node $version..."
  local download_url="http://s3pository.heroku.com/node/v$version/node-v$version-$os-$cpu.tar.gz"
  curl "$download_url" -s -o - | tar xzf - -C /tmp
  mv /tmp/node-v$version-$os-$cpu/* $dir
  chmod +x $dir/bin/*
  export PATH=$dir/bin:$PATH
  echo "listing bin:"
  ls $dir/bin
}

install_iojs() {
  local version="$1"
  local dir="$2"

  if [ "$version" == "" ]; then return; fi

  if needs_resolution "$version"; then
    echo "Resolving iojs version ${version:-(latest stable)} via semver.io..."
    version=$(curl --silent --get --data-urlencode "range=${version}" https://semver.herokuapp.com/iojs/resolve)
  fi

  echo "Downloading and installing iojs $version..."
  local download_url="https://iojs.org/dist/v$version/iojs-v$version-$os-$cpu.tar.gz"
  curl $download_url -s -o - | tar xzf - -C /tmp
  mv /tmp/iojs-v$version-$os-$cpu/* $dir
  chmod +x $dir/bin/*
  export PATH=$dir/bin:$PATH
}

install_npm() {
  local version="$1"

  if [ "$version" == "" ]; then
    echo "Using default npm version: `npm --version`"
  else
    if needs_resolution "$version"; then
      echo "Resolving npm version ${version} via semver.io..."
      version=$(curl --silent --get --data-urlencode "range=${version}" https://semver.herokuapp.com/npm/resolve)
    fi
    if [[ `npm --version` == "$version" ]]; then
      echo "npm `npm --version` already installed with node"
    else
      echo "Downloading and installing npm $version (replacing version `npm --version`)..."
      npm install --unsafe-perm --quiet -g npm@$version 2>&1 >/dev/null | indent
    fi
  fi

  warn_old_npm `npm --version`
}
