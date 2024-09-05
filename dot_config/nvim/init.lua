vim.wo.number = true
vim.wo.relativenumber = true

vim.g.mapleader = " "

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{
		"rebelot/kanagawa.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require('kanagawa').setup({
				theme = "wave"
			})
			vim.cmd("colorscheme kanagawa")
		end,
	},
	{
		'nvim-telescope/telescope.nvim',
		event = 'VimEnter',
		dependencies = { 'nvim-lua/plenary.nvim' },
		config = function()
			require('telescope').setup({})
			local builtin = require('telescope.builtin')
			vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
			vim.keymap.set('n', '<leader>fs', builtin.lsp_document_symbols, {})
			vim.keymap.set('n', '<leader>/', builtin.current_buffer_fuzzy_find, {})
		end
	},
	{
		'folke/flash.nvim',
		event = 'VeryLazy',
		keys = {
			{ "s", mode = { "n", "x", "o" }, function() require("flash").jump() end }
		}
	}
})
