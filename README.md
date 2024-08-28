# media-controls.nvim

[![Apache 2.0 License][license-shield]][license-url]

### Media Controls for Neovim

<img src="preview.gif" width="800em"/> <br>

This Neovim plugin provides controls and status updates for media players on macOS. It enables you to easily access track information, elapsed time, and control playback directly from your Neovim environment. Whether you want to play, pause, or skip tracks, this plugin has got you covered.

## Requirements

This plugin currently only supports macOS.

This plugin requires [nowplaying-cli](https://github.com/kirtan-shah/nowplaying-cli) in order to work. You can install it with:

```bash
brew install nowplaying-cli
```

Additionally, a patched font is required. This has been tested with [Nerd Fonts](https://www.nerdfonts.com/). Please ensure you have a patched font installed and set as your terminal or Neovim GUI font for the best experience.


## Installation

<details>
    <summary>With <a href="https://github.com/folke/lazy.nvim">folke/lazy.nvim</a></summary>

    ```lua
    { 'Vilos92/media-controls.nvim' }
    ```
</details>

## Commands

### Queries

- `:MediaControlStatus` - Get the current status of the media player.
  - Returns the track and artist.
- `:MediaControlPlayback` - Get the current playback of the media player.
  - Returns the track, artist, and elapsed percentage of the current track.
- `:MediaControlElapsedPct` - Get the elapsed percentage of the current track.

### Controls

- `:MediaControlPlay` - Start playback.
- `:MediaControlPause` - Pause playback.
- `:MediaControlToggle` - Toggle playback.
- `:MediaControlNext` - Skip to the next track.
- `:MediaControlPrevious` - Skip to the previous track.

## Listening to status

You can listen to the status of the media player for use in other plugins such as [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim).

In order to listen to the status, you can use the `poll_status` function. This will poll the status of the media player.

```lua
local media_controls = require("media-controls")
-- If using `media-controls` in multiple places, `poll_status` should only be called once.
media_controls.poll_status()
```

You can then use the `get_playback` function to get the current status of the media player.

```lua
-- Returns: "Track - Artist > Elapsed%"
media_controls.get_playback()
```

If you do not want to include the elapsed percentage, you can instead use `get_status`.

```lua
-- Returns: "Track - Artist"
media_controls.get_status()
```

<details>
<summary>lualine.nvim example</summary>

```lua
local media_controls = require("media-controls")
-- If using `media-controls` in multiple places, `poll_status` should only be called once.
media_controls.poll_status()

require("lualine").setup({
  options = { theme = "auto" },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch", "diff", "diagnostics" },
    lualine_c = {
      media_controls.get_playback(),
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
      media_controls.get_playback(),
    },
    lualine_x = { "filename", "location" },
    lualine_y = {},
    lualine_z = {},
  },
})
```
</details>

<details>
<summary>mini.nvim example</summary>

```lua
local media_controls = require("media-controls")
-- If using `media-controls` in multiple places, `poll_status` should only be called once.
media_controls.poll_status()

local footer = (function()
  local media_status = ""
  local timer = vim.loop.new_timer()

  timer:start(
    0,
    1000,
    vim.schedule_wrap(function()
      if vim.bo.filetype ~= "ministarter" then
        return
      end

      local new_media_status = media_controls.get_status()
      new_media_status = new_media_status or ""

      if new_media_status == media_status then
        return
      end

      media_status = new_media_status
      MiniStarter.refresh()
    end)
  )

  return function()
    return "Hello,\n\n📅 The current date is " .. os.date("%B %d, %Y") .. "\n\n" .. media_status
  end
end)()
```
</details>

## Known Issues

- The plugin currently only supports macOS.
  - This project could be extended to support `playerctl` or other alternatives for cross-platform support.

## Related Projects

- [nowplaying-cli](https://github.com/kirtan-shah/nowplaying-cli)
- [music-controls.nvim](https://github.com/AntonVanAssche/music-controls.nvim)
- [nvim-spotify](https://github.com/KadoBOT/nvim-spotify)

<!-- MARKDOWN LINKS & IMAGES -->

[license-shield]: https://img.shields.io/github/license/Vilos92/media-controls.nvim.svg?style=for-the-badge
[license-url]: https://github.com/Vilos92/media-controls.nvim/blob/main/LICENSE
