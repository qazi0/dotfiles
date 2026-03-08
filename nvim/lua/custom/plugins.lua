local plugins = {
  {
    "neovim/nvim-lspconfig",
     config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
     end,
  },
  {
    "nvimtools/none-ls.nvim",
    event = "VeryLazy",
    opts = function()
      return require "custom.configs.null-ls"
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "clangd",
        "clang-format",
      }
    }
  }
}
return plugins
