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
      return directory
    end
  end
end

function M.download(url, filename)
  http.request({ url = url
               , method = "GET"
               , sink = ltn12.sink.file(io.open(filename, "w"))
               })
end

local DIRECTORY = M.expanddir(opts[1])

if not DIRECTORY then
  print(help)
  return false
end

if lfs.attributes(DIRECTORY)["mode"] ~= "directory" then
  print("error: "..DIRECTORY.." is not a directory")
  return false
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
  M.download(LUA_URI..LUA_FILENAME, BUILD_DIR..LUA_FILENAME)
end

if not lfs.attributes(BUILD_DIR..LUAROCKS_FILENAME) then
  M.download(LUAROCKS_URI..LUAROCKS_FILENAME, BUILD_DIR..LUAROCKS_FILENAME)
end

function run(command, ...)
  local to_run = string.format(command, ...)

  print("EXECUTING:", to_run)

  return os.execute(to_run)
end

lfs.chdir(BUILD_DIR)
run("tar -xvpf %s", LUA_FILENAME)
run("tar -xvpf %s", LUAROCKS_FILENAME)

lfs.chdir("lua-"..LUA_VERSION)

run("make %s", PLATFORM)
run("make install INSTALL_TOP=%s", DIRECTORY)

--lfs.chdir(BUILD_DIR.."luarocks-"..LUAROCKS_VERSION)
--run("./configure --prefix=%s --sysconfdir=%s --force-config --with-lua%s")
--run("cd %s; ./configure --prefix=%s --sysconfdir=%s --force-config --with-lua=/usr/local", luarocks_dir, working_dir, luarocks_dir)
--run("cd %s; make && make install", luarocks_dir)
--
--function download(url, filename)
--end
