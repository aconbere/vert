local class = require("class")
local cache = require("cache")

local Installable = class()

function Installable:init(args)
  self._uri        = args.uri
  self._filename   = args.filename
  self._make_tasks = args.make_tasks
end

function Installable:filename(version)
  return string.format(self._filename, version)
end

function Installable:download()
  cache.get_or_download(self.build_dir..self.filename(version), self.uri)
end

function Installable:locals(t)
  local locals = {}
  for i,k in ipairs(t) do
    table.insert(locals, self[k])
  end
  return locals
end

function Installable:run_task(task)
  utils.ensure(utils.run(task.command, unpack(self.locals(task))))
end

function Installable:build()
  for i, task in ipairs(self.make_tasks) do
    self:run_task(task)
  end
end

function Installable:install()
end
