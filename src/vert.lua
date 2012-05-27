#!/usr/bin/env lua

local io      = require("io")
local lfs     = require("lfs")
local http    = require("socket.http")
local ltn12   = require("ltn12")
local optimal = require("optimal")

local opts = optimal.parse(...)

local help = [[usage: vert [--luarocks-version[ [--lua-version] <directory>

--luarocks-version : luarocks version to install
--lua-version : lua version to compile
]]

local activate_template = [[
# This file must be used with "source bin/activate" *from bash*
# you cannot run it directly

deactivate () {
    # reset old environment variables
    if [ -n "$_OLD_VERT_PATH" ] ; then
        PATH="$_OLD_VERT_PATH"
        export PATH
        unset _OLD_VERT_PATH
    fi

    if [ -n "$_OLD_VERT_LUA_PATH" ] ; then
        LUA_PATH="$_OLD_VERT_LUA_PATH"
        export LUA_PATH
        unset _OLD_VERT_LUA_PATH
    fi

    if [ -n "$_OLD_VERT_LUA_CPATH" ] ; then
        LUA_CPATH="$_OLD_VERT_LUA_CPATH"
        export LUA_CPATH
        unset _OLD_VERT_LUA_CPATH
    fi

    # This should detect bash and zsh, which have a hash command that must
    # be called to get it to forget past commands.  Without forgetting
    # past commands the $PATH changes we made may not be respected
    if [ -n "$BASH" -o -n "$ZSH_VERSION" ] ; then
        hash -r
    fi

    if [ -n "$_OLD_VERT_PS1" ] ; then
        PS1="$_OLD_VERT_PS1"
        export PS1
        unset _OLD_VERT_PS1
    fi

    unset VERT_ENV
    if [ ! "$1" = "nondestructive" ] ; then
    # Self destruct!
        unset -f deactivate
    fi
}

# unset irrelavent variables
deactivate nondestructive

LUA_VERSION="%s"
export LUA_VERSION
VERT_ENV="%s"
export VERT_ENV

_OLD_VERT_PATH="$PATH"
PATH="$VERT_ENV/bin:$PATH"
export PATH

# unset LUA_PATH if set
# this will fail if LUA_PATH is set to the empty string (which is bad anyway)
# could use `if (set -u; : $LUA_PATH) ;` in bash
if [ -n "$LUA_PATH" ] ; then
    _OLD_VERT_LUA_PATH="$LUA_PATH"
    unset LUA_PATH
fi

if [ -n "$LUA_CPATH" ] ; then
    _OLD_VERT_LUA_CPATH="$LUA_CPATH"
    unset LUA_CPATH
fi

LUA_PATH="$VERT_ENV/share/lua/$LUA_VERSION//?.lua;/$VERT_ENV/lib/luarocks/?.lua"
export LUA_PATH

LUA_CPATH="$VERT_ENV/share/lua/$LUA_VERSION//?.lua;/$VERT_ENV/lib/luarocks/?.lua"
export LUA_CPATH

if [ -z "$VERT_ENV_DISABLE_PROMPT" ] ; then
    _OLD_VERT_PS1="$PS1"
    if [ "x" != x ] ; then
	PS1="$PS1"
    else
    if [ "`basename \"$VERT_ENV\"`" = "__" ] ; then
        # special case for Aspen magic directories
        # see http://www.zetadev.com/software/aspen/
        PS1="[`basename \`dirname \"$VERT_ENV\"\``] $PS1"
    else
        PS1="(`basename \"$VERT_ENV\"`)$PS1"
    fi
    fi
    export PS1
fi

# This should detect bash and zsh, which have a hash command that must
# be called to get it to forget past commands.  Without forgetting
# past commands the $PATH changes we made may not be respected
if [ -n "$BASH" -o -n "$ZSH_VERSION" ] ; then
    hash -r
fi
]]


local M = {}

function M.expanddir(directory)
  if directory then
    if directory:sub(1,1) == "~" then
      return os.getenv("HOME")..directory:sub(2, #directory)
    elseif directory == "." then
      return lfs.currentdir()
    elseif directory == ".." then
      return lfs.currentdir().."../"
    elseif directory:sub(1,2) == "./" then
      return lfs.currentdir()..directory:sub(3, #directory)
    else
      return lfs.currentdir().."/"..directory
    end
  end
end

function M.download(url, filename)
  return http.request({ url = url
                      , method = "GET"
                      , sink = ltn12.sink.file(io.open(filename, "w"))
                      })
end

local DIRECTORY = M.expanddir(opts[1])

if not DIRECTORY then
  print(help)
  return false
end

local _dir_attrs = lfs.attributes(DIRECTORY)
if (not _dir_attrs) or _dir_attrs["mode"] ~= "directory" then
  lfs.mkdir(DIRECTORY)
end

local LUAROCKS_VERSION  = opts["luarocks-version"] or "2.0.8"
local LUA_VERSION       = opts["lua-version"] or "5.1"
local LUAROCKS_URI      = "http://luarocks.org/releases/"
local LUA_URI           = "http://www.lua.org/ftp/"
local LUA_FILENAME      = "lua-"..LUA_VERSION..".tar.gz"
local LUAROCKS_FILENAME = "luarocks-"..LUAROCKS_VERSION..".tar.gz"
local BUILD_DIR         = DIRECTORY.."/build/"
local PLATFORM          = "linux"
local CURRENT_DIR       = lfs.currentdir()

if not lfs.attributes(BUILD_DIR) then
  lfs.mkdir(BUILD_DIR)
end

if not lfs.attributes(BUILD_DIR..LUA_FILENAME) then
  _, status, _headers = M.download(LUA_URI..LUA_FILENAME, BUILD_DIR..LUA_FILENAME)
  if status ~= 200 then
    print("Failed to download lua version: "..LUA_VERSION)
    os.exit(2)
  end
end

if not lfs.attributes(BUILD_DIR..LUAROCKS_FILENAME) then
  _, status, _headers = M.download(LUAROCKS_URI..LUAROCKS_FILENAME, BUILD_DIR..LUAROCKS_FILENAME)
  if status ~= 200 then
    print("Failed to download luarocks version: "..LUAROCKS_VERSION)
    os.exit(2)
  end
end

function ensure(f, err)
  if not f then
    print(err)
    os.exit()
  end
end

function run(command, ...)
  local to_run = string.format(command, ...)

  print("EXECUTING:", to_run)

  return os.execute(to_run)
end


run("tar -xvpf %s -C %s", BUILD_DIR..LUA_FILENAME, BUILD_DIR)
run("tar -xvpf %s -C %s", BUILD_DIR..LUAROCKS_FILENAME, BUILD_DIR)

function build_lua(dir)
  lfs.chdir(dir)

  ensure(run("make %s", PLATFORM),
         "make lua failed")
  ensure(run("make install INSTALL_TOP=%s", DIRECTORY),
         "install lua failed")
  lfs.chdir(CURRENT_DIR)
end

function build_luarocks(dir)
  lfs.chdir(dir)
  ensure(run("./configure --prefix=%s --sysconfdir=%s --force-config --with-lua=%s",
             DIRECTORY, DIRECTORY, DIRECTORY),
             "configure luarocks failed")
  ensure(run("make"),
         "make luarocks failed")
  ensure(run("make install"),
         "install luarocks failed")
  lfs.chdir(CURRENT_DIR)
end

function write_activate_script(lua_version, vert_path)
  local activate_file, err = io.open(DIRECTORY.."/bin/activate", "w+")
  if not activate_file then
    print("Failed to open activate file: "..err)
    os.exit(3)
  end

  activate_file:write(string.format(activate_template, lua_version, vert_path))
  activate_file:close()
end

build_lua(BUILD_DIR.."lua-"..LUA_VERSION)
build_luarocks(BUILD_DIR.."luarocks-"..LUAROCKS_VERSION)

write_activate_script(LUA_VERSION, DIRECTORY)

print("ok")
