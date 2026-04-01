---
name: jj
description: "Jujutsu VCS for all version control: describe/commit changes, view history/diffs, rebase, squash, split, absorb, push/fetch, manage bookmarks, undo operations. Use instead of git for any VCS task."
argument-hint: "[describe | log | push | status | squash | absorb | split | rebase | bookmark | undo | or natural language]"
allowed-tools: "Bash, Read, Grep, Glob"
---

# Jujutsu (jj) VCS — Full Instructions

Use **jj (Jujutsu)** for ALL version control. NEVER run raw `git` commands.

## Core Mental Model

- **Working copy IS a change** — no staging area, no `add`. Every file edit is already part of the current change (`@`).
- **Change IDs are stable** — they survive rebases and amends. Always prefer change IDs (short hex like `kxqpslmn`) over commit IDs.
- **Bookmarks, not branches** — `jj bookmark` is the equivalent of git branches.
- **Automatic rebasing** — editing an ancestor change automatically rebases all descendants.
- **Conflicts are first-class** — stored in the tree, not blocking. You can keep working and resolve later.
- **Everything is undoable** — `jj op log` shows history, `jj op undo` reverts the last operation.
- **`jj commit` = `jj describe` + `jj new`** — use `jj commit -m "..."` as a convenient shorthand.

## Dispatch on $ARGUMENTS

| Argument | Action |
|----------|--------|
| *(empty)* or `describe` | **Describe workflow**: status, diff, log, then describe current change |
| `commit` | **Commit workflow**: describe + new in one step |
| `log` | Show change history |
| `status` or `st` | Show working-copy status |
| `diff` | Show current change diff |
| `push` | Push bookmarks to remote |
| `fetch` | Fetch from remote |
| `new` | Create new empty change |
| `squash` | Squash current change into parent |
| `absorb` | Auto-absorb hunks into ancestor changes |
| `split` | Split current change |
| `rebase` | Rebase changes |
| `bookmark` or `b` | Manage bookmarks |
| `undo` | Undo last operation |
| `show` | Show a specific change |
| *(other)* | Interpret as natural-language VCS request |

---

## Workflows

### 1. Describe / Commit (the primary workflow)

This is what you do most often — finalize the current change and move on.

```bash
# 1. Inspect what's in the current change
jj status
jj diff

# 2. Check recent history for style
jj log -r 'ancestors(@, 10)'

# 3a. Option A — describe then new (two steps, more control)
jj describe -m "feat: add charging profile validation

Implements JSON schema validation for SetChargingProfile requests.

Co-Authored-By: Claude <noreply@anthropic.com>"
jj new

# 3b. Option B — commit (describe + new in one step)
jj commit -m "feat: add charging profile validation

Implements JSON schema validation for SetChargingProfile requests.

Co-Authored-By: Claude <noreply@anthropic.com>"
```

**Description rules:**
- Follow Conventional Commits: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`
- First line: concise summary, under 72 characters
- Body (after blank line): explain **why**, not what — the diff shows the what
- End with: `Co-Authored-By: Claude <noreply@anthropic.com>`
- Analyze the actual diff to write an accurate description — never guess

### 2. Viewing History and Diffs

```bash
jj log                                  # Default log
jj log -r 'ancestors(@, 20)'            # Last 20 ancestors
jj log -r 'all()'                       # Everything
jj log -r 'bookmarks()'                 # Bookmarked changes
jj log --stat                           # With file change stats
jj log -r 'mine()'                      # Your changes only
jj log -r 'description(regex)'          # Search descriptions

jj diff                                 # Current change diff
jj diff -r <change_id>                  # Specific change diff
jj diff --from <a> --to <b>             # Diff between two changes
jj diff --stat                          # Summary stats only

jj show <change_id>                     # Description + diff of a change
jj evolog                               # How current change evolved over time
jj evolog -r <change_id>                # Evolution log of specific change
jj interdiff --from <a> --to <b>        # Compare what two changes *do* (patch-level diff)
```

### 3. Creating and Navigating Changes

```bash
jj new                                  # New change on top of @
jj new <change_id>                      # New change on top of specific change
jj new <a> <b>                          # New merge change with multiple parents
jj edit <change_id>                     # Set working copy to edit an existing change
jj next                                 # Move working copy to child revision
jj prev                                 # Move working copy to parent revision
jj abandon                              # Abandon current change
jj abandon <change_id>                  # Abandon specific change
```

### 4. Rewriting History

```bash
# Squash — move changes into parent or specific ancestor
jj squash                               # Squash @ into parent
jj squash --into <change_id>            # Squash @ into specific ancestor
jj squash -i                            # Interactively pick hunks to squash

# Absorb — automatically route hunks to the right ancestor
jj absorb                               # Auto-absorb all hunks from @
jj absorb <filesets>                    # Absorb only specific paths
jj absorb --from <rev> --into <revset>  # Control source and destinations

# Split — break a change into two
jj split                                # Interactively split current change
jj split <paths>                        # Split by file paths

# Rebase — move changes to new parents
jj rebase -r <src> -d <dst>             # Rebase single change
jj rebase -s <src> -d <dst>             # Rebase change + all descendants
jj rebase -b <change> -d <dst>          # Rebase entire branch

