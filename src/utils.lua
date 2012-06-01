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

function M.build_lua(lua_dir, platform, top)
  local current_dir = lfs.currentdir()
  lfs.chdir(lua_dir)

  M.ensure(M.run("make %s", platform), "make lua failed")
  M.ensure(M.run("make install INSTALL_TOP=%s", top),
         "install lua failed")
  lfs.chdir(current_dir)
end

function M.build_luarocks(luarocks_dir, prefix)
  local current_dir = lfs.currentdir()
  lfs.chdir(luarocks_dir)
  M.ensure(M.run("./configure --prefix=%s --sysconfdir=%s --force-config --with-lua=%s",
             prefix, prefix, prefix),
             "configure luarocks failed")
  M.ensure(M.run("make"),
         "make luarocks failed")
  M.ensure(M.run("make install"),
         "install luarocks failed")
  lfs.chdir(current_dir)
end

function M.write_activate_script(template, lua_version, prefix)
  local activate_file, err = io.open(prefix.."/bin/activate", "w+")

  if not activate_file then
    print("Failed to open activate file: "..err)
    os.exit(3)
  end

  activate_file:write(string.format(template, lua_version, prefix))
  activate_file:close()
end

return M
