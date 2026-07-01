return {
  {
    "folke/noice.nvim",
    opts = {
      notify = {
        timeout = 8000,
      },
      views = {
        mini = {
          win_options = {
            winblend = 0,
          },
          size = {
            width = 60,
          },
        },
      },
    },
    keys = {
      { "<leader>n", "<cmd>Noice telescope<cr>", desc = "Noice Log" },
    },
  },
}
