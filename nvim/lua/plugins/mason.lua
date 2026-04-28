local tools = {
  "clangd",
  "cmake-language-server",
  "pyright",
  "ruff",
}

return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      if vim.env.NVIM_DOTFILES_BOOTSTRAP == "1" then
        opts.ensure_installed = {}
        return opts
      end

      vim.list_extend(opts.ensure_installed, tools)
    end,
  },
}
