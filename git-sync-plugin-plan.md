# Git AutoSync Plugin Development Plan

## Overview
Convert the existing single-file git sync plugin into a proper multi-file Neovim plugin that can be distributed and managed via lazy.nvim or other plugin managers.

## Current State ✅ COMPLETED
- ✅ Restructured into proper plugin architecture
- ✅ Modular design with separate files for git, config, and main logic
- ✅ Configuration system with multi-repository support
- ✅ Template variables for commit messages
- ✅ Plugin entry point and README documentation

## Target Plugin Structure
```
nvim-git-autosync/
├── lua/git-autosync/
│   ├── init.lua          # Main setup and public API
│   ├── config.lua        # Configuration management and validation
│   ├── git.lua          # Git operations and command execution
│   ├── notifications.lua # User feedback and logging
│   ├── commands.lua     # User commands and autocommands
│   └── health.lua       # Health checks for :checkhealth
├── doc/git-autosync.txt  # Vim help documentation
├── plugin/git-autosync.lua # Plugin entry point
├── README.md            # Installation and usage guide
├── LICENSE              # MIT or similar
└── tests/               # Unit tests (optional but recommended)
    ├── git_spec.lua
    ├── config_spec.lua
    └── minimal_init.lua
```

## Key Improvements to Implement

### 1. Enhanced Error Handling
- Capture both stdout and stderr from git commands
- Smart stderr analysis (distinguish info vs error messages)
- Structured error types (network, conflict, auth, etc.)
- Better async error propagation

### 2. Configuration System
- User-configurable options with validation
- Per-repository configuration support
- Configurable commit message templates
- Environment-specific settings

### 3. Git Operations Improvements
- Pre-flight checks (repo validation, connectivity)
- Change detection to avoid unnecessary syncs
- Merge conflict detection and handling
- Support for multiple remotes
- Branch-aware operations

### 4. User Experience
- `:GitSyncStatus` command showing sync state
- Configurable notification levels (silent/normal/verbose)
- Progress indicators for long operations
- Manual conflict resolution workflows

### 5. Plugin Infrastructure
- Proper lazy loading support
- Health checks integration
- Help documentation
- Standard plugin conventions

## Implementation Steps

### Phase 1: Core Structure ✅ COMPLETED
1. ✅ Create plugin directory structure
2. ✅ Split existing code into modules:
   - ✅ Extract git operations to `git.lua`
   - ✅ Move config to `config.lua`
   - ✅ Create `init.lua` with setup function
3. ✅ Add plugin entry point
4. ✅ Basic README and installation instructions

### Phase 2: Enhanced Git Operations ✅ COMPLETED
1. ✅ Improve git command execution with better error handling
2. ✅ Add stderr analysis for smart error detection (then removed for transparency)
3. ✅ Implement change detection
4. ✅ Add pre-flight validation checks

### Phase 3: User Experience
1. Add status command and better notifications
2. Create health checks
3. Add help documentation
4. Implement configurable notification levels

### Phase 4: Polish & Distribution
1. Add comprehensive configuration validation
2. Write tests
3. Create detailed documentation
4. Prepare for public release

## Configuration API Design
```lua
require("git-autosync").setup({
  -- Repositories to watch
  repos = {
    {
      path = "~/obsidian-notes",
      sync_interval = 5, -- minutes
      commit_template = "[{hostname}] vault sync: {timestamp}",
      auto_pull = true,
      auto_push = true,
    }
  },
  
  -- Global settings
  notifications = {
    level = "normal", -- "silent", "normal", "verbose"
    on_error_only = false,
  },
  
  -- Git behavior
  git = {
    add_all = true, -- vs only tracked files
    pull_before_push = true,
    handle_conflicts = "pause", -- "pause", "skip", "notify"
  }
})
```

## Current Plugin Structure
```
git-sync.nvim/
├── lua/git-sync/
│   ├── init.lua          # ✅ Main setup and public API
│   ├── config.lua        # ✅ Configuration management
│   ├── git.lua          # ✅ Git operations
│   ├── notifications.lua # ✅ Notification system  
│   └── health.lua       # ✅ Health checks
├── plugin/git-sync.lua  # ✅ Plugin entry point
├── README.md            # ✅ Installation guide
└── git-sync-plugin-plan.md # Development plan
```

## Next Steps
Ready for **Phase 3: User Experience**

Phase 2 completed with additional improvements:
- ✅ Enhanced git command execution with stdout/stderr capture
- ✅ Removed error parsing for raw git error transparency  
- ✅ Cleaned up redundant callback parameters
- ✅ Added vim.uv/vim.loop API compatibility
- ✅ Fixed plugin initialization bug with auto-setup
- ✅ Added nil check for repo_config safety

## Development Setup
For local testing, add to lazy.nvim config:
```lua
{
    dir = "/Users/luisp/dev/personal/git-sync.nvim",
    name = "git-sync.nvim",
    opts = { ... }
}
```
