return {
  -- Bundled by the markdown extra but unmaintained and needs Node; glow covers preview
  {
    "iamcco/markdown-preview.nvim",
    enabled = false,
  },
  -- Disable MD013 (line-length) diagnostics
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters = {
        ["markdownlint-cli2"] = {
          args = { "--config", vim.fn.stdpath("config") .. "/markdownlint.jsonc", "-" },
        },
      },
    },
  },
}
