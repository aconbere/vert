#!/usr/bin/env lua

local M = {}

function M.rm(opts)
  local lfs     = require("lfs")
  local utils   = require("utils")

  local help = [[usage: vert rm <name>]]
  
  local vert_name = opts[2]

  if not vert_name then
    print(help)
    os.exit(1)
  end

  local vert_dir = utils.expanddir("~/.verts/")..vert_name

  if not(utils.isdir(vert_dir)) then
    print("vert '"..vert_name.."' doesn't exist")
    os.exit(1)
  end

  lfs.rmdir(vert_dir)

  print("ok")
end

return M.rm
