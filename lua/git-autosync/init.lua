local config = require("git-autosync.config")
local git = require("git-autosync.git")

local M = {}

local timers = {}

local function sync_repo()
    local cwd = vim.fn.getcwd()
    local should_sync, repo_config = config.should_sync_repo(cwd)

    if not should_sync or not repo_config then
        return
    end

    if repo_config.auto_push then
        git.sync_repository(cwd, repo_config.commit_template)
    end
end

local function setup_autocommands()
    local group = vim.api.nvim_create_augroup("GitAutoSync", { clear = true })

    vim.api.nvim_create_autocmd("VimEnter", {
        group = group,
        callback = function()
            vim.defer_fn(sync_repo, 1000)
        end,
    })
end

local function setup_timers()
    for _, repo in ipairs(config.get_watched_repos()) do
        if repo.sync_interval > 0 then
            local timer = (vim.uv or vim.loop).new_timer()
            timer:start(
                repo.sync_interval * 60 * 1000,
                repo.sync_interval * 60 * 1000,
                function()
                    vim.schedule(function()
                        local cwd = vim.fn.getcwd()
                        local expanded_path = vim.fn.expand(repo.path)
                        if vim.fn.resolve(cwd) == vim.fn.resolve(expanded_path) then
                            sync_repo()
                        end
                    end)
                end
            )
            table.insert(timers, timer)
        end
    end
end

local function setup_commands()
    vim.api.nvim_create_user_command("GitSync", function()
        sync_repo()
    end, { desc = "Manually sync git repository" })
end

function M.setup(user_config)
    -- Prevent duplicate setup
    if vim.g.git_autosync_setup_done then
        return
    end
    vim.g.git_autosync_setup_done = 1
    
    config.setup(user_config)
    setup_autocommands()
    setup_timers()
    setup_commands()
end

M.sync = sync_repo
M.config = config

return M
