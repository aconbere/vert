#!/usr/bin/env lua

local utils       = require("utils")
local lfs         = require("lfs")
local Installable = require("installable")
local activate    = require("vert_activate")

local installers = {}

installers.luajit = Installable.new({
  uri = "http://luajit.org/download/",
  remote_filename = "LuaJIT-%s.tar.gz",
  make_tasks = {
    { "make %s prefix=%s","platform", "prefix" },
    { "make install prefix=%s", "prefix" }
  }
})

installers.lua = Installable.new({
  uri = "http://www.lua.org/ftp/",
  remote_filename = "lua-%s.tar.gz",
  local_filename = "lua-%s",
  make_tasks = {
    { "make %s", "platform" },
    { "make install INSTALL_TOP=%s", "prefix" }
  }
})

installers.luarocks = Installable.new({
  uri = "http://luarocks.org/releases/",
  remote_filename = "luarocks-%s.tar.gz",
  local_filename = "luarocks-%s",
  make_tasks = {
    { "./configure --prefix=%s --sysconfdir=%s --force-config --with-lua=%s", "prefix", "prefix", "prefix" },
    { "make" },
    { "make install" }
  }
})

_M = {}
_M.installers = installers

function _M.do_init(opts)
  local prefix             = utils.expanddir(opts[2])
  local lua_version        = opts["lua-version"]        or "5.1.5"
  local lua_implimentation = opts["lua-implimentation"] or "lua"
  local luarocks_version   = opts["luarocks-version"]   or "2.0.8"
  local platform           = opts["platform"]           or "linux"
  local build_dir          = prefix.."/build/"
  local cache_dir          = utils.expanddir("~/.verts_cache")
  local debug              = opts["debug"]

  if debug then
    print("Directory "..prefix)
    print("Lua version: "..lua_version)
    print("Lua implimentation: "..lua_implimentation)
    print("LuaRocks version: "..luarocks_version)
    print("Lua platform: "..platform)
  end

  if not installers[lua_implimentation] then
    print("invalid implimentation choice")
    os.exit(1)
  end

  if not utils.isdir(prefix) then
    lfs.mkdir(prefix)
  end

  if not utils.isdir(build_dir) then
    lfs.mkdir(build_dir)
  end

  print("installing ".. lua_implimentation.." version: "..lua_version)

  installers[lua_implimentation]:install({ build_dir = build_dir
                                         , version   = lua_version
                                         , platform  = platform
                                         , prefix    = prefix
                                         })

  installers.luarocks:install({ build_dir = build_dir
                              , version   = luarocks_version
                              , prefix    = prefix
                              })

  write_activate_script(activate_template, lua_version:sub(1,3), prefix)

  print("ok")
end

function _M.run(opts)
  local help =
[[
usage: vert init [--luarocks-version[ [--lua-version]
                 [--lua-implimentation] [--platform]
                 <directory>

  --luarocks-version : luarocks version to install
  --lua-version : lua version to compile
  --lua-implimentation : lua implimentation to compile [lua | luajit]
  --platform : platform to compile to default is "linux"
]]

  local prefix = opts[2]

  if (not prefix) or (#prefix == 0) then
    print(help)
    os.exit(1)
  end
end

return _M
