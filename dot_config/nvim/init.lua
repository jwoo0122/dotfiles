---Scroll
vim.o.scrolloff = 999

---Line Number
vim.wo.number = true
vim.wo.relativenumber = true
vim.wo.signcolumn = "yes"

---Indentation
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

---Split direction
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Filetype
vim.filetype.add({
  extension = {
    mdx = 'markdown.mdx',
    md = 'markdown',
  }
})

-- Terminal
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>')

-- Diagnostic
vim.keymap.set('n', 'ge', vim.diagnostic.open_float)
vim.diagnostic.config({
  float = {
    source = true,
    border = 'single',
  }
})


-- Window
vim.keymap.set('n', '<C-h>', '<C-w><C-h>')
vim.keymap.set('n', '<C-l>', '<C-w><C-l>')
vim.keymap.set('n', '<C-j>', '<C-w><C-j>')
vim.keymap.set('n', '<C-k>', '<C-w><C-k>')

-- Keymap
vim.g.mapleader = " "

---Folding
vim.opt.foldmethod = 'indent'
vim.opt.foldlevel = 99
vim.opt.foldenable = false

-- Plugins
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'

if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end ---@diagnostic disable-next-line: undefined-field

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "catppuccin/nvim",
    lazy = false,
    config = function()
      require('catppuccin').setup {}
      vim.cmd.colorscheme('catppuccin-mocha')
    end,
    priority = 1000
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
        pylsp = {},
        rust_analyzer = {},
        jsonls = {},
        astro = {},
        eslint = {},
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                globals = {
                  'vim'
                }
              }
            }
          }
        },
        ts_ls = {},
        marksman = {},
        tailwindcss = {},
        yamlls = {},
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
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
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
          { name = 'buffer' },
          { name = 'emoji' }
        }),
      })
    end
  },
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = true,
  },
  {
    'nvim-lualine/lualine.nvim',
    config = function()
      require('lualine').setup {
        options = {
          component_separators = { left = ' ', right = ' ' },
          section_separators = { left = ' ', right = ' ' },
        }
      }
    end
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      -- {"3rd/image.nvim", opts = {}}, -- Optional image support in preview window: See `# Preview Mode` for more information
    },
    lazy = false, -- neo-tree will lazily load itself
    ---@module "neo-tree"
    ---@type neotree.Config?
    opts = {
      -- fill any relevant options here
    },
  },

})
