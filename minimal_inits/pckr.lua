vim.o.number = true
vim.o.autoread = true
vim.o.autowrite = true
vim.o.swapfile = false
vim.o.confirm = true

local function bootstrap_pckr()
  local pckr_path = vim.fn.stdpath("data") .. "/pckr/pckr.nvim"

  if not vim.loop.fs_stat(pckr_path) then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/lewis6991/pckr.nvim",
      pckr_path,
    })
  end

  vim.opt.rtp:prepend(pckr_path)
end

bootstrap_pckr()

require("pckr").add({
  {
    "~/github/linrongbin16/colorbox.nvim",
    config = function()
      require("colorbox").setup()
    end,
    run = function()
      require("colorbox").update()
    end,
  },
})
