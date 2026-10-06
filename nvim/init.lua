-- Neovim entrypoint (install.sh links this to ~/.config/nvim/init.lua).
-- Shared settings live in ~/.vimrc (also used by plain Vim); nvim-only config
-- goes below.

vim.cmd("source ~/.vimrc")

-- Tokyo Night via Neovim's built-in plugin manager (0.12+)
vim.opt.termguicolors = true
vim.pack.add({ "https://github.com/folke/tokyonight.nvim" }, { confirm = false })
require("tokyonight").setup({ style = "night" })
-- falls back to the .vimrc colorscheme if the plugin isn't available
pcall(vim.cmd.colorscheme, "tokyonight-night")
