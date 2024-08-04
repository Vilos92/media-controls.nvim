# media-controls.nvim

[![Apache 2.0 License][license-shield]][license-url]

### Media controls for neovim

Provides controls and a status listener for media players on MacOS.

## Requirements

This plugin currently only supports macOS.

This plugin requires [nowplaying-cli](https://github.com/kirtan-shah/nowplaying-cli) in order to work. You can install it with:

```bash
brew install nowplaying-cli
```

Additionally, a patched font is required. We have tested it with [Nerd Fonts](https://www.nerdfonts.com/). Please ensure you have a patched font installed and set as your terminal or Neovim GUI font for the best experience.


## Installation

<details>
    <summary>With <a href="https://github.com/folke/lazy.nvim">folke/lazy.nvim</a></summary>

    ```lua
    { 'vilos92/media-controls.nvim' }
    ```
</details>

## Queries

- `MediaControlStatus` - Get the current status of the media player.
  - Attempts to return the track and artist by default.
- `MediaControlElapsedPct` - Get the elapsed percentage of the current track.

## Commands

- `MediaControlPlay` - Start playback.
- `MediaControlPause` - Pause playback.
- `MediaControlToggle` - Toggle playback.
- `MediaControlNext` - Skip to the next track.
- `MediaControlPrevious` - Skip to the previous track.

## Listening to status

You can listen to the status of the media player for use in other plugins such as [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim).

<details>
    <summary>lualine.nvim example</summary>

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
          media_controls.status_listen,
        },
        lualine_x = { "filename", "location" },
        lualine_y = {},
        lualine_z = {},
      },
    })
    ```
</details>

<!-- MARKDOWN LINKS & IMAGES -->

[license-shield]: https://img.shields.io/github/license/Vilos92/media-controls.nvim.svg?style=for-the-badge
[license-url]: https://github.com/Vilos92/media-controls.nvim/blob/main/LICENSE
