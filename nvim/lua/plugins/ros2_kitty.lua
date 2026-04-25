-- ~/dotfiles/nvim/lua/plugins/ros2_kitty.lua
return {
  -- Seamless navigation between Kitty and Neovim splits
  {
    "knubie/vim-kitty-navigator",
    build = "cp ./*.py ~/.config/kitty/",
    keys = {
      { "<C-h>", "<Cmd>KittyNavigateLeft<CR>", mode = {"n", "v", "i"}, desc = "Navigate Left" },
      { "<C-j>", "<Cmd>KittyNavigateDown<CR>", mode = {"n", "v", "i"}, desc = "Navigate Down" },
      { "<C-k>", "<Cmd>KittyNavigateUp<CR>", mode = {"n", "v", "i"}, desc = "Navigate Up" },
      { "<C-l>", "<Cmd>KittyNavigateRight<CR>", mode = {"n", "v", "i"}, desc = "Navigate Right" },
    }
  },
  
  -- ROS 2 Telescope Integration (Find ROS packages, topics, and nodes easily)
  {
    "ErickKramer/nvim-ros2",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("nvim-ros2").setup({
        telescope = true,
      })
    end,
  },
}

