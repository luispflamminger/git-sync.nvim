local M = {}

local function notify(msg, is_error)
    local level = is_error and vim.log.levels.ERROR or vim.log.levels.INFO
    vim.notify("[Git Sync] " .. msg, level)
end

function M.run_command(cmd, callback)
    vim.fn.jobstart("git " .. cmd, {
        on_exit = function(_, exit_code, _)
            callback(exit_code == 0)
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

function M.sync_repository(repo_path, commit_template)
    local repo_name = vim.fn.fnamemodify(repo_path, ":t")
    
    M.add_all(function(add_success)
        if add_success then
            local timestamp = os.date("%Y-%m-%d %H:%M:%S")
            local hostname = vim.fn.hostname()
            local commit_msg = commit_template
                :gsub("{timestamp}", timestamp)
                :gsub("{hostname}", hostname)

            M.commit(commit_msg, function(commit_success)
                if commit_success then
                    notify("✓ Committed " .. repo_name)
                end

                M.pull(function(pull_success)
                    if pull_success then
                        notify("✓ Pulled " .. repo_name)

                        M.push(function(push_success)
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

return M