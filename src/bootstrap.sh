#!/usr/bin/env bash

HELP="vert <target_dir>"

if [[ ! "$1" ]]
then
  echo "vert takes 1 argument 0 given"
fi

TARGET_DIR=$1
CURRENT_DIR=`pwd`

if [[ ! -e './build' ]]
then
  mkdir './build'
fi

if [[ ! -e './.vert' ]]
then
  mkdir './.vert'
fi

build_lua () {
  # $1 = lua version to install ex: 5.1.5, 5.2
  # $2 = platform to install on ex: linux, solaris, bsd
  # $3 = directory to install to ex: ./

  if [[ ! "$1" ]]
  then
    echo "build_lua takes 3 arguments 0 given"
  fi
  local version=$1

  if [[ ! "$2" ]]
  then
    echo "build_lua takes 3 arguments 1 given"
  fi
  local platform=$2

  if [[ ! "$3" ]]
  then
    echo "build_lua takes 3 arguments 2 given"
  fi
  local target_dir=$3

  local lua_url="http://www.lua.org/ftp/lua-$version.tar.gz"

  if [[ ! -e "./build/lua-$version.tar.gz" ]]
  then
    wget $lua_url -O "./build/lua-$version.tar.gz"
  fi

  tar -xvpf "./build/lua-$version.tar.gz" -C ./build

  mv "./build/lua-$version" './build/lua'
  pushd './build/lua'
  make $platform
  make install INSTALL_TOP="$target_dir"
  popd
}


build_luarocks () {
  # $1 = version: luarocks version to install ex: 5.1.5, 5.2
  # $2 = prefix: prefix to install luarocks into
  # $3 = sysconfdir: where to store luarocks config
  # $4 = with_lua: What lua to use

  if [[ ! "$1" ]]
  then
    echo "build_luarocks takes 4 arguments 0 given"
  fi
  local version=$1

  luarocks_uri='https://github.com/keplerproject/luarocks/tarball/master'

  if [[ $version == "HEAD" ]]
  then
    luarocks_uri='https://github.com/keplerproject/luarocks/tarball/master'
  fi
  
  if [[ ! "$2" ]]
  then
    echo "build_luarocks takes 4 arguments 1 given"
  fi
  local prefix=$2

  if [[ ! "$3" ]]
  then
    echo "build_luarocks takes 4 arguments 2 given"
  fi
  local sysconfdir=$3

  if [[ ! "$4" ]]
  then
    echo "build_luarocks takes 4 arguments 3 given"
  fi
  local with_lua=$4


  if [[ ! -e './build/luarocks.tar.gz' ]]
  then
    wget $luarocks_uri -O './build/luarocks.tar.gz'
  fi

  tar -xvpf './build/luarocks.tar.gz' -C './build'

  OUT=`ls ./build | grep kepler`
  mv "./build/$OUT" './build/luarocks'

  pushd './build/luarocks'
  ./configure --prefix=$prefix --sysconfdir=$sysconfdir --force-config --with-lua=$with_lua
  make && make install
  popd
}


build_lua 5.1.5 linux "$CURRENT_DIR/.vert"
build_luarocks "HEAD" "$CURRENT_DIR/.vert" "$CURRENT_DIR/.luarocks" "$CURRENT_DIR/.vert"
