local media_status = require("media-controls.utils.media-status")

local function check_is_nowplaying_cli_installed()
  if vim.fn.executable("nowplaying-cli") == 0 then
    return false
  end

  return true
end

local M = {}

function M.get_now_playing()
  if not check_is_nowplaying_cli_installed() then
    return media_status.STATUS_NOT_INSTALLED
  end

  local artist = vim.fn.system("nowplaying-cli get artist")
  local title = vim.fn.system("nowplaying-cli get title")

  if artist == "" and title == "" then
    return media_status.STATUS_NO_MEDIA
  end

  if artist == "" then
    return "󰋋 " .. vim.trim(title)
  end

  return "󰋋 " .. vim.trim(title) .. " - " .. vim.trim(artist)
end

function M.get_elapsed_percentage()
  if not check_is_nowplaying_cli_installed() then
    return media_status.STATUS_NOT_INSTALLED
  end

  local elapsedTime = vim.fn.system("nowplaying-cli get elapsedTime")
  local duration = vim.fn.system("nowplaying-cli get duration")

  elapsedTime = tonumber(elapsedTime)
  duration = tonumber(duration)

  if elapsedTime == nil or duration == nil then
    return nil
  end

  local percentage = math.floor((elapsedTime / duration) * 100)
  if percentage > 100 then
    return nil
  end

  return percentage
end

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
