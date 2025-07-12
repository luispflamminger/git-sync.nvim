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

local function validate_config(config)
    local errors = {}

    -- Validate repos
    if not config.repos or type(config.repos) ~= "table" then
        table.insert(errors, "repos must be a table")
    else
        for i, repo in ipairs(config.repos) do
            if type(repo) ~= "table" then
                table.insert(errors, string.format("repos[%d] must be a table", i))
            else
                if not repo.path or type(repo.path) ~= "string" or repo.path == "" then
                    table.insert(errors, string.format("repos[%d].path must be a non-empty string", i))
                end

                if repo.sync_interval and (type(repo.sync_interval) ~= "number" or repo.sync_interval < 0) then
                    table.insert(errors, string.format("repos[%d].sync_interval must be a non-negative number", i))
                end

                if repo.commit_template and type(repo.commit_template) ~= "string" then
                    table.insert(errors, string.format("repos[%d].commit_template must be a string", i))
                end

                if repo.auto_pull ~= nil and type(repo.auto_pull) ~= "boolean" then
                    table.insert(errors, string.format("repos[%d].auto_pull must be a boolean", i))
                end

                if repo.auto_push ~= nil and type(repo.auto_push) ~= "boolean" then
                    table.insert(errors, string.format("repos[%d].auto_push must be a boolean", i))
                end
            end
        end
    end

    -- Validate notifications
    if config.notifications then
        if type(config.notifications) ~= "table" then
            table.insert(errors, "notifications must be a table")
        else
            if config.notifications.level then
                local valid_levels = { "silent", "normal", "on_error_only" }
                if not vim.tbl_contains(valid_levels, config.notifications.level) then
                    table.insert(errors, "notifications.level must be one of: " .. table.concat(valid_levels, ", "))
                end
            end
        end
    end

    -- Validate git config
    if config.git then
        if type(config.git) ~= "table" then
            table.insert(errors, "git must be a table")
        else
            if config.git.add_all ~= nil and type(config.git.add_all) ~= "boolean" then
                table.insert(errors, "git.add_all must be a boolean")
            end

            if config.git.pull_before_push ~= nil and type(config.git.pull_before_push) ~= "boolean" then
                table.insert(errors, "git.pull_before_push must be a boolean")
            end

            if config.git.handle_conflicts then
                local valid_conflicts = { "pause", "skip", "notify" }
                if not vim.tbl_contains(valid_conflicts, config.git.handle_conflicts) then
                    table.insert(errors, "git.handle_conflicts must be one of: " .. table.concat(valid_conflicts, ", "))
                end
            end
        end
    end

    return errors
end
function M.setup(user_config)
    local config = vim.tbl_deep_extend("force", M.defaults, user_config or {})

    -- Validate configuration
    local validation_errors = validate_config(config)
    if #validation_errors > 0 then
        local error_msg = "git-sync.nvim configuration errors:\n" .. table.concat(validation_errors, "\n")
        vim.api.nvim_err_writeln(error_msg)
        return nil
    end

    M.options = config
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
