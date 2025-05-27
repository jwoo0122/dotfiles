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
  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
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
    'nvim-treesitter/nvim-treesitter',
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = { "javascript", "astro", "typescript", "dockerfile", "bash", "go", "json", "lua", "yaml", "ocaml", "fsharp", "python", "rust" },
        sync_install = true,
        auto_install = true,
        highlight = {
          enable = true
        },
      })
    end
  },
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end
  },
  {
    'Bekaboo/dropbar.nvim',
    config = function()
      require('dropbar').setup({
        menu = {
          preview = false,
          win_configs = {
            border = 'rounded'
          }
        }
      })
      local dropbar_api = require('dropbar.api')
      vim.keymap.set('n', '<leader>;', dropbar_api.pick)
      vim.keymap.set('n', '[;', dropbar_api.goto_context_start)
      vim.keymap.set('n', '];', dropbar_api.select_next_context)
    end
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
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'jvgrootveld/telescope-zoxide',
    },
    config = function()
      local telescope = require('telescope')
      telescope.setup({
        defaults = {
          layout_strategy = 'vertical',
          preview = false,
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true,    -- override the file sorter
            case_mode = "smart_case",
          }
        },
        pickers = {
          find_files = {
            hidden = true
          }
        }
      })
      telescope.load_extension('zoxide');

      local function project_files()
        local is_inside_work_tree = {}
        local opts = {} -- define here if you want to define something

        local cwd = vim.fn.getcwd()
        if is_inside_work_tree[cwd] == nil then
          vim.fn.system("git rev-parse --is-inside-work-tree")
          is_inside_work_tree[cwd] = vim.v.shell_error == 0
        end

        if is_inside_work_tree[cwd] then
          require("telescope.builtin").git_files(opts)
        else
          require("telescope.builtin").find_files(opts)
        end
      end

      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>p', project_files, {})
      vim.keymap.set('n', '<leader>d', builtin.lsp_document_symbols, {})
      vim.keymap.set('n', '<leader>b', builtin.buffers, {})
      vim.keymap.set('n', '<leader>z', telescope.extensions.zoxide.list, {})
      vim.keymap.set('n', '<leader>/', builtin.current_buffer_fuzzy_find, {})
    end
  },
})
