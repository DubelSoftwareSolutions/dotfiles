local clangd_query_driver =
  "--query-driver=/usr/bin/clang*,/usr/bin/gcc*,/usr/bin/g++*,/usr/local/cuda/bin/nvcc,/usr/local/cuda-*/bin/nvcc,/opt/cuda/bin/nvcc,/opt/cuda-*/bin/nvcc"

local function has_arg_with_prefix(args, prefix)
  for _, arg in ipairs(args) do
    if vim.startswith(arg, prefix) then
      return true
    end
  end

  return false
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "cuda" } },
  },

  {
    "p00f/clangd_extensions.nvim",
    ft = { "c", "cpp", "objc", "objcpp", "cuda" },
  },

  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.clangd = opts.servers.clangd or {}

      local clangd = opts.servers.clangd
      if type(clangd.cmd) ~= "table" then
        clangd.cmd = { "clangd" }
      end

      if not has_arg_with_prefix(clangd.cmd, "--query-driver=") then
        table.insert(clangd.cmd, clangd_query_driver)
      end
    end,
  },

  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}

      for _, ft in ipairs({ "c", "cpp", "objc", "objcpp", "cuda" }) do
        opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or { "clang-format" }
      end
    end,
  },

  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      opts.sources.providers = opts.sources.providers or {}
      opts.sources.providers.snippets = opts.sources.providers.snippets or {}
      opts.sources.providers.snippets.opts = opts.sources.providers.snippets.opts or {}
      opts.sources.providers.snippets.opts.extended_filetypes =
        opts.sources.providers.snippets.opts.extended_filetypes or {}
      opts.sources.providers.snippets.opts.extended_filetypes.cuda =
        opts.sources.providers.snippets.opts.extended_filetypes.cuda or { "cpp", "c" }
    end,
  },
}
