#!/usr/bin/env lua

local M = {}

function M.make(opts)
  local lfs   = require("lfs")
  local utils = require("utils")
  local init  = require("vert_initialize")

  local help = [=[usage: vert make <name> [--lua-version] [--luarocks--version]]=]

  local vert_name = opts[2]

  if not vert_name then
    print(help)
    os.exit(1)
  end

  local verts_dir = utils.expanddir("~/.verts")
  if not utils.isdir(verts_dir) then
    lfs.mkdir(verts_dir)
  end

  local vert_dir = verts_dir.."/"..vert_name

  init({ ["lua-version"]      = opts["lua-version"]
       , ["luarocks-version"] = opts["luarocks-version"]
       , [2]                  = vert_dir
       })

  print("ok")
end

return M.make