# Other rewrites
jj duplicate <change_id>                # Copy a change
jj revert -r <change_id>               # Create reverse of a change
jj diffedit                             # Edit the diff of @ with a diff editor
jj diffedit -r <change_id>             # Edit diff of specific change

# Advanced
jj parallelize <revset>                 # Make revisions siblings instead of ancestors
jj simplify-parents -r <revset>        # Remove redundant parent edges
jj fix                                  # Run configured formatters on changed files
jj arrange                              # Interactively rearrange the commit graph
```

### 5. Bookmarks (Branch Management)

```bash
jj bookmark list                        # List all bookmarks
jj bookmark create <name> -r @          # Create at current change
jj bookmark create <name> -r <rev>      # Create at specific change
jj bookmark set <name> -r @             # Move bookmark to current change
jj bookmark delete <name>               # Delete bookmark
jj bookmark rename <old> <new>          # Rename bookmark
jj bookmark track <name>@<remote>       # Track a remote bookmark
jj bookmark untrack <name>@<remote>     # Untrack a remote bookmark
```

### 6. Remote Operations (Git Interop)

```bash
# Fetch
jj git fetch                            # Fetch all remotes
jj git fetch --remote <name>            # Fetch specific remote

# Push
jj git push                             # Push all tracked bookmarks
jj git push --bookmark <name>           # Push specific bookmark
jj git push --change <change_id>        # Push change (auto-creates push-<id> bookmark)
jj git push --new-bookmark <name>       # First push of a new bookmark

# Common pattern: finish work and push
jj commit -m "feat: ..."
jj git push --change @-                 # Push the just-committed change
```

### 7. Undo and Recovery

```bash
jj op log                               # Show operation history
jj op undo                              # Undo last operation
jj undo                                 # Shorthand for jj op undo
jj redo                                 # Redo the most recently undone operation
jj op restore <op_id>                   # Restore repo to specific operation state
jj op show <op_id>                      # Show what an operation did
jj op show -p <op_id>                   # Show operation with patch/diff
```

### 8. Conflict Resolution

```bash
jj status                               # Shows conflicted files
jj resolve                              # Launch merge tool
jj resolve <path>                       # Resolve specific file
jj restore --from <rev> <path>          # Take a file from another revision
```

### 9. Workspace Management

```bash
jj workspace list                       # List workspaces
jj workspace add <path>                 # Create new workspace
jj workspace forget <name>              # Remove a workspace
jj workspace root                       # Print workspace root
```

### 10. File Operations

```bash
jj file list                            # List tracked files
jj file show <path> -r <rev>            # Show file at specific revision
jj file chmod <mode> <path>             # Change file permissions in change
```

---

## Revset Reference

Revsets are jj's powerful revision selection language. Use them with `-r` flags.

```
@                       # Working-copy change
@-                      # Parent of working copy
@--                     # Grandparent
<change_id>             # Specific change (short hex)
<change_id>-            # Parent of specific change

# Ancestors and descendants
ancestors(@, N)         # N ancestors of @
..@                     # All ancestors of @
@..                     # All descendants of @
<a>..<b>                # Changes reachable from b but not a

# Set operations
<a> | <b>               # Union
<a> & <b>               # Intersection
<a> ~ <b>               # Difference (in a, not in b)
~<a>                    # Complement

# Named sets
trunk()                 # Main/trunk bookmark
bookmarks()             # All bookmarked changes
remote_bookmarks()      # All remote bookmarks
tags()                  # All tags
heads(<revset>)         # Head changes in set
roots(<revset>)         # Root changes in set
mutable()               # All mutable (non-immutable) changes
immutable()             # All immutable changes

# Filtering
mine()                  # Changes authored by you
description(regex)      # Changes matching description
author(regex)           # Changes by author
committer(regex)        # Changes by committer
empty()                 # Empty changes (no diff)
merges()                # Merge changes
conflict()              # Changes with conflicts
connected(<revset>)     # Transitive closure of parent/child

# Useful combinations
mine() & mutable()                  # Your recent work
ancestors(@, 20) & ~empty()         # Last 20 non-empty ancestors
bookmarks() & mine()                # Your bookmarked changes
mutable() & conflict()              # Mutable changes with conflicts
reachable(@, mutable())             # All mutable changes reachable from @
```

---

## Important Rules

1. **NEVER run `git` commands** — always use `jj` equivalents.
2. **Working copy IS a change** — don't look for a staging step. Edits are already tracked.
3. **Use change IDs** over commit IDs — they're stable across rewrites.
4. **Always inspect before describing** — run `jj status` and `jj diff` first.
5. **Don't leave empty descriptions** — always describe before `jj new` / after `jj commit`.
6. **Confirm destructive operations** — `jj abandon`, `jj op undo`, `jj rebase`, `jj squash` can rewrite history. Always confirm with the user.
7. **Use `jj git push --change`** for ad-hoc pushes — auto-creates a `push-<id>` bookmark.
8. **Use `jj absorb` over manual squash** when spreading fixes across a stack — it routes hunks automatically.
9. **Use `jj interdiff`** to compare implementations or review what changed since last push.
10. **Use `jj op undo`** freely — every operation is reversible.
