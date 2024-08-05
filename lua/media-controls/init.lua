local media_status = require("media-controls.utils.media-status")
local nowplaying_cli = require("media-controls.utils.nowplaying-cli")

-- MEDIA INFO
-- The `MediaInfo` object is used to store information about the currently playing media.

local MediaInfo = {
  track = nil,
  artist = nil,
  elapsed_time = nil,
  duration = nil,
  -- We store the previous `elapsed_percentage` to determine if a track has skipped or reset.
  -- This allows us to determine if it makes sense to refresh the track and artist information.
  elapsed_percentage = nil,
}

-- We do not directly return the results from `nowplaying-cli` as there is is an IO operation involved
-- and we want to avoid blocking the caller. We instead cache relevant values in `MediaInfo` using a
-- timer callback and return formatted values value via `get_status()`.
MediaInfo.get_status = function()
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

-- POLLS
-- Only one timer should exist for each polling function.
local Polls = {
  status_timer = vim.loop.new_timer(),
  elapsed_percentage_timer = vim.loop.new_timer(),
}

-- PLUGIN
-- This is the`media-controls` plugin module.

local M = {}

function M.setup(opts)
  opts = opts or {}
end

-- Begin an interval to poll the now playing status. If this is not run, the result
-- of `MediaInfo.get_status()` will always be `media_status.STATUS_DEFAULT`.
function M.poll_status()
  Polls.status_timer:stop()

  Polls.status_timer:start(
    1000,
    10000,
    vim.schedule_wrap(function()
      MediaInfo.track = nowplaying_cli.get_title()
      MediaInfo.artist = nowplaying_cli.get_artist()
    end)
  )
end

-- Begin an interval to poll the elapsed elapsed_percentage of the currently playing media.
function M.poll_elapsed_percentage()
  Polls.elapsed_percentage_timer:stop()

  Polls.elapsed_percentage_timer:start(
    1000,
    1000,
    vim.schedule_wrap(function()
      local status_line = MediaInfo.get_status()

      if not status_line or status_line == media_status.STATUS_NO_MEDIA then
        MediaInfo.elapsed_time = nil
        MediaInfo.duration = nil
        MediaInfo.elapsed_percentage = nil
        return
      end

      MediaInfo.elapsed_time = nowplaying_cli.get_elapsed_time()
      MediaInfo.duration = nowplaying_cli.get_duration()

      if MediaInfo.elapsed_time == nil or MediaInfo.duration == nil then
        return
      end

      local elapsed_percentage = math.floor((MediaInfo.elapsed_time / MediaInfo.duration) * 100)
      if elapsed_percentage > 100 then
        MediaInfo.elapsed_percentage = nil
        return
      end

      -- There is a performance hit to calling `nowplaying-cli` every second, so we only
      -- attempt to retrieve updated media info if the elapsed elapsed_percentage has reset.
      if MediaInfo.elapsed_percentage and (elapsed_percentage or 0) < MediaInfo.elapsed_percentage then
        MediaInfo.track = nowplaying_cli.get_title()
        MediaInfo.artist = nowplaying_cli.get_artist()
      end

      MediaInfo.elapsed_percentage = elapsed_percentage
    end)
  )
end

function M.poll()
  M.poll_status()
  M.poll_elapsed_percentage()
end

-- Retrieve cached status line.
function M.get_status()
  return MediaInfo.get_status()
end

-- Retrieve cached status line + elapsed elapsed_percentage.
function M.get_playback()
  local status_line = MediaInfo.get_status()
  local elapsed_percentage = MediaInfo.elapsed_percentage

  if elapsed_percentage == nil then
    return status_line
  end

  return status_line .. "  " .. elapsed_percentage .. "󰏰"
end

function M.print_status()
  local status_line = MediaInfo.get_status()
  print(status_line)
end

function M.print_playback()
  local playback = M.get_playback()
  print(playback)
end

function M.print_elapsed_percentage()
  local status_line = MediaInfo.get_status()

  if not status_line or status_line == media_status.STATUS_NO_MEDIA then
    print("󰏰 unavailable")
    return
  end

  MediaInfo.elapsed_time = nowplaying_cli.get_elapsed_time()
  MediaInfo.duration = nowplaying_cli.get_duration()

  if MediaInfo.elapsed_time == nil or MediaInfo.duration == nil or MediaInfo.elapsed_time > MediaInfo.duration then
    print("󰏰 unavailable")
    return
  end

  MediaInfo.elapsed_percentage = math.floor((MediaInfo.elapsed_time / MediaInfo.duration) * 100)
  print(MediaInfo.elapsed_percentage .. "󰏰")
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
