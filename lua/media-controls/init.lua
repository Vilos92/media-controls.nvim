local media_status = require("media-controls.utils.media-status")
local nowplaying_cli = require("media-controls.utils.nowplaying-cli")

local M = {}

function M.setup(opts)
  opts = opts or {}

  -- We do not directly return the result of get_now_playing() as there is
  -- is an IO operation involved and we want to avoid blocking the caller.
  -- We instead cache the value in `STATUS_LINE` using a timer callback
  -- and return this cached value via `status_listen()`.
  STATUS_LINE = media_status.STATUS_DEFAULT
end

-- Begin an interval to poll the now playing status. If this is not run,
-- the `STATUS_LINE` will always be `STATUS_DEFAULT`.
function M.status_poll()
  local timer = vim.loop.new_timer()
  timer:start(
    1000,
    10000,
    vim.schedule_wrap(function()
      STATUS_LINE = nowplaying_cli.get_now_playing() or media_status.STATUS_NO_MEDIA
    end)
  )
end

-- Retrieve cached status line.
function M.status_cache()
  return STATUS_LINE or media_status.STATUS_DEFAULT
end

--Retrieve the current media status using `nowplaying-cli`.
function M.status_fetch()
  STATUS_LINE = nowplaying_cli.get_now_playing() or media_status.STATUS_NO_MEDIA
  print(STATUS_LINE)
end

function M.play()
  nowplaying_cli.play()
end

function M.pause()
  nowplaying_cli.pause()
end

function M.toggle()
  nowplaying_cli.toggle()
end

function M.next()
  nowplaying_cli.next()
end

function M.previous()
  nowplaying_cli.previous()
end

return M
