# git-sync.nvim

A Neovim plugin for automatic git repository synchronization with configurable intervals and repositories.

## Features

- **Automatic periodic sync** - Sync configured repositories at set intervals
- **Manual sync command** - `:GitSync` for on-demand synchronization  
- **Multi-repository support** - Configure multiple repositories with different settings
- **Smart change detection** - Only syncs when there are actual changes
- **Configurable notifications** - Silent, normal, or error-only notification modes
- **Configurable commit messages** - Customize commit messages with dynamic variables

### How it works

The plugin automatically:
1. Detects changes in your configured repositories
2. Adds and commits changes with your custom message template
3. Pulls latest changes from remote
4. Pushes your commits to remote

If you open up a repository configured for sync in Neovim, sync is triggered on startup and at configured intervals.
Note that sync is only enabled if `vim.fn.getcwd()` matches a path in set in `repos`.

## Requirements & Installation

**Requirements:**
- Neovim >= 0.7.0
- git

**Installation with lazy.nvim:**

```lua
{
    "luispflamminger/git-sync.nvim",
    opts = {
        repos = {
            {
                path = "~/personal-notes",
                sync_interval = 5, -- sync every 5 minutes
                commit_template = "[{hostname}] vault sync: {timestamp}",
            }
        }
    }
}
```

**Manual setup:**

```lua
require("git-sync").setup({
    repos = {
        {
            path = "~/personal-notes",
            sync_interval = 5,
            commit_template = "[{hostname}] vault sync: {timestamp}",
        }
    }
})
```

## Configuration

Complete configuration with all available options:

```lua
require("git-sync").setup({
    repos = {
        {
            path = "~/personal-notes",              -- Path to git repository (required)
            sync_interval = 5,                     -- Sync interval in minutes (default: 5, set to 0 to disable)
            commit_template = "[{hostname}] vault sync: {timestamp}",  -- Commit message template
            auto_pull = true,                      -- Pull before pushing (default: true)
            auto_push = true,                      -- Push after committing (default: true)
        },
        {
            path = "~/documents", 
            sync_interval = 0,                     -- Manual sync only
            commit_template = "docs update: {timestamp}",
            auto_pull = true,
            auto_push = false,                     -- Commit but don't push
        }
    },
    
    notifications = {
        level = "normal",                          -- "silent", "normal", "on_error_only" (default: "normal")
    },
    
    git = {
        add_all = true,                           -- Add all files vs only tracked files (default: true)
        pull_before_push = true,                  -- Pull before pushing (default: true)
        handle_conflicts = "pause",               -- "pause", "skip", "notify" (default: "pause")
    }
})
```

## Usage

### Commands

**`:GitSync`** - Manually trigger sync for the current repository if it's configured for syncing.

### Template Variables

Commit message templates support these variables:

- **`{hostname}`** - Current machine hostname
- **`{timestamp}`** - Current date and time (YYYY-MM-DD HH:MM:SS format)

**Example:**
```lua
commit_template = "[{hostname}] vault sync: {timestamp}"
-- Results in: "[macbook] vault sync: 2024-01-15 14:30:22"
```

### Notification Levels

- **`silent`** - No notifications shown
- **`normal`** - Standard success/error notifications (default)
- **`on_error_only`** - Only show error notifications, suppress success messages

## Troubleshooting

- Run `:checkhealth git-sync` for diagnostics including plugin configuration, repository status, and git connectivity.
- Verify that your repository is set up in `repos.path`
- Ensure you open the exact repository root directory in Neovim. If you open a subdirectory within a configured repo, sync will not be triggered.
- Verify that git is working manually with `git pull` and `git push`
