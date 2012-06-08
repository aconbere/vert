#!/usr/bin/env lua

local lfs     = require("lfs")
local utils   = require("utils")

local M = {}

function M.rmdir(dir, args)
  assert(dir, "dir cannot be nil")
  assert(utils.isdir(dir), "dir is not a directory")

  local force = args and args["force"]

  if not force then
    return lfs.rmdir(dir)
  end

  if dir:sub(#dir, #dir) ~= "/" then
    dir = dir.."/"
  end

  for name in lfs.dir(dir) do
    if (name ~= ".") and (name ~= "..") then
      local path = dir..name
      local attrs = lfs.attributes(dir..name)
      if attrs["mode"] == "directory" then
        local _, err = M.rmdir(path, args)
        if err then
          return nil, err
        end
      else
        local _, err = os.remove(path)
        if err then
          return nil, err
        end
      end
    end
  end

  return lfs.rmdir(dir)
end

function M.remove(opts)

  local help = [[usage: vert rm <name>]]

  local vert_name = opts[2]

  if not vert_name then
    print(help)
    os.exit(1)
  end

  local vert_dir = utils.expanddir("~/.verts/")..vert_name
  print(vert_dir)

  if not(utils.isdir(vert_dir)) then
    print("vert '"..vert_name.."' doesn't exist")
    os.exit(1)
  end

  local _, err = M.rmdir(vert_dir, { force = true })
  if err then
    print("ERROR: "..err)
    os.exit(1)
  end

  print("ok")
end

return M.remove
