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

function M.get_title()
  if not check_is_nowplaying_cli_installed() then
    return media_status.STATUS_NOT_INSTALLED
  end

  local title = vim.fn.system("nowplaying-cli get title")
  return vim.trim(title)
end

function M.get_artist_title_callback(callback)
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

function M.get_is_playing_elapsed_time_duration_callback(callback)
  if not check_is_nowplaying_cli_installed() then
    return callback(media_status.STATUS_NOT_INSTALLED, media_status.STATUS_NOT_INSTALLED, media_status.STATUS_NOT_INSTALLED)
  end

  Job:new({
    command = "nowplaying-cli",
    args = { "get", "playbackRate" },
    on_exit = function(j)
      local isPlaying = vim.trim(j:result()[1]) == "1"
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
              callback(isPlaying, elapsedTime, duration)
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
