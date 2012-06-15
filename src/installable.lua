local class = require("class")
local utils = require("utils")
local lfs   = require("lfs")
local Cache = require("cache")

local Installable = class()

function Installable:init(args)
  self._uri             = args.uri
  self._remote_filename = args.remote_filename
  self._local_filename  = args.local_filename
  self._make_tasks      = args.make_tasks

  assert(self._remote_filename, "Installable: remote filename required")

  self.cache            = Cache.new("~/.verts_cache")
end

function Installable:remote_filename(version)
  return string.format(self._remote_filename, version)
end

function Installable:local_pathname(build_dir, version)
  return string.format(build_dir.."/"..self._local_filename, version)
end

function Installable:download(build_dir, version)
  self.cache:get_or_download(self:remote_filename(version), self._uri)
end

function Installable:untar(build_dir, version)
  local pathname = self.cache.cache_dir.."/"..self:remote_filename(version)
  utils.ensure(utils.run("tar -xvpf %s -C %s", pathname, build_dir))
end

local function mget(table, keys)
  local new_table = {}
  for i, k in ipairs(keys) do
    new_table[i] = table[k]
  end
  return new_table
end

function Installable:run_task(task, args)
  local task = task
  local command = table.remove(task, 1)
  local slice = mget(args, task)

  utils.ensure(utils.run(command, unpack(slice)))
end

function Installable:install(args)
  local current_dir = lfs.currentdir()

  self:download(args.build_dir, args.version)
  self:untar(args.build_dir, args.version)

  lfs.chdir(self:local_pathname(args.build_dir, args.version))

  if self._make_tasks then
    for i, task in ipairs(self._make_tasks) do
      self:run_task(task, args)
    end
  end

  lfs.chdir(current_dir)
end

return Installable
