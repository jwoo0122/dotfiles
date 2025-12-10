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
vim.opt.cursorline = true

vim.opt.listchars:append {
  tab = "┊ ",
  multispace = "·",
  lead = "·",
  trail = "·",
  nbsp = "·",
  space = "·"
}

--- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.inccommand = "split"

-- -- statusline
-- vim.opt.laststatus = 3

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

--- command mode
vim.opt.wildmode = "list:longest,list:full"
vim.opt.wildignore:append({"node_modules"})

-- Terminal
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>')

-- Diagnostic
vim.keymap.set('n', 'ge', vim.diagnostic.open_float)
vim.diagnostic.config({
  float = {
    source = true,
    border = 'rounded',
  }
})

-- hover
local originalHover = vim.lsp.buf.hover
vim.lsp.buf.hover = function()
  return originalHover({
    border = "rounded",
    max_width = math.floor(vim.o.columns * 0.7),
    max_height = math.floor(vim.o.lines * 0.7)
  })
end

--- netrw
vim.g.netrw_liststyle = 3

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
    "rose-pine/neovim",
    config = function()
      require('rose-pine').setup {}
      vim.cmd('colorscheme rose-pine')
    end
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
          layout_strategy = 'horizontal',
          layout_config = {
            horizontal = {
              prompt_position = "top",
              width = { padding = 0 },
              height = { padding = 0 },
              preview_width = 0.5
            }
          },
          preview = true,
          sorting_strategy = "ascending"
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
      vim.keymap.set('n', '<leader>g', builtin.live_grep, {})
      vim.keymap.set('n', '<leader>/', builtin.current_buffer_fuzzy_find, {})

    end
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    ---@type Flash.Config
    opts = {},
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },
  {
    "tpope/vim-fugitive",
    config = function()
    end
  },
  {
    "gelguy/wilder.nvim",
    config = function()
      local wilder = require('wilder')

      wilder.setup({ modes = { ":", "/", "?" }})
      wilder.set_option("renderer", wilder.popupmenu_renderer(
        wilder.popupmenu_palette_theme({
          highlighter = wilder.basic_highlighter(),
          border = 'rounded',
          max_width = '50%',
          max_height = '30%',
          reverse = 0,
          left = {' ', wilder.popupmenu_devicons()},
          right = {' ', wilder.popupmenu_scrollbar()},
          prompt_position = 'top',
        })
      ))
    end
  },
  {
    'kevinhwang91/nvim-bqf',
    config = function()
    end
  },
  {
    'akinsho/toggleterm.nvim',
    version = "*",
    config = function()
      require('toggleterm').setup{
        open_mapping = [[<c-\>]]
      }
    end
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    ---@module "ibl"
    ---@type ibl.config
    config = function()
      local highlight = {
            "CursorColumn",
            "Whitespace",
          }
      require('ibl').setup {
        indent = {
          highlight = highlight,
          char = ""
        },
        whitespace = {
          highlight = highlight,
          remove_blankline_trail = false,
        },
        scope = {
          enabled = true
        }
      }
    end
  },
  {
    'prichrd/netrw.nvim',
    opts = {}
  },
  { "nvim-tree/nvim-web-devicons", opts = {} },
  { 'nvim-mini/mini.statusline', version = '*', opts = {} },
})
