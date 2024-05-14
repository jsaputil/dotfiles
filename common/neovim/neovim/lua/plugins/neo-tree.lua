return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      sources = {
        "filesystem",
        "buffers",
        "git_status",
      },
      source_selector = {
        winbar = true,
        show_scrolled_off_parent_node = false,
        statusline = false,
        content_layout = "center",
        sources = {
          { source = "filesystem" },
          { source = "buffers" },
          { source = "git_status" },
        },
      },
    },
  },
}
