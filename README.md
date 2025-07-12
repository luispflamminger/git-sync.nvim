# git-sync.nvim

A neovim plugin for automatic git repository synchronization with configurable intervals and repositories.

## Features

- Automatic periodic sync of configured git repositories
- Manual sync command `:GitSync`
- Configurable commit message templates
- Pull on startup

## Installation

Install using your favorite plugin manager, e.g. lazy.nvim:

```lua
{
    "luispflamminger/git-sync.nvim",
    opts = {
        repos = {
            {
                path = "~/obsidian-notes",
                sync_interval = 5, -- minutes
                commit_template = "[{hostname}] vault sync: {timestamp}",
                auto_pull = true,
                auto_push = true,
            }
        }
    }
}
```

## Full Configuration

```lua
require("git-sync").setup({
    repos = {
        {
            path = "~/obsidian-notes",
            sync_interval = 5, -- minutes
            commit_template = "[{hostname}] vault sync: {timestamp}",
            auto_pull = true,
            auto_push = true,
        }
    },
    
    notifications = {
        level = "normal", -- "silent", "normal", "on_error_only"
    },
    
    git = {
        add_all = true, -- vs only tracked files
        pull_before_push = true,
        handle_conflicts = "pause", -- "pause", "skip", "notify"
    }
})
```

## Commands

- `:GitSync` - Manually trigger sync for current repository

## Template Variables

Commit message templates support these variables:
- `{hostname}` - Current machine hostname
- `{timestamp}` - Current date and time

## Notification Levels

- `silent` - No notifications shown
- `normal` - Standard success/error notifications (default)
- `on_error_only` - Only show error notifications, suppress success messages

## Requirements

- nvim >= 0.7.0
- git
