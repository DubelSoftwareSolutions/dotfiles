return {
  {
    "dlyongemallo/diffview.nvim",
    cmd = {
      "DiffviewClose",
      "DiffviewDiffFiles",
      "DiffviewFileHistory",
      "DiffviewFocusFiles",
      "DiffviewLog",
      "DiffviewOpen",
      "DiffviewToggleFiles",
    },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview" },
      { "<leader>gD", "<cmd>DiffviewOpen HEAD~1<cr>", desc = "Diffview HEAD~1" },
      { "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", desc = "File History" },
      { "<leader>gF", "<cmd>DiffviewFileHistory<cr>", desc = "Repository History" },
      { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Close Diffview" },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
  },
}
