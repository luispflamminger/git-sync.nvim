if vim.g.loaded_git_sync then
    return
end
vim.g.loaded_git_sync = 1

if vim.fn.has("nvim-0.7.0") == 0 then
    vim.api.nvim_err_writeln("git-sync.nvim requires at least nvim-0.7.0")
    return
end
