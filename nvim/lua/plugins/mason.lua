return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "clangd",
        "cmake-language-server",
        "pyright",
        "ruff",
      },
    },
  },
}
