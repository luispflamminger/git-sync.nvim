-- Simple Auto Git Sync for Neovim

local M = {}

-- Configuration
local config = {
    -- List of directories to auto-sync
    watched_repos = {
        vim.fn.expand("~/obsidian-notes"),
    },

    -- Sync interval in minutes
    sync_interval = 5,

    -- Pull on startup
    pull_on_startup = true,

    -- Push periodically
    push_enabled = true,
}

-- Simple notification
local function notify(msg, is_error)
    local level = is_error and vim.log.levels.ERROR or vim.log.levels.INFO
    vim.notify("[Git Sync] " .. msg, level)
end

-- Check if current directory should be synced
local function should_sync()
    local cwd = vim.fn.getcwd()
    for _, repo in ipairs(config.watched_repos) do
        if vim.fn.resolve(cwd) == vim.fn.resolve(repo) then
            return true
        end
    end
    return false
end

-- Run git command and handle result
local function git_cmd(cmd, callback)
    vim.fn.jobstart("git " .. cmd, {
        on_exit = function(_, exit_code, _)
            callback(exit_code == 0)
        end
    })
end

-- Sync current repository
local function sync_repo()
    if not should_sync() then
        return
    end

    local repo_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")

    -- Commit and push if enabled
    if config.push_enabled then
        -- Add all files
        git_cmd("add .", function(add_success)
            if add_success then
                -- Create commit message with hostname and timestamp
                local timestamp = os.date("%Y-%m-%d %H:%M:%S")
                local commit_msg = string.format("[mac] vault sync: %s", timestamp)

                git_cmd('commit -m "' .. commit_msg .. '"', function(commit_success)
                    if commit_success then
                        notify("✓ Committed " .. repo_name)
                    end

                    git_cmd("pull", function(pull_success)
                        if pull_success then
                            notify("✓ Pulled " .. repo_name)

                            git_cmd("push", function(push_success)
                                if push_success then
                                    notify("✓ Pushed " .. repo_name)
                                end
                            end)
                        end
                    end)
                end)
            end
        end)
    end
end

-- Setup
local function setup()
    local group = vim.api.nvim_create_augroup("GitSync", { clear = true })

    -- Pull on startup
    if config.pull_on_startup then
        vim.api.nvim_create_autocmd("VimEnter", {
            group = group,
            callback = function()
                vim.defer_fn(sync_repo, 1000)
            end,
        })
    end

    -- Periodic sync
    if config.sync_interval > 0 then
        local timer = vim.loop.new_timer()
        timer:start(config.sync_interval * 60 * 1000, config.sync_interval * 60 * 1000, function()
            vim.schedule(sync_repo)
        end)
    end

    -- Create user command
    vim.api.nvim_create_user_command("GitSync", function()
        sync_repo()
    end, { desc = "Manually sync git repository" })
end

-- Public API
M.setup = setup
M.config = config
M.sync = sync_repo

return M
