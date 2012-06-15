local utils = require("utils")
local class = require("class")
local lfs   = require("lfs")

local Cache = class()

function Cache:init(cache_dir)
  assert(cache_dir, "cache_dir is required")
  assert(type(cache_dir) == "string", "cache_dir must be a string")


  self.cache_dir = utils.expanddir(cache_dir)
  if not utils.isdir(self.cache_dir) then
    lfs.mkdir(self.cache_dir)
  end
end

function Cache:exists(name)
  return lfs.attributes(self:path(name))
end

function Cache:path(name)
  return self.cache_dir.."/"..name
end

function Cache:try(name, callback)
  assert(name, "name is required")
  assert(callback, "callback is required")

  if not self:exists(name) then
    callback(name)
  end
end

function Cache:download()
  return http.request({ url = url
                      , method = "GET"
                      , sink = ltn12.sink.file(io.open(filename, "w"))
                      })
end

function Cache:get_or_download(filename, uri)
  assert(filename, "filename is required")
  assert(uri, "uri is required")

  self:try(filename, function (name)
    local remote_path = uri..filename
    local _, status, _headers = utils.download(remote_path, self:path(name))
    assert(status == 200, "Failed to download: "..filename)
  end)
end

return Cache
