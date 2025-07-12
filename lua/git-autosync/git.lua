local M = {}

local function notify(msg, is_error)
    local level = is_error and vim.log.levels.ERROR or vim.log.levels.INFO
    vim.notify("[Git Sync] " .. msg, level)
end

function M.run_command(cmd, callback)
    local stdout_lines = {}
    local stderr_lines = {}
    vim.fn.jobstart("git " .. cmd, {
        stdout_buffered = true,
        stderr_buffered = true,
        on_stdout = function(_, data)
            if data then
                vim.list_extend(stdout_lines, data)
            end
        end,
        on_stderr = function(_, data)
            if data then
                vim.list_extend(stderr_lines, data)
            end
        end,
        on_exit = function(_, exit_code, _)
            local stdout = table.concat(stdout_lines, "\n")
            local stderr = table.concat(stderr_lines, "\n")

            callback({
                success = exit_code == 0,
                exit_code = exit_code,
                stdout = stdout,
                stderr = stderr
            })
        end
    })
end

function M.add_all(callback)
    M.run_command("add .", callback)
end

function M.commit(message, callback)
    M.run_command('commit -m "' .. message .. '"', callback)
end

function M.pull(callback)
    M.run_command("pull", callback)
end

function M.push(callback)
    M.run_command("push", callback)
end

function M.status(callback)
    M.run_command("status --porcelain", function(result)
        result.has_changes = result.success and result.stdout ~= ""
        callback(result)
    end)
end

function M.check_repo_status(callback)
    M.run_command("rev-parse --git-dir", function(result)
        if not result.success then
            result.status_type = "not_a_repo"
            callback(result)
            return
        end

        M.run_command("remote get-url origin", function(remote_result)
            if not remote_result.success then
                remote_result.status_type = "no_remote"
                callback(remote_result)
                return
            end

            callback({ success = true, status_type = "valid", repo_valid = true, has_remote = true })
        end)
    end)
end
function M.sync_repository(repo_path, commit_template)
    local repo_name = vim.fn.fnamemodify(repo_path, ":t")

    -- Pre-flight checks
    M.check_repo_status(function(result)
        if not result.success then
            if result.status_type == "not_a_repo" then
                notify("Skipping " .. repo_name .. " - not a git repository", true)
            elseif result.status_type == "no_remote" then
                notify("Skipping " .. repo_name .. " - no remote configured", true)
            end
            return
        end

        -- Check for changes before attempting sync
        M.status(function(status_result)
            if not status_result.has_changes then
                -- No changes, but still pull to get remote updates
                M.pull(function(pull_result)
                    if pull_result.success and pull_result.stdout:match("Already up to date") then
                        -- Silent - no notification for "already up to date"
                    elseif pull_result.success then
                        notify("✓ Pulled updates for " .. repo_name)
                    else
                        notify("Failed to pull: " .. pull_result.stderr, true)
                    end
                end)
                return
            end

            -- Proceed with full sync if there are changes
            M.add_all(function(add_result)
                if add_result.success then
                    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
                    local hostname = vim.fn.hostname()
                    local commit_msg = commit_template
                        :gsub("{timestamp}", timestamp)
                        :gsub("{hostname}", hostname)

                    M.commit(commit_msg, function(commit_result)
                        if commit_result.success then
                            notify("✓ Committed " .. repo_name)
                        elseif commit_result.stderr:match("nothing to commit") then
                            -- This is fine, just continue to pull
                        else
                            notify("Failed to commit: " .. commit_result.stderr, true)
                            return
                        end

                        M.pull(function(pull_result)
                            if pull_result.success then
                                notify("✓ Pulled " .. repo_name)
                            else
                                notify("Failed to pull: " .. pull_result.stderr, true)
                                return
                            end

                            M.push(function(push_result)
                                if push_result.success then
                                    notify("✓ Pushed " .. repo_name)
                                else
                                    notify("Failed to push: " .. push_result.stderr, true)
                                end
                            end)
                        end)
                    end)
                else
                    notify("Failed to add files: " .. add_result.stderr, true)
                end
            end)
        end)
    end)
end

return M
