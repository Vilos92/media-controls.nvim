-- HELPERS
-- Helper functions for checking for the existence of `nowplaying-cli` and
-- getting the current media status.

DEFAULT_STATUS = "😴 No active media"

local function check_is_nowplaying_cli_installed()
  if vim.fn.executable("nowplaying-cli") == 0 then
    return false
  end

  return true
end

local function get_now_playing()
  if not check_is_nowplaying_cli_installed() then
    return "🔇 nowplaying-cli is not installed"
  end

  local artist = vim.fn.system(
    "nowplaying-cli get-raw | rg -oP '(?<=kMRMediaRemoteNowPlayingInfoArtist = )[^\n]+' | sed 's/;$//' | sed 's/^\"//;s/\"$//'"
  )
  local title = vim.fn.system(
    "nowplaying-cli get-raw | rg -oP '(?<=kMRMediaRemoteNowPlayingInfoTitle = )[^\n]+' | sed 's/;$//' | sed 's/^\"//;s/\"$//'"
  )

  if artist == "" and title == "" then
    return DEFAULT_STATUS
  end

  if artist == "" then
    return "🎧 " .. vim.trim(title)
  end

  return "🎧 " .. vim.trim(title) .. " - " .. vim.trim(artist)
end

local function play()
  if not check_is_nowplaying_cli_installed() then
    return "🔇 nowplaying-cli is not installed"
  end

  vim.fn.system("nowplaying-cli play")
end

local function pause()
  if not check_is_nowplaying_cli_installed() then
    return "🔇 nowplaying-cli is not installed"
  end

  vim.fn.system("nowplaying-cli pause")
end

local function toggle()
  if not check_is_nowplaying_cli_installed() then
    return "🔇 nowplaying-cli is not installed"
  end

  vim.fn.system("nowplaying-cli togglePlayPause")
end

local function next()
  if not check_is_nowplaying_cli_installed() then
    return "🔇 nowplaying-cli is not installed"
  end

  vim.fn.system("nowplaying-cli next")
end

local function previous()
  if not check_is_nowplaying_cli_installed() then
    return "🔇 nowplaying-cli is not installed"
  end

  vim.fn.system("nowplaying-cli previous")
end

-- MODULE
-- The nvim plugin for `media-controls`.

local M = {}

function M.setup(opts)
  opts = opts or {}

  -- We do not directly return the result of get_now_playing() as there is
  -- is an IO operation involved and we want to avoid blocking the caller.
  -- We instead cache the value in `STATUS_LINE` using a timer callback
  -- and return this cached value via `status_listen()`.
  STATUS_LINE = DEFAULT_STATUS
end

-- STATUS
-- Methods to get and listen to the current media status.

-- Begin an interval to poll the now playing status. If this is not run,
-- the `STATUS_LINE` will always be `DEFAULT_STATUS`.
function M.status_poll()
  -- STATUS_LINE = get_now_playing() or DEFAULT_STATUS

  local timer = vim.loop.new_timer()
  timer:start(
    1000,
    10000,
    vim.schedule_wrap(function()
      STATUS_LINE = get_now_playing() or DEFAULT_STATUS
    end)
  )
end

-- Return cached status line.
function M.status_listen()
  return STATUS_LINE or DEFAULT_STATUS
end

function M.status()
  STATUS_LINE = get_now_playing() or DEFAULT_STATUS
  print(STATUS_LINE)
end

-- PLAYBACK CONTROLS
-- Methods to control media playback.

function M.play()
  play()
end

function M.pause()
  pause()
end

function M.toggle()
  toggle()
end

function M.next()
  next()
end

function M.previous()
  previous()
end

return M
