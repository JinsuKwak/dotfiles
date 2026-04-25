local theme = require("config.theme")

local function transparent_highlights()
  return {
    Normal = { bg = "NONE" },
    NormalNC = { bg = "NONE" },
    NormalFloat = { bg = "NONE" },
    FloatBorder = { bg = "NONE" },
    FloatTitle = { bg = "NONE" },
    SignColumn = { bg = "NONE" },
    LineNr = { bg = "NONE" },
    CursorLineNr = { bg = "NONE" },
    EndOfBuffer = { bg = "NONE" },
    MsgArea = { bg = "NONE" },
    WinSeparator = { bg = "NONE" },
    StatusLine = { bg = "NONE" },
    StatusLineNC = { bg = "NONE" },
    TabLine = { bg = "NONE" },
    TabLineFill = { bg = "NONE" },
    TabLineSel = { bg = "NONE" },
    NeoTreeNormal = { bg = "NONE" },
    NeoTreeNormalNC = { bg = "NONE" },
    VertSplit = { bg = "NONE" },
  }
end

return {
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = {
      transparent = theme.transparent_background,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
      on_highlights = function(highlights)
        for group, value in pairs(transparent_highlights()) do
          highlights[group] = value
        end
      end,
    },
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      transparent_background = theme.transparent_background,
      custom_highlights = transparent_highlights,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = theme.colorscheme,
    },
  },
}
