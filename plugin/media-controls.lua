if vim.fn.has("nvim-0.7.0") ~= 1 then
  vim.api.nvim_err_writeln("vilos92/media-controls.nvim requires at least nvim-0.7.0.")
end

if _G.loaded_music_controls then
  return
end

vim.api.nvim_create_user_command("MediaControlArtist", function()
  require("media-controls").print_artist()
end, {})
vim.api.nvim_create_user_command("MediaControlTrack", function()
  require("media-controls").print_track()
end, {})
vim.api.nvim_create_user_command("MediaControlStatus", function()
  require("media-controls").print_status()
end, {})
vim.api.nvim_create_user_command("MediaControlPlayback", function()
  require("media-controls").print_playback()
end, {})
vim.api.nvim_create_user_command("MediaControlElapsedPct", function()
  require("media-controls").print_elapsed_percentage()
end, {})
vim.api.nvim_create_user_command("MediaControlIsPlaying", function()
  require("media-controls").print_is_playing()
end, {})
vim.api.nvim_create_user_command("MediaControlPlay", function()
  require("media-controls").play()
end, {})
vim.api.nvim_create_user_command("MediaControlPause", function()
  require("media-controls").pause()
end, {})
vim.api.nvim_create_user_command("MediaControlToggle", function()
  require("media-controls").toggle()
end, {})
vim.api.nvim_create_user_command("MediaControlNext", function()
  require("media-controls").next()
end, {})
vim.api.nvim_create_user_command("MediaControlPrevious", function()
  require("media-controls").previous()
end, {})

_G.loaded_music_controls = true
