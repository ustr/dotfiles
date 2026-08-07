vim.opt.number = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.expandtab = true
vim.opt.relativenumber = true

vim.opt.clipboard = "unnamedplus"

vim.keymap.set("v", ">", ">gv")
vim.keymap.set("v", "<", "<gv")

vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })

vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.nix", "*.sh", "*.zsh" },
  callback = function()
    local ft = vim.bo.filetype
    local view = vim.fn.winsaveview()
    
    if ft == "nix" then
      vim.cmd("%!nixpkgs-fmt")
    elseif ft == "sh" or ft == "zsh" then
      vim.cmd("%!shfmt -i 2")
    end
    
    vim.fn.winrestview(view)
  end,
})
