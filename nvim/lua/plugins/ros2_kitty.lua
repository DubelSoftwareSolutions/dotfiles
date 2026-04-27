-- ~/dotfiles/nvim/lua/plugins/ros2_kitty.lua
return {
  -- Seamless navigation between Kitty and Neovim splits
  {
    "knubie/vim-kitty-navigator",
    keys = {
      { "<C-h>", "<Cmd>KittyNavigateLeft<CR>", mode = {"n", "v", "i"}, desc = "Navigate Left" },
      { "<C-j>", "<Cmd>KittyNavigateDown<CR>", mode = {"n", "v", "i"}, desc = "Navigate Down" },
      { "<C-k>", "<Cmd>KittyNavigateUp<CR>", mode = {"n", "v", "i"}, desc = "Navigate Up" },
      { "<C-l>", "<Cmd>KittyNavigateRight<CR>", mode = {"n", "v", "i"}, desc = "Navigate Right" },
    }
  },  
  {
    "ErickKramer/nvim-ros2",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      -- picker = "telescope", -- Default
      autocmds = true,
      treesitter = true,
    },
    keys = {
      { "<leader>li", function() require("nvim-ros2").pickers.interfaces() end, desc = "[ROS 2]: List interfaces" },
      { "<leader>ln", function() require("nvim-ros2").pickers.nodes() end, desc = "[ROS 2]: List nodes" },
      { "<leader>la", function() require("nvim-ros2").pickers.actions() end, desc = "[ROS 2]: List actions" },
      { "<leader>lt", function() require("nvim-ros2").pickers.topics_info() end, desc = "[ROS 2]: List topics with info" },
      { "<leader>le", function() require("nvim-ros2").pickers.topics_echo() end, desc = "[ROS 2]: List topics with echo" },
      { "<leader>ls", function() require("nvim-ros2").pickers.services() end, desc = "[ROS 2]: List services" },
    },
  },
}
