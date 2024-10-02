local M = {}

local function check_nowplaying_cli()
  return vim.fn.executable("nowplaying-cli") == 1
end

M.check = function()
  vim.health.start("media-controls.nvim")
  if check_nowplaying_cli() then
    vim.health.ok("nowplaying-cli is installed")
  else
    vim.health.error("nowplaying-cli is not installed")
  end
end
return M
