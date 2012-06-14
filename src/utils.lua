local http  = require("socket.http")
local ltn12 = require("ltn12")
local lfs   = require("lfs")
local io    = require("io")

local M = {}

function M.ensure(f, err)
  if not f then
    print(err)
    os.exit()
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
  if directory then
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
end

function M.download(url, filename)
  return http.request({ url = url
                      , method = "GET"
                      , sink = ltn12.sink.file(io.open(filename, "w"))
                      })
end


return M
