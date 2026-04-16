# scs

Personal script archive focused primarily on Roblox Lua experiments, utility scripts, UI work, and small helper tools.

> This repository is best understood as a mixed personal collection rather than a single packaged framework.  
> It contains standalone scripts, UI experiments, archived files, and game-specific prototypes kept in one place.

---

## Overview

`scs` is a personal repository that gathers many independent Lua scripts and a few supporting assets.  
The contents range from general utilities and UI code to game-specific experiments, testing files, archived snippets, and local helper scripts.

The repository is especially centered around:

- Roblox Lua scripting
- reusable UI experimentation
- personal script backups
- quick utility and testing files
- archived one-off prototypes

One of the most structured files in the repository is `uibox.lua`, which acts like a reusable UI library with support for window creation, tabs, buttons, toggles, inputs, and window state controls such as minimize, maximize, and destroy.

---

## Repository Style

This repository is **not organized as a formal package** with a strict module structure.  
Instead, it reflects an evolving personal workspace where scripts are collected, tested, modified, and archived over time.

Because of that, you should expect:

- inconsistent naming between files
- standalone scripts that are not connected to each other
- archived or outdated files mixed with newer ones
- game-specific scripts beside general-purpose utilities
- experimentation-oriented code rather than a single release-ready product

---

## Main Categories

### 1. UI / Framework Work
Files in this group are focused on reusable interface systems or interface experiments.

Examples:
- `uibox.lua`
- `coolkid ui.lua`
- `dakxun ui.lua`

These files are useful if you want to inspect or reuse visual structure, control creation, layout logic, or interaction patterns.

---

### 2. General Utility Scripts
Scripts that provide convenience features or quality-of-life behavior.

Examples:
- `anti afk.lua`
- `rejoin.lua`
- `clearerror.lua`
- `copy avatar.lua`
- `id change.lua`

These are generally small, direct scripts made for a specific task.

---

### 3. Game-Specific Scripts
A large part of the repository is made of scripts targeting particular Roblox experiences or scenarios.

Examples:
- `doors.lua`
- `rivals.lua`
- `3008.lua`
- `phantom force esp.lua`
- `midnight chaser auto farm .lua`
- `prison breaker 1.5.lua`

These files are usually self-contained and may depend heavily on the structure of the target game.

---

### 4. Movement / Physics / Interaction Experiments
Files in this area appear to test movement behavior, part interaction, or physical manipulation.

Examples:
- `walk on walls.lua`
- `222walk on walls.lua`
- `gravity.lua`
- `seat boost.lua`
- `veh velocity.lua`
- `vech speed.lua`
- `part ring.lua`
- `fe grab part.lua`

---

### 5. Archived / Miscellaneous Files
Some files appear to be preserved for reference, experiments, older versions, or unrelated local tooling.

Examples:
- `.ct` Cheat Engine tables
- `.bat` helper files
- `.txt` notes / raw snippets / paths
- font and image assets
- presentation or document leftovers

This category reflects the repository’s archival nature.

---

## Featured File: `uibox.lua`

`uibox.lua` is one of the most reusable parts of the repository.

### What it provides
- window creation
- tab-based layout
- button controls
- toggle controls
- input controls
- label / paragraph style helpers
- window destroy support
- maximize / minimize window state handling

### Why it matters
If this repository has a “core reusable component,” `uibox.lua` is the closest thing to it.  
It is the best entry point for anyone trying to understand the more polished side of the codebase.

### Intended use
Use `uibox.lua` when you want a custom Roblox UI shell for:
- tool menus
- debugging panels
- script loaders
- personal interfaces
- tabbed utilities

---

## Example Usage

Basic example structure for the UI library:

```lua
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/EnzoLisianthus/scs/refs/heads/main/uibox.lua"))()

local win = UI:CreateWindow("Test Window")

local mainTab = win:CreateTab("Main")
mainTab:AddButton("Print Hello", function()
    print("Hello")
end)

mainTab:AddToggle("Example Toggle", function(state)
    print("Toggle:", state)
end, false)

mainTab:AddInput("Example Input", function(text, enterPressed)
    print("Input:", text, enterPressed)
end, "Type here...")
