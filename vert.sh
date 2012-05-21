#!/usr/bin/env bash

CURRENT_DIR=`pwd`
LUAROCKS_URI='https://github.com/keplerproject/luarocks/tarball/master'
LUAROCKS_DIR='./build/luarocks'

if [[ ! -e './build' ]]
then
  mkdir './build'
fi

if [[ ! -e './.vert' ]]
then
  mkdir './.vert'
fi

if [[ ! -e './build/luarocks.tar.gz' ]]
then
  wget $LUAROCKS_URI -O './build/luarocks.tar.gz'
fi

tar -xvpf './build/luarocks.tar.gz' -C './build'

OUT=`ls ./build | grep kepler`
mv "./build/$OUT" $LUAROCKS_DIR

pushd $LUAROCKS_DIR
echo `pwd`
./configure --prefix="$CURRENT_DIR/.vert" --sysconfdir="$CURRENT_DIR/.luarocks" --force-config --with-lua=/usr/local
make && make install

