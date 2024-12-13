vim.wo.number = true
vim.wo.relativenumber = true

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.bo.softtabstop = 2
vim.opt.list = true

vim.opt.listchars:append {
  tab = "|-",
  multispace = "·",
  lead = "·",
  trail = "·",
  nbsp = "·",
  space = "·"
}

vim.g.mapleader = " "

vim.api.nvim_create_autocmd({ 'BufEnter', 'FocusGained', 'InsertLeave', 'CmdlineLeave', 'WinEnter' }, {
  pattern = '*',
  group = augroup,
  callback = function()
    vim.opt.cursorline = true
    if vim.o.nu and vim.api.nvim_get_mode().mode ~= 'i' then
      vim.opt.relativenumber = true
    end
  end,
})
vim.api.nvim_create_autocmd({ 'BufLeave', 'FocusLost', 'InsertEnter', 'CmdlineEnter', 'WinLeave' }, {
  pattern = '*',
  group = augroup,
  callback = function()
    vim.opt.cursorline = false
    if vim.o.nu then
      vim.opt.relativenumber = false
      vim.cmd 'redraw'
    end
  end,
})

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
    'nanotee/zoxide.vim',
    config = function()
      vim.g.zoxide_use_select = 1
    end
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require('tokyonight').setup()
      vim.cmd("colorscheme tokyonight-night")
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
      vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
      vim.keymap.set('n', '<leader>/', builtin.current_buffer_fuzzy_find, {})
    end
  },
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end }
    }
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
    },
    config = function()
      local servers = {
        rust_analyzer = {},
        jsonls = {},
        astro = {},
        eslint = {},
        lua_ls = {},
        ts_ls = {}
      }

      require('mason').setup()

      local ensure_installed = vim.tbl_keys(servers)
      require('mason-tool-installer').setup({ ensure_installed = ensure_installed })
      require('mason-lspconfig').setup({
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            require('lspconfig')[server_name].setup(server)
          end
        }
      })

      vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
      vim.keymap.set('n', 'fr', vim.lsp.buf.references)
      vim.keymap.set('n', 'rn', vim.lsp.buf.rename)
      vim.keymap.set('n', 'fm', vim.lsp.buf.format)
    end
  },
  {
    'akinsho/toggleterm.nvim',
    version = "*",
    config = function()
      require('toggleterm').setup {
        size = 20,
        open_mapping = [[<c-`>]]
      }
    end
  },
  {
    'stevearc/oil.nvim',
    opts = {
      view_options = {
        show_hidden = true
      }
    },
  },
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-vsnip',
      'hrsh7th/vim-vsnip',
    },
    config = function()
      local cmp = require('cmp')

      cmp.setup({
        snippet = {
          expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
          end
        },
        mapping = {
          ['<Tab>'] = function(fallback)
            if cmp.visible() then
              cmp.confirm({ select = true })
            else
              fallback()
            end
          end,
          ['<C-j>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
          ['<C-k>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
        },
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'vsnip' },
        }),
        {
          { name = 'buffer' }
        }
      })
    end
  },
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = true,
  },
  { 'echasnovski/mini.statusline', version = false, config = true },
  {
    'nvim-treesitter/nvim-treesitter',
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = { "javascript", "astro", "typescript", "dockerfile", "bash", "go", "json", "lua", "yaml" },
        sync_install = true,
        auto_install = true,
        highlight = {
          enable = true
        }
      })
    end
  }
})
