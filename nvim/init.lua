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
  pattern = { "*.nix", "*.sh", "*.zsh", "*.tex" },
  callback = function()
    local ft = vim.bo.filetype
    local view = vim.fn.winsaveview()

    if ft == "nix" then
      vim.cmd("%!nixpkgs-fmt")
    elseif ft == "sh" or ft == "zsh" then
      vim.cmd("%!shfmt -i 2")
    elseif ft == "tex" then
      vim.cmd("%!tex-fmt --stdin 2>/dev/null")
    end

    vim.fn.winrestview(view)
  end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.tex",
  callback = function(args)
    local file = vim.api.nvim_buf_get_name(args.buf)
    local directory = vim.fs.dirname(file)
    local filename = vim.fs.basename(file)

    vim.system({
      "pdflatex",
      "-interaction=nonstopmode",
      "-halt-on-error",
      filename,
    }, {
      cwd = directory,
      text = true,
    }, function(result)
      vim.schedule(function()
        if result.code == 0 then
          vim.notify("LaTeX compiled successfully")
        else
          local output = result.stderr ~= "" and result.stderr or result.stdout
          vim.notify("LaTeX compilation failed:\n" .. output, vim.log.levels.ERROR)
        end
      end)
    end)
  end,
})
