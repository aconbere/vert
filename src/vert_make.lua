#!/usr/bin/env lua

local _M = {}

function _M.run(opts)
  local lfs   = require("lfs")
  local utils = require("utils")
  local init = require("vert_initialize")

  local help = [=[
usage: vert make [--lua-version] [--luarocks--version] [--lua-implimentation]
                 [--platform] <name>
]=]

  local vert_name = opts[2]

  if not vert_name then
    print(help)
    os.exit(1)
  end

  local verts_dir = utils.expanddir("~/.verts")
  if not utils.isdir(verts_dir) then
    lfs.mkdir(verts_dir)
  end

  opts[2] = verts_dir.."/"..vert_name

  init.do_init(opts)

  print("ok")
end

return _M
