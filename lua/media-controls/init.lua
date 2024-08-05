local media_status = require("media-controls.utils.media-status")

-- We do not directly return the result of get_now_playing() as there is is an IO operation involved
-- and we want to avoid blocking the caller. We instead cache the value in `STATUS_LINE` using a
-- timer callback and return this cached value via `status_listen()`.
STATUS_LINE = media_status.STATUS_DEFAULT

-- Similar to the status line, we cache the elapsed percentage of the currently playing media. This is
-- updated every second as opposed to the longer refresh used for the track and artist information.
ELAPSED_PERCENTAGE = nil

-- Only one timer should exist for each polling function.
IS_POLLING_STATUS = false
IS_POLLING_ELAPSED_PERCENTAGE = false

local nowplaying_cli = require("media-controls.utils.nowplaying-cli")

local M = {}

function M.setup(opts)
  opts = opts or {}
end

-- Begin an interval to poll the now playing status. If this is not run,
-- the `STATUS_LINE` will always be `STATUS_DEFAULT`.
function M.status_poll()
  if IS_POLLING_STATUS then
    return
  end

  local timer = vim.loop.new_timer()
  timer:start(
    1000,
    10000,
    vim.schedule_wrap(function()
      STATUS_LINE = nowplaying_cli.get_now_playing() or media_status.STATUS_NO_MEDIA
    end)
  )

  IS_POLLING_STATUS = true
end

-- Begin an interval to poll the elapsed percentage of the currently playing media.
function M.elapsed_percentage_poll()
  if IS_POLLING_ELAPSED_PERCENTAGE then
    return
  end

  local timer = vim.loop.new_timer()
  timer:start(
    1000,
    1000,
    vim.schedule_wrap(function()
      if not STATUS_LINE or STATUS_LINE == media_status.STATUS_NO_MEDIA then
        ELAPSED_PERCENTAGE = nil
        return
      end

      local new_elapsed_percentage = nowplaying_cli.get_elapsed_percentage()

      -- There is a performance hit to calling `get_now_playing()` every second, so we only
      -- attempt to retrieve an updated status line if the elapsed percentage has reset.
      if ELAPSED_PERCENTAGE and (new_elapsed_percentage or 0) < ELAPSED_PERCENTAGE then
        STATUS_LINE = nowplaying_cli.get_now_playing() or media_status.STATUS_NO_MEDIA
      end

      ELAPSED_PERCENTAGE = new_elapsed_percentage
    end)
  )

  IS_POLLING_ELAPSED_PERCENTAGE = true
end

function M.poll()
  M.status_poll()
  M.elapsed_percentage_poll()
end

-- Retrieve cached status line.
function M.status_cache()
  return STATUS_LINE or media_status.STATUS_DEFAULT
end

-- Retrieve cached status line + elapsed percentage.
function M.playback_cache()
  local status_line = STATUS_LINE or media_status.STATUS_DEFAULT
  local elapsed_percentage = ELAPSED_PERCENTAGE

  if elapsed_percentage == nil then
    return status_line
  end

  return status_line .. "  " .. elapsed_percentage .. "󰏰"
end

--Retrieve the current media status using `nowplaying-cli`.
function M.status_print()
  STATUS_LINE = nowplaying_cli.get_now_playing() or media_status.STATUS_NO_MEDIA
  print(STATUS_LINE)
end

function M.elapsed_percentage_print()
  local elapsed_percentage = nowplaying_cli.get_elapsed_percentage()
  if elapsed_percentage == nil then
    print("󰏰 unavailable")
    return
  end

  print(elapsed_percentage .. "󰏰")
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
