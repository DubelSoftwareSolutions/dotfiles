return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "pyright",               -- Python LSP
        "clangd",                -- C++ LSP
        "cmake-language-server", -- CMake LSP (crucial for ROS2 CMakeLists.txt)
        "ruff",                  -- Extremely fast Python linter/formatter
      },
    },
  },
}

