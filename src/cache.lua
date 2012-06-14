local utils = require("utils")

local C = {}

function C.get_or_download(filename, uri)
  local pathname = cache_dir..filename
  if not lfs.attributes(pathname) then
    local _, status, _headers = utils.download(uri, pathname)
    assert(stats == 200, "Failed to download: "..filename)
  end
end

return C
