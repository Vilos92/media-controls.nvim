if vim.fn.has("nvim-0.7.0") ~= 1 then
   vim.api.nvim_err_writeln("media-controls.nvim requires at least nvim-0.7.0.")
end

if _G.loaded_music_controls then
  return
end

vim.api.nvim_create_user_command('MCStatus', function() require('media-controls').status() end, {})
vim.api.nvim_create_user_command('MCPlay', function() require('media-controls').play() end, {})
vim.api.nvim_create_user_command('MCPause', function() require('media-controls').pause() end, {})
vim.api.nvim_create_user_command('MCToggle', function() require('media-controls').toggle() end, {})
vim.api.nvim_create_user_command('MCNext', function() require('media-controls').next() end, {})
vim.api.nvim_create_user_command('MCPrevious', function() require('media-controls').previous() end, {})

_G.loaded_music_controls = true
