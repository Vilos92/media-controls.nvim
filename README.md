# media-controls.nvim

### Media controls for neovim

**NOTE**: This plugin currently only supports macOS.

Provides controls and a status listener for media players on MacOS.

## Installation

<details>
    <summary>With <a href="https://github.com/folke/lazy.nvim">folke/lazy.nvim</a></summary>
    <code>{ 'vilos92/media-controls.nvim' }</code>
</details>

## Commands

- `MCStatus` - Get the current status of the media player.
  - Attempts to return the track and artist by default.
- `MCPlay` - Start playback.
- `MCPause` - Pause playback.
- `MCToggle` - Toggle playback.
- `MCNext` - Skip to the next track.
- `MCPrevious` - Skip to the previous track.

## Listening to status

You can listen to the status of the media player, for use in other plugins such as [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim).

<details>
    <summary>lualine.nvim example</summary>
    <code>
    ```lua
    local media_controls = require("media-controls")
    media_controls.status_poll()

    require("lualine").setup({
      options = { theme = "auto" },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = {
          media_controls.status_listen,
        },
        lualine_x = {
          "filename",
          "encoding",
          "fileformat",
          "filetype",
        },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },

      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {
          media_controls.listen,
        },
        lualine_x = { "filename", "location" },
        lualine_y = {},
        lualine_z = {},
      },
    })
    ```
    </code>
</details>
