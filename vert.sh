#!/usr/bin/env bash

LUA_VERSION="5.1.5"
LUA_URL="http://www.lua.org/ftp/lua-$LUA_VERSION.tar.gz"

CURRENT_DIR=`pwd`
LUAROCKS_URI='https://github.com/keplerproject/luarocks/tarball/master'

if [[ ! -e './build' ]]
then
  mkdir './build'
fi

if [[ ! -e './.vert' ]]
then
  mkdir './.vert'
fi

if [[ ! -e "./build/lua-$LUA_VERSION.tar.gz" ]]
then
  wget $LUA_URL -O "./build/lua-$LUA_VERSION.tar.gz"
fi


tar -xvpf "./build/lua-$LUA_VERSION.tar.gz" -C ./build

OUT=`ls ./build | grep lua`
mv "./build/$OUT" './build/lua'
pushd './build/lua'
INSTALL_TOP="$CURRENT_DIR/.vert"
make local
popd

if [[ ! -e './build/luarocks.tar.gz' ]]
then
  wget $LUAROCKS_URI -O './build/luarocks.tar.gz'
fi

tar -xvpf './build/luarocks.tar.gz' -C './build'

OUT=`ls ./build | grep kepler`
mv "./build/$OUT" './build/luarocks'

pushd './build/luarocks'
./configure --prefix="$CURRENT_DIR/.vert" --sysconfdir="$CURRENT_DIR/.luarocks" --force-config --with-lua=/usr/local
make && make install
popd
