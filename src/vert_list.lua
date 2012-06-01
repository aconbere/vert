#!/usr/bin/env lua

local M = {}

function M.list_files(dir)
  local files = {}

  for filename in lfs.dir(dir) do
    if filename and (filename ~= ".") and (filename ~= "..") then
      f = dir..filename
      local attrs = lfs.attributes(f)
      if attrs["mode"] == "directory" then
        table.insert(files, filename)
      end
    end
  end

  return files
end

function M.list(opts)
  local lfs     = require("lfs")
  local utils   = require("utils")

  local help = [[usage: vert ls <name>]]

  local verts_dir = utils.expanddir("~/.verts/")

  local files = M.list_files(verts_dir)
  for i, f in pairs(files) do
    print(f)
  end
end

return M.list
