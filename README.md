= VERT: A virtual environment for lua.

Produces a localized install of lua and luarocks for isolated installation and
running of lua programs.

== Command [vert]

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

