-- Neovim entrypoint (install.sh links this to ~/.config/nvim/init.lua).
-- Shared settings live in ~/.vimrc (also used by plain Vim); nvim-only config
-- goes below.

vim.cmd("source ~/.vimrc")

-- Tokyo Night via Neovim's built-in plugin manager (0.12+): "night" in dark
-- mode, "day" in light mode.
vim.opt.termguicolors = true
vim.pack.add({ "https://github.com/folke/tokyonight.nvim" }, { confirm = false })
require("tokyonight").setup({ style = "night", light_style = "day" })

-- Load the matching style. Explicit names, rather than plain "tokyonight", so
-- dark mode is always "night". Loading the scheme sets 'background' itself;
-- setting 'background' first would trigger a second, racing reload. If the
-- plugin isn't available, set it by hand and keep the .vimrc colorscheme.
local function apply_theme(bg)
  local scheme = bg == "light" and "tokyonight-day" or "tokyonight-night"
  if not pcall(vim.cmd.colorscheme, scheme) then
    vim.o.background = bg
  end
end

-- Follow the macOS light/dark appearance. `defaults read -g AppleInterfaceStyle`
-- prints "Dark" in dark mode and fails in light mode. This reads the OS setting
-- directly because asking the terminal (OSC 11) doesn't work reliably inside
-- tmux. Re-checked on focus, so a system switch applies when you return to nvim.
if vim.fn.has("mac") == 1 then
  local function sync_theme()
    local out = vim.fn.system({ "defaults", "read", "-g", "AppleInterfaceStyle" })
    apply_theme(out:match("Dark") and "dark" or "light")
  end
  sync_theme()
  -- nested: lets the .vimrc ColorScheme autocmd (ColorColumn colour) fire when
  -- the colorscheme is reloaded from inside this callback.
  vim.api.nvim_create_autocmd({ "FocusGained", "VimResume" }, { nested = true, callback = sync_theme })
else
  apply_theme(vim.o.background)
end
