local media_status = require("media-controls.utils.media-status")
local nowplaying_cli = require("media-controls.utils.nowplaying-cli")

-- Only one timer should exist for each polling function.
IS_POLLING_STATUS = false
IS_POLLING_ELAPSED_PERCENTAGE = false

-- MEDIA INFO
-- The `MediaInfo` object is used to store information about the currently playing media.

local MediaInfo = {
  track = nil,
  artist = nil,
  elapsed_time = nil,
  duration = nil,
  -- We cache the `elapsed_percentage` of the currently playing media. This is updated every
  -- second as opposed to the longer refresh used for the track and artist information.
  elapsed_percentage = nil
}

-- We do not directly return the result of get_now_playing() as there is is an IO operation involved
-- and we want to avoid blocking the caller. We instead cache relevant values in `MediaInfo` using a
-- timer callback and return formatted values value via `status_cache()`.
MediaInfo.get_status_line = function()
  if MediaInfo.track == nil and MediaInfo.artist == nil then
    return media_status.STATUS_DEFAULT
  end

  if not MediaInfo.track and not MediaInfo.artist then
    return media_status.STATUS_NO_MEDIA
  end

  if not MediaInfo.artist then
    return "󰋋 " .. MediaInfo.track
  end

  return "󰋋 " .. MediaInfo.track .. " - " .. MediaInfo.artist
end

-- PLUGIN
-- This is the`media-controls` plugin module.

local M = {}

function M.setup(opts)
  opts = opts or {}
end

-- Begin an interval to poll the now playing status. If this is not run, the result
-- of `MediaInfo.get_status_line()` will always be `media_status.STATUS_DEFAULT`.
function M.status_poll()
  if IS_POLLING_STATUS then
    return
  end

  local timer = vim.loop.new_timer()
  timer:start(
    1000,
    10000,
    vim.schedule_wrap(function()
      MediaInfo.track = nowplaying_cli.get_title()
      MediaInfo.artist = nowplaying_cli.get_artist()
    end)
  )

  IS_POLLING_STATUS = true
end

-- Begin an interval to poll the elapsed elapsed_percentage of the currently playing media.
function M.elapsed_percentage_poll()
  if IS_POLLING_ELAPSED_PERCENTAGE then
    return
  end

  local timer = vim.loop.new_timer()
  timer:start(
    1000,
    1000,
    vim.schedule_wrap(function()
      local status_line = MediaInfo.get_status_line()

      if not status_line or status_line == media_status.STATUS_NO_MEDIA then
        MediaInfo.elapsed_time = nil
        MediaInfo.duration = nil
        MediaInfo.elapsed_percentage = nil
        return
      end

      MediaInfo.elapsed_time = nowplaying_cli.get_elapsed_time()
      MediaInfo.duration = nowplaying_cli.get_duration()

      if MediaInfo.elapsed_time == nil or MediaInfo.duration == nil then
        return nil
      end

      local elapsed_percentage = math.floor((MediaInfo.elapsed_time / MediaInfo.duration) * 100)
      if elapsed_percentage > 100 then
        return nil
      end

      -- There is a performance hit to calling `nowplaying_cli` every second, so we only
      -- attempt to retrieve updated media info if the elapsed elapsed_percentage has reset.
      if MediaInfo.elapsed_percentage and (elapsed_percentage or 0) < MediaInfo.elapsed_percentage then
        MediaInfo.track = nowplaying_cli.get_title()
        MediaInfo.artist = nowplaying_cli.get_artist()
      end

      MediaInfo.elapsed_percentage = elapsed_percentage
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
  -- format from media-info
  local media_info_status_line = ""
  if MediaInfo.track and MediaInfo.artist then
    media_info_status_line = MediaInfo.track .. " - " .. MediaInfo.artist
  end

  return MediaInfo.get_status_line()
end

-- Retrieve cached status line + elapsed elapsed_percentage.
function M.playback_cache()
  -- format from media-info
  local media_info_playback_line = ""
  if MediaInfo.elapsed_time and MediaInfo.duration then
    media_info_playback_line = MediaInfo.elapsed_time .. " / " .. MediaInfo.duration
  end
  print(media_info_playback_line)

  local status_line = MediaInfo.get_status_line()
  local elapsed_percentage = MediaInfo.elapsed_percentage

  if elapsed_percentage == nil then
    return status_line
  end

  return status_line .. "  " .. elapsed_percentage .. "󰏰"
end

--Retrieve the current media status using `nowplaying-cli`.
function M.status_print()
  local status_line = MediaInfo.get_status_line()
  print(status_line)
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
