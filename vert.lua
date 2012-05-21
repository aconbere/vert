local luarocks_uri = string.format("https://github.com/keplerproject/luarocks/tarball/master")
local working_dir  = "/home/aconbere/Projects/lua/vert"
local build_dir    = string.format("%s/%s", working_dir, "build")
local luarocks_dir = string.format("%s/luarocks", build_dir)


function run(command, ...)
  local to_run = string.format(command, ...)

  print("EXECUTING:", to_run)

  return os.execute(to_run)
end

run("mkdir %s", build_dir)
run("wget %s -O %s/%s", luarocks_uri, build_dir, "luarocks.tar.gz")
run("tar -xvpf %s/%s -C %s", build_dir, "luarocks.tar.gz", build_dir)
run("cd %s; ./configure --prefix=%s --sysconfdir=%s --force-config --with-lua=/usr/local", luarocks_dir, working_dir, luarocks_dir)
run("cd %s; make && make install", luarocks_dir)
