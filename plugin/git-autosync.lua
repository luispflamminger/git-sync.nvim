if vim.g.loaded_git_autosync then
    return
end
vim.g.loaded_git_autosync = 1

if vim.fn.has("nvim-0.7.0") == 0 then
    vim.api.nvim_err_writeln("git-autosync requires at least nvim-0.7.0")
    return
end