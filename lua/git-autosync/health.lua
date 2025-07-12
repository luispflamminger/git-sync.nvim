local M = {}

local function check_git()
    local handle = io.popen("git --version 2>/dev/null")
    if not handle then
        return false, "git command not found"
    end

    local result = handle:read("*a")
    handle:close()

    if not result or result == "" then
        return false, "git command failed"
    end

    local version = result:match("git version ([%d%.]+)")
    if not version then
        return false, "could not parse git version"
    end

    return true, "git version " .. version
end

local function check_neovim_version()
    local version = vim.version()
    local required = { 0, 7, 0 }

    if version.major > required[1] or
        (version.major == required[1] and version.minor > required[2]) or
        (version.major == required[1] and version.minor == required[2] and version.patch >= required[3]) then
        return true, string.format("nvim %d.%d.%d", version.major, version.minor, version.patch)
    else
        return false, string.format("nvim %d.%d.%d (requires >= %d.%d.%d)",
            version.major, version.minor, version.patch,
            required[1], required[2], required[3])
    end
end

local function check_config()
    local config = require("git-autosync.config")

    if not config.options or vim.tbl_isempty(config.options) then
        return false, "plugin not configured - run setup() first"
    end

    local repos = config.get_watched_repos()
    if not repos or #repos == 0 then
        return false, "no repositories configured"
    end

    return true, string.format("%d repositories configured", #repos)
end

local function check_repositories()
    local config = require("git-autosync.config")
    local results = {}

    for _, repo in ipairs(config.get_watched_repos()) do
        local expanded_path = vim.fn.expand(repo.path)
        local repo_name = vim.fn.fnamemodify(expanded_path, ":t")

        if vim.fn.isdirectory(expanded_path) == 0 then
            table.insert(results, {
                repo = repo_name,
                status = "error",
                message = "directory does not exist: " .. expanded_path
            })
        else
            -- Check if it's a git repo with remote
            local old_cwd = vim.fn.getcwd()
            vim.cmd("cd " .. vim.fn.fnameescape(expanded_path))

            -- Check if it's a git repo using synchronous commands
            local git_dir_result = vim.fn.system("git rev-parse --git-dir 2>/dev/null")
            if vim.v.shell_error ~= 0 then
                table.insert(results, {
                    repo = repo_name,
                    status = "error",
                    message = "not a git repository"
                })
            else
                -- Check for remote
                local remote_result = vim.fn.system("git remote get-url origin 2>/dev/null")
                if vim.v.shell_error ~= 0 then
                    table.insert(results, {
                        repo = repo_name,
                        status = "warn",
                        message = "git repository but no remote configured"
                    })
                else
                    table.insert(results, {
                        repo = repo_name,
                        status = "ok",
                        message = "valid git repository with remote"
                    })
                end
            end

            vim.cmd("cd " .. vim.fn.fnameescape(old_cwd))
        end
    end

    return results
end

function M.check()
    vim.health.start("git-autosync")

    -- Check Neovim version
    local nvim_ok, nvim_msg = check_neovim_version()
    if nvim_ok then
        vim.health.ok("Neovim version: " .. nvim_msg)
    else
        vim.health.error("Neovim version: " .. nvim_msg)
    end

    -- Check git installation
    local git_ok, git_msg = check_git()
    if git_ok then
        vim.health.ok("Git installation: " .. git_msg)
    else
        vim.health.error("Git installation: " .. git_msg)
        return -- No point checking further without git
    end

    -- Check plugin configuration
    local config_ok, config_msg = check_config()
    if config_ok then
        vim.health.ok("Plugin configuration: " .. config_msg)
    else
        vim.health.error("Plugin configuration: " .. config_msg)
        return -- No point checking repos without config
    end

    -- Check notification configuration
    local config = require("git-autosync.config")
    local notif_level = config.options.notifications and config.options.notifications.level or "normal"
    local valid_levels = { "silent", "normal", "on_error_only" }

    if vim.tbl_contains(valid_levels, notif_level) then
        vim.health.ok("Notification level: " .. notif_level)
    else
        vim.health.warn("Invalid notification level: " ..
            notif_level .. " (should be: " .. table.concat(valid_levels, ", ") .. ")")
    end

    -- Check if setup was called
    if vim.g.git_autosync_setup_done then
        vim.health.ok("Plugin setup completed")
    else
        vim.health.warn("Plugin setup not detected - autocommands and timers may not be active")
    end

    -- Check repositories
    vim.health.info("Configured repositories:")
    local repo_results = check_repositories()

    for _, result in ipairs(repo_results) do
        if result.status == "ok" then
            vim.health.ok(result.repo .. ": " .. result.message)
        elseif result.status == "warn" then
            vim.health.warn(result.repo .. ": " .. result.message)
        else
            vim.health.error(result.repo .. ": " .. result.message)
        end
    end
end

return M
