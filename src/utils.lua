local lfs   = require("lfs")
local io    = require("io")

local M = {}

function M.ensure(f, err)
  if not f then
    print(err)
    os.exit(1)
  end
end

function M.run(command, ...)
  local to_run = string.format(command, ...)

  print("EXECUTING:", to_run)

  return os.execute(to_run)
end

function M.isdir(dir)
  local dir_attrs = lfs.attributes(dir)
  return dir_attrs and (dir_attrs["mode"] == "directory")
end

function M.expanddir(directory)
  assert(directory, "directory is required")
  if directory:sub(1,1) == "~" then
    return os.getenv("HOME")..directory:sub(2, #directory)
  elseif directory == "." then
    return lfs.currentdir()
  elseif directory == ".." then
    return lfs.currentdir().."../"
  elseif directory:sub(1,2) == "./" then
    return lfs.currentdir()..directory:sub(3, #directory)
  elseif directory:sub(1,1) == "/" then
    return directory
  else
    return lfs.currentdir().."/"..directory
  end
end

return M
