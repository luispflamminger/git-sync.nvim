-- SPDX-FileCopyrightText: 2025 Luis Pfamminger
--
-- SPDX-License-Identifier: Apache-2.0

local M = {}

function M.notify(msg, is_error)
    local config = require("git-sync.config")
    local settings = config.options.notifications or {}
    local level_setting = settings.level or "normal"

    -- Skip all notifications if level is silent
    if level_setting == "silent" then
        return
    end

    -- Skip non-error notifications if level is on_error_only
    if level_setting == "on_error_only" and not is_error then
        return
    end

    local level = is_error and vim.log.levels.ERROR or vim.log.levels.INFO
    vim.notify("[Git Sync] " .. msg, level)
end

return M