local M = {}

function M.startswith(s, prefix)
  assert(type(s) == "string")
  assert(type(prefix) == "string")
  return prefix == s:sub(1, #prefix)
end



function M.is_long_opt(s)
  return M.startswith(s, "--") and not s:find("=")
end

function M.is_long_assignment(s)
  return M.startswith(s, "--") and s:find("=")
end

function M.is_short_opt(s)
  return M.startswith(s, "-") and (#s == 2)
end




function M.get_long_opt(s)
  return s:sub(3, #s), true
end

function M.get_short_opt(s)
  return s:sub(2, #s), true
end

function M.get_long_assignment(s)
  local start, _end = s:find("=")
  return s:sub(3, start-1), s:sub(_end+1, #s)
end




function M.parse(...)
  local args = {...}
  local options = {}

  local order = 1

  local key, value
  for i, v in ipairs(args) do
    if M.is_long_opt(v) then
      key, value = M.get_long_opt(v)
      options[key] = value
    elseif M.is_long_assignment(v) then
      key, value = M.get_long_assignment(v)
      options[key] = value
    elseif M.is_short_opt(v) then
      key, value = M.get_short_opt(v)
      options[key] = value
    else
      options[order] = v
      order = order + 1
    end
  end

  return options
end

return M
