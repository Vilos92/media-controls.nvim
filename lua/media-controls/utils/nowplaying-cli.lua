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
