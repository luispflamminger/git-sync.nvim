# git-autosync.nvim

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
    "luispflamminger/git-autosync.nvim",
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
require("git-autosync").setup({
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
        level = "normal", -- "silent", "normal", "verbose"
        on_error_only = false,
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

## Requirements

- nvim >= 0.7.0
- git
