-- before anything register the .mond file extension
vim.filetype.add({
  extension = {
    mond = "mond",
  },
})

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
