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
          ensure_installed = { "python", "cpp", "c", "lua", "markdown", "latex" },
          highlight = { enable = true },
          indent = { enable = true },
        })
      end
    end
  },
  { "neovim/nvim-lspconfig",
    dependencies = { "williamboman/mason.nvim", "hrsh7th/nvim-cmp", "hrsh7th/cmp-nvim-lsp" },
    config = function()
      require("mason").setup()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local servers = { "pyright", "clangd", "lua_ls", "tinymist" }
      for _, lsp in ipairs(servers) do
          local config = {
              capabilities = capabilities,
              on_attach = function(_, bufnr)
                  local b = { buffer = bufnr }
                  map("n", "gd", vim.lsp.buf.definition, b)
                  map("n", "K", vim.lsp.buf.hover, b)
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
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping.select_next_item(),
        }),
        sources = cmp.config.sources({ { name = "nvim_lsp" } }, { { name = "buffer" } })
      })
    end
  },
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" }, config = true },
  { "stevearc/oil.nvim", dependencies = { "nvim-tree/nvim-web-devicons" }, config = true },
  { "akinsho/toggleterm.nvim", version = "*", config = function()
      require("toggleterm").setup({
        size = 15,
        open_mapping = [[<c-\>]],
        direction = "float",
        shell = "pwsh -NoLogo",
      })
    end
  },
  { "nvim-lualine/lualine.nvim", config = function()
      require("lualine").setup({
        options = { theme = "kanagawa", globalstatus = true },
        sections = { lualine_x = { function() return os.getenv("CONDA_DEFAULT_ENV") or "base" end, "filetype" } }
      })
    end
  },
})

map("n", "-", "<CMD>Oil<CR>")
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>")
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>")
map("n", "<leader>t", "<cmd>ToggleTerm<cr>")
map("n", "<leader>e", vim.diagnostic.open_float)


