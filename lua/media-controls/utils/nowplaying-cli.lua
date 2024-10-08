local Job = require("plenary.job")

local media_status = require("media-controls.utils.media-status")

local function check_is_nowplaying_cli_installed()
  if vim.fn.executable("nowplaying-cli") == 0 then
    return false
  end

  return true
end

local M = {}

-- QUERIES

function M.get_artist()
  if not check_is_nowplaying_cli_installed() then
    return media_status.STATUS_NOT_INSTALLED
  end

  local artist = vim.fn.system("nowplaying-cli get artist")
  return vim.trim(artist)
end

function M.get_track()
  if not check_is_nowplaying_cli_installed() then
    return media_status.STATUS_NOT_INSTALLED
  end

  -- The `title` parameter returns the track name.
  local track = vim.fn.system("nowplaying-cli get title")
  return vim.trim(track)
end

function M.get_elapsed_time()
  if not check_is_nowplaying_cli_installed() then
    return media_status.STATUS_NOT_INSTALLED
  end

  local elapsedTime = vim.fn.system("nowplaying-cli get elapsedTime")

  return tonumber(elapsedTime)
end

function M.get_duration()
  if not check_is_nowplaying_cli_installed() then
    return media_status.STATUS_NOT_INSTALLED
  end

  local duration = vim.fn.system("nowplaying-cli get duration")

  return tonumber(duration)
end

function M.get_is_playing()
  if not check_is_nowplaying_cli_installed() then
    return media_status.STATUS_NOT_INSTALLED
  end

  local playbackRate = vim.fn.system("nowplaying-cli get playbackRate")

  return vim.trim(playbackRate) == "1"
end

-- CALLBACK QUERIES
-- Callbacks are used to avoid blocking the main thread while waiting for the response from the CLI.
-- They are mainly used when polling the media status in the background.

-- Async function to query the `artist` and `title` of the current media and fire a callback with the results.
function M.get_artist_and_title_callback(callback)
  if not check_is_nowplaying_cli_installed() then
    return callback(media_status.STATUS_NOT_INSTALLED, media_status.STATUS_NOT_INSTALLED)
  end

  Job:new({
    command = "nowplaying-cli",
    args = { "get", "artist" },
    on_exit = function(artist_response)
      local artist = vim.trim(artist_response:result()[1])
      Job:new({
        command = "nowplaying-cli",
        args = { "get", "title" },
        on_exit = function(title_response)
          local title = vim.trim(title_response:result()[1])
          callback(artist, title)
        end,
      }):start()
    end,
  }):start()
end

-- Async function to query the `is_playing`, `elapsed_time` and `duration` of the
-- current media and fire a callback with the results.
function M.get_playback_callback(callback)
  if not check_is_nowplaying_cli_installed() then
    return callback(
      media_status.STATUS_NOT_INSTALLED,
      media_status.STATUS_NOT_INSTALLED,
      media_status.STATUS_NOT_INSTALLED
    )
  end

  Job:new({
    command = "nowplaying-cli",
    args = { "get", "playbackRate" },
    on_exit = function(playback_rate_result)
      local is_playing = vim.trim(playback_rate_result:result()[1]) == "1"
      Job:new({
        command = "nowplaying-cli",
        args = { "get", "elapsedTime" },
        on_exit = function(elapsed_time_result)
          local elapsedTime = tonumber(vim.trim(elapsed_time_result:result()[1]))
          Job:new({
            command = "nowplaying-cli",
            args = { "get", "duration" },
            on_exit = function(duration_result)
              local duration = tonumber(vim.trim(duration_result:result()[1]))
              callback(is_playing, elapsedTime, duration)
            end,
          }):start()
        end,
      }):start()
    end,
  }):start()
end

-- ACTIONS

function M.play()
  if not check_is_nowplaying_cli_installed() then
    return media_status.STATUS_NOT_INSTALLED
  end

  vim.fn.system("nowplaying-cli play")
end

function M.pause()
  if not check_is_nowplaying_cli_installed() then
    return media_status.STATUS_NOT_INSTALLED
  end

  vim.fn.system("nowplaying-cli pause")
end

function M.toggle()
  if not check_is_nowplaying_cli_installed() then
    return media_status.STATUS_NOT_INSTALLED
  end

  vim.fn.system("nowplaying-cli togglePlayPause")
end

function M.next()
  if not check_is_nowplaying_cli_installed() then
    return media_status.STATUS_NOT_INSTALLED
  end

  vim.fn.system("nowplaying-cli next")
end

function M.previous()
  if not check_is_nowplaying_cli_installed() then
    return media_status.STATUS_NOT_INSTALLED
  end

  vim.fn.system("nowplaying-cli previous")
end

return M
