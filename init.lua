vim.g.mapleader = " "
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.scrolloff =  5
vim.opt.updatetime = 200
vim.opt.timeoutlen = 300
vim.opt.clipboard = "unnamedplus"
vim.opt.undofile = true
vim.opt.swapfile = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartindent = true
vim.opt.completeopt = { "menuone", "noselect" }
vim.opt.splitright = true
vim.opt.splitbelow = true

vim.filetype.add({ extension = { typ = "typst" } })

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

local function map(mode, lhs, rhs, opts)
    local options = { silent = true }
    if opts then options = vim.tbl_extend("force", options, opts) end
    vim.keymap.set(mode, lhs, rhs, options)
end

require("lazy").setup({
    { "rebelot/kanagawa.nvim", priority = 1000, config = function()
        require("kanagawa").setup({ theme = "wave", background = { dark = "wave" } })
        vim.cmd.colorscheme("kanagawa-wave")
    end
},
{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate", config = function()
    local ok, configs = pcall(require, "nvim-treesitter.configs")
    if ok then
        configs.setup({
            ensure_installed = { "python", "cpp", "c", "lua", "typst", "latex" },
            highlight = { enable = true },
            indent = { enable = true },
        })
    end
end
  },
  { "neovim/nvim-lspconfig",
  dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
  },
  config = function()
      require("mason").setup()
      local ensure = {
          "clangd", "lua_ls", "texlab", "tinymist",
          "arduino_language_server", "asm_lsp", "julials",
          "basedpyright", "ruff",
      }
      require("mason-lspconfig").setup({ ensure_installed = ensure })

      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local servers = vim.deepcopy(ensure)
      for _, lsp in ipairs(servers) do
          local config = {
              capabilities = capabilities,
              on_attach = function(_, bufnr)
                  local b = { buffer = bufnr }
                  map("n", "gd", vim.lsp.buf.definition, b)
                  map("n", "K",  vim.lsp.buf.hover, b)
                  map("n", "<leader>rn", vim.lsp.buf.rename, b)
              end,
          }

          if lsp == "lua_ls" then
              config.settings = {
                  Lua = {
                      runtime = { version = "LuaJIT" },
                      diagnostics = { globals = { "vim" } },
                      workspace = {
                          library = vim.api.nvim_get_runtime_file("", true),
                          checkThirdParty = false,
                      },
                  },
              }
          end

          vim.lsp.config(lsp, config)
          vim.lsp.enable(lsp)
      end

      local cmp = require("cmp")
      cmp.setup({
          mapping = cmp.mapping.preset.insert({
              ["<CR>"]    = cmp.mapping.confirm({ select = true }),
              ["<TAB>"]   = cmp.mapping.select_next_item(),
              ["<S-TAB>"]   = cmp.mapping.select_prev_item(),
              ["<C-Space>"] = cmp.mapping.complete(),
          }),
          sources = cmp.config.sources(
              { { name = "nvim_lsp" } },
              { { name = "buffer" }, { name = "path" } }
          ),
      })

      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
  end
},
{
    'nvim-telescope/telescope.nvim', version = '*',
    dependencies = {
        'nvim-lua/plenary.nvim',
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    }
},

{
    'stevearc/oil.nvim',
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {
        default_file_explorer = true,
        delete_to_trash = true,
        float = {
            max_width = 0.75,
            max_height = 0.75,
            border = "rounded",
            win_options = {
                winblend = 0,
            },
            override = function(conf)
                return conf
            end,
        },
    },
    dependencies = { { "nvim-tree/nvim-web-devicons", opts = {} } },
    lazy = false,
},

{ "akinsho/toggleterm.nvim",
version = "*",
config = function()
    require("toggleterm").setup({
        size = 20,
        autochdir = true,
        open_mapping = [[<c-}>]],
        direction = "float",
        shell = "pwsh -NoLogo",
    })
end
  },

  { "nvim-lualine/lualine.nvim", config = function()
      require("lualine").setup({
          options = { theme = "auto", globalstatus = true },
          sections = { lualine_x = { function() return os.getenv("CONDA_DEFAULT_ENV") or "" end, "filetype" } }
      })
  end
  },
  {
      "windwp/nvim-autopairs",
      config = function()
          require("nvim-autopairs").setup({
              check_ts = true,
              enable_moveright = true,
              enable_check_bracket_line = true,
          })
      end,
  },
  {
      "mikavilpas/yazi.nvim",
      version = "*", -- use the latest stable version
      event = "VeryLazy",
      dependencies = {
          { "nvim-lua/plenary.nvim", lazy = true },
      },
      keys = {
          -- 👇 in this section, choose your own keymappings!
          {
              "<leader>y",
              mode = { "n", "v" },
              "<cmd>Yazi<cr>",
              desc = "Open yazi at the current file",
          },
          {
              -- Open in the current working directory
              "<leader>cw",
              "<cmd>Yazi cwd<cr>",
              desc = "Open the file manager in nvim's working directory",
          },
          {
              "<c-up>",
              "<cmd>Yazi toggle<cr>",
              desc = "Resume the last yazi session",
          },
      },
      opts = {
          -- if you want to open yazi instead of netrw, see below for more info
          open_for_directories = false,
          keymaps = {
              show_help = "<f1>",
          },
      },
      -- 👇 if you use `open_for_directories=true`, this is recommended
      init = function()
          -- mark netrw as loaded so it's not loaded at all.
          --
          -- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
          vim.g.loaded_netrwPlugin = 1
      end,
  },
  {
      'chomosuke/typst-preview.nvim',
      lazy = false, -- or ft = 'typst'
      version = '1.*',
      opts = {}, -- lazy.nvim will implicitly calls `setup {}`
  }
})

map("n", "<leader>o", "<CMD>Oil --float<CR>")
map("n", "-", "<CMD>Oil<CR>")
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>")
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>")
map("n", "<leader>e", vim.diagnostic.open_float)
map("n", "<leader>bn", ":bnext<CR>")
map("n", "<leader>bp", ":bprevious<CR>")
map("n", "<leader>bd", ":bd<CR>")
map("n", "<leader>ss", "<cmd>vs<CR>")
map("n", "<leader>cc", "<cmd>close<CR>")
map("n", "<leader>tp", "<cmd>TypstPreview<CR>")
map("n", "<leader>ts", "<cmd>TypstPreviewStop<CR>")
map("n", "<leader>cd", ":lcd %:p:h<CR>")
map("n", "<F11>", function()
vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
end)
vim.o.guifont = "Iosevka Nerd Font Mono:h13"
vim.g.neovide_title_background_color = string.format(
    "%x",
    vim.api.nvim_get_hl(0, {id=vim.api.nvim_get_hl_id_by_name("Normal")}).bg
)
vim.g.neovide_hide_mouse_when_typing = true
if vim.g.neovide then
  local function copy() vim.cmd([[normal! "+y]]) end
  local function paste() vim.api.nvim_paste(vim.fn.getreg("+"), true, -1) end

  vim.keymap.set("v", "<C-c>", copy, { silent = true, desc = "Copy" })
  vim.keymap.set({ "n", "i", "v", "c", "t" }, "<C-v>", paste, { silent = true, desc = "Paste" })
end
