# VERT: A virtual environment for lua.

Produces a localized install of lua and luarocks for isolated installation and
running of lua programs.

## Installing Vert

    $> luarocks install vert

This will install the `vert` command and add a file `vert_wrapper` to your path
`vert` is the main way you'll interface with virtual environments. By sourcing
`vert_wrapper` in your shells initialization script (bashrc, zshrc, etc,) your
shell will be embued with the very helpful `verton` function. This will enable
you to keep a collection of environments in a single directory to turn on or
off as you please.

## Creating an environment

To run vert just run `vert init` with the path to the directory to install into

    $> vert init .
    $> source ./bin/activate (vert)
    $> lua
    Lua 5.1.5  Copyright (C) 1994-2012 Lua.org, PUC-Rio

You can configure which lua and luarocks version to use with with the config
flags `--lua-version` and `--luarocks-version`

    $> vert --lua-version=5.2.0
    $> source ./bin/activate
    (vert) $> lua
    Lua 5.2.0  Copyright (C) 1994-2011 Lua.org, PUC-Rio

## Activating an environment

There isn't really any magic in Vert, and getting running in a virtual
environment using is a manual though simple process. After you build a virtual
env using vert, a shell script will be created in ./bin/activate of that vert.
To activate the vert execute:

    $> source ./bin/activate

All this script does is copy the current environment variables that setup your
paths (`PATH`, `LUA_CPATH`, `LUA_PATH` and `PS1`) and reassigning them to point
to the particular virtual env you're working on.

Once an environment is activate simple run `deactivate` to exit

    (vert)$> deactivate

Alternatively in your bashrc or zshrc you can source the `vert_wrappers.sh`
installed, it will provide a function `verton` that will activate verts found
in `~/.verts`

## Commands

## Subcommands

### vert init

`vert init` will build a vert in a given directory

    $> vert init /my/env

### vert make

`vert make` will build a new vert in your ~/.verts directory

    $> vert make my_env

### verton

`verton` is a shell function available if you source
`/usr/bin/env/vert_wrapper.sh` it will activate a vert found in ~/.verts

    $> verton my_env

### vert rm

`vert rm` will remove a vert in ~/.verts

    $> vert rm my_env

### vert ls

`vert ls` will list all your verts in ~/.verts

    $> vert ls my_env

## Platform Support

Currently I've only tested this on linux, though given lua's support for many
platforms I don't see this approaching being difficult on most Unixes"
