return {
  {
    "folke/noice.nvim",
    opts = {
      notify = {
        timeout = 8000,
      },
      views = {
        split = {
          enter = true,
        },
      },
      routes = {
        {
          filter = {
            event = "notify",
            min_level = vim.log.levels.WARN,
          },
          view = "split",
        },
        {
          filter = {
            event = "notify",
          },
          view = "split",
        },
      },
    },
    keys = {
      {
        "<leader>sn",
        function()
          require("noice").cmd("history")
        end,
        desc = "Notification History (Noice)",
      },
    },
  },
}
