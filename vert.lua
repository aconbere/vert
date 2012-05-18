local LUAROCKS_VERSION = "2.0.8"
local luarocks_filename = string.format("luarocks-%s.tar.gz", LUAROCKS_VERSION)
local luarocks_uri = string.format("http://luarocks.org/releases/%s", luarocks_filename)

local working_dir = "/home/aconbere/Projects/lua/vert"
local build_dir = string.format("%s/%s", working_dir, "build")

local luarocks_dir = string.format("%s/%s", build_dir, luarocks_filename)


os.execute(string.format("mkdir %s", build_dir))
os.execute(string.format("wget %s %s -p %s", luarocks_uri, luarocks_filename, build_dir))
os.execute(string.format("tar -xvpf %s/%s", build_dir, luarocks_filename))

os.execute(string.format("cd %s; ./configure --prefix=%s --sysconfdir=%s --force-config", luarocks_dir, working_dir, luarocks_dir))
os.execute(string.format("cd %s; make && make install", luarocks_dir))
