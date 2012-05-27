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
end

build_lua(BUILD_DIR.."lua-"..LUA_VERSION)
build_luarocks(BUILD_DIR.."luarocks-"..LUAROCKS_VERSION)

print("ok")
