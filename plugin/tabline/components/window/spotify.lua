local wez = require('wezterm')
local util = require('tabline.util')

local last_update = 0
local stored_playback = ''

---format spotify playback, to handle max_width nicely
---@param pb string
---@param max_width number
---@return string
local format_playback = function(pb, max_width)
  if #pb <= max_width then
    return pb
  end

  if #pb <= max_width then
    return pb
  end

  -- fallback, return with ... trimmed to max width
  return pb:sub(1, max_width - 3) .. '...'
end

---gets the currently playing song from spotify
---@param max_width number
---@param throttle number
---@return string
local get_currently_playing = function(max_width, throttle)
  if util._wait(throttle, last_update) then
    return stored_playback
  end
  -- fetch playback using spotify-tui
  local success, pb, stderr = wez.run_child_process { 'spt_pb' }
  if not success then
    wez.log_error(stderr)
    return ''
  end
  local res = format_playback(util._trim(pb), max_width)
  stored_playback = res
  last_update = os.time()

  return res
end

return {
  default_opts = {
    throttle = 10,
    icon = wez.nerdfonts.fa_spotify,
    max_width = 64,
  },
  update = function(_, opts)
    return get_currently_playing(opts.max_width, opts.throttle)
  end,
}
