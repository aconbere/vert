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

function M.get_os()
  local os_name = 'unknown'
        -- is popen supported?
        local popen_status, popen_result = pcall(io.popen, "")
        if popen_status then
                popen_result:close()
                -- Unix-based OS
                raw_os_name = io.popen('uname -s','r'):read('*l')
        else
                -- windows
                local env_OS = os.getenv('OS')
                if env_OS then
                        raw_os_name= env_OS
                end
        end

        os_name = (raw_os_name):lower()

        local os_patterns = {
                ['windows'] = 'windows',
                ['linux'] = 'linux',
                ['mac'] = 'macosx',
                ['darwin'] = 'macosx',
                ['^mingw'] = 'windows',
                ['^cygwin'] = 'windows',
                ['bsd$'] = 'bsd',
                ['SunOS'] = 'solaris',
        }

        for pattern, name in pairs(os_patterns) do
                if os_name:match(pattern) then
                        os_name = name
                        break
                end
        end
        return os_name
end
return M
