local M = {}

M.defaults = {
    repos = {
        {
            path = vim.fn.expand("~/obsidian-notes"),
            sync_interval = 5,
            commit_template = "[{hostname}] vault sync: {timestamp}",
            auto_pull = true,
            auto_push = true,
        }
    },

    notifications = {
        level = "normal", -- "silent", "normal", "on_error_only"
    },

    git = {
        add_all = true,
        pull_before_push = true,
        handle_conflicts = "pause",
    }
}

M.options = {}

function M.setup(user_config)
    M.options = vim.tbl_deep_extend("force", M.defaults, user_config or {})
    return M.options
end

function M.get_watched_repos()
    return M.options.repos or {}
end

function M.should_sync_repo(repo_path)
    local resolved_path = vim.fn.resolve(repo_path)
    for _, repo in ipairs(M.get_watched_repos()) do
        if vim.fn.resolve(vim.fn.expand(repo.path)) == resolved_path then
            return true, repo
        end
    end
    return false, nil
end

return M
