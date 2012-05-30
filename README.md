# VERT: A virtual environment for lua.

Produces a localized install of lua and luarocks for isolated installation and
running of lua programs.

## Command [vert]

To run vert just run `vert` with the path to the directory to install into

    $> vert .
    $> source ./bin/activate
    (vert) $> lua
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

## Platform Support

Currently I've only tested this on linux, though given lua's support for many
platforms I don't see this approaching being difficult on most Unixes"
