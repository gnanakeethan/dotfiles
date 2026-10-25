---
name: tea
description: "Gitea CLI (tea) for interacting with Gitea repos: list/create/edit issues and pull requests, review PRs, manage releases, milestones, labels, notifications, repos, branches, and authenticated API calls. Use when working with a Gitea instance instead of `gh` for GitHub."
argument-hint: "[issues | pr | notifications | releases | repos | open | clone | api | whoami | or natural language]"
allowed-tools: "Bash, Read, Grep, Glob"
---

# tea — Gitea CLI

Use `tea` (the official Gitea CLI) for ALL Gitea operations — issues, PRs, releases, notifications, repo browsing, and authenticated API calls. The user is already logged in (`tea logins list` to confirm); do NOT run `tea login` unless explicitly asked.

`tea` auto-detects the Gitea login + repo from the current directory's `git remote` when run inside a clone. Outside a clone, pass `--repo <owner>/<name>` (`-r`) and/or `--login <name>` (`-l`).

## Default login (this machine)

- Login name: `gnanakeethan`
- URL: `https://git.cloudparallax.com`
- User: `gnanakeethan` (admin)

If a command needs a login but isn't run inside a Gitea clone, pass `--login gnanakeethan` (or `-l gnanakeethan`).

## Dispatch on $ARGUMENTS

| Argument | Action |
|----------|--------|
| *(empty)* | Run `tea whoami` and `tea notifications --mine` to show context |
| `issues` or `i` | Issue workflows (list/view/create/edit/close) |
| `pr` or `pulls` | Pull-request workflows (list/view/checkout/create/review/merge) |
| `notifications` or `n` | Notifications (list, mark read) |
| `releases` or `r` | Releases (list/create/edit/delete) |
| `repos` or `repo` | Repo info (list, search, view) |
| `branches` or `b` | List branches |
| `labels` | Manage issue labels |
| `milestones` or `ms` | List/create milestones |
| `open` or `o` | Open repo / issue / PR in browser |
| `clone <repo>` or `C` | Clone a repository |
| `api <path>` | Authenticated API call (use for anything not in a subcommand) |
| `whoami` | Show current user |
| *(other)* | Interpret as natural-language Gitea request |

Output formats: most list/show commands accept `-o json|yaml|csv|tsv|table|simple`. Default to `-o json` and pipe through `jq` when you need to consume the result programmatically — the default table output is for humans.

---

## Issues

```bash
# List open issues in current repo
tea issues

# Filter
tea issues --state open|closed|all
tea issues --labels bug,p1 --milestones v1.0
tea issues --assignee gnanakeethan --author someone
tea issues --keyword "search text"

# View one issue (with comments)
tea issues 42 --comments

# Create — non-interactive requires --title and --description
tea issues create --title "Title" --description "Body in markdown" \
  --labels bug --assignees gnanakeethan --milestone v1.0

# Edit / close / reopen
tea issues edit 42 --title "New title"
tea issues close 42
tea issues reopen 42

# Different repo
tea issues -r owner/name
tea issues -r owner/name 42 --comments
```

Body must be passed via `--description`. For multi-line bodies, use a heredoc:

```bash
tea issues create --title "Crash on login" --description "$(cat <<'EOF'
## Steps
1. Open app
2. Click login

## Expected
Logs in.

## Actual
Crashes.
EOF
)"
```

---

## Pull Requests

```bash
# List
tea pr                          # open PRs
tea pr --state all              # all
tea pr --state closed --lm 50

# View detail (include comments and CI)
tea pr 17 --comments

# Checkout locally (creates/switches branch tracking the PR head)
tea pr checkout 17

# Create — must be on the source branch (or pass --head)
tea pr create --title "feat: X" --description "Why" \
  --base main --head feature/x \
  --labels enhancement --assignees gnanakeethan \
  --allow-maintainer-edits

# Review interactively (prompts for comments + verdict)
tea pr review 17

# Approve / request-changes
tea pr approve 17
tea pr reject 17 -d "Needs tests"

# Merge / close / reopen
tea pr merge 17                 # default merge style from repo settings
tea pr close 17
tea pr reopen 17

# Cleanup local + remote branch after a closed PR
tea pr clean 17

# Review comments
tea pr review-comments 17
tea pr resolve <comment-id>
tea pr unresolve <comment-id>
```

PR creation requires the source branch to already be pushed to the remote. If `tea pr create` fails with "head branch not found", push first (`git push -u origin <branch>`) and retry.

---

## Notifications

```bash
tea notifications --mine                    # all unread across all repos
tea notifications --mine --states unread,pinned
tea notifications --types issue,pull --mine

tea notifications read <id>                 # mark one as read
tea notifications read --mine               # mark all filtered as read
tea notifications pin <id>
```

Default state filter is `unread,pinned`. Pass `--states all` (or specific) to widen.

---

## Releases

```bash
tea releases                                       # list
tea releases create --tag v1.2.3 --title "v1.2.3" \
  --note "Changelog body" --target main
tea releases create --tag v1.2.3 --draft
tea releases create --tag v1.2.3 --prerelease
tea releases create --tag v1.2.3 --asset ./dist/app.tar.gz --asset ./dist/app.zip

tea releases edit <tag> --title "..." --note "..."
tea releases delete <tag>
```

`tea releases create` will create the tag on the remote if it doesn't exist (use `--target` to pick the commit-ish).

---

## Repos / Branches / Labels / Milestones

```bash
tea repos list                              # repos accessible to you
tea repos search --keyword foo
tea repos                                   # show current repo

tea branches                                # list branches

tea labels                                  # list labels in current repo
tea labels create --name bug --color "#dd0000" --description "..."
tea labels delete <id>

tea milestones                              # list open milestones
tea milestones create --title v1.0 --description "..." --deadline 2026-12-31
```

---

## Open in browser / Clone

```bash
tea open                                    # repo home in browser
tea open issues 42
tea open pulls 17

tea clone owner/name                        # clone via the configured login
tea clone owner/name --depth 1
```

---

## Authenticated API (escape hatch)

For anything not exposed as a subcommand, hit the Gitea API directly. The Gitea API is OpenAPI-documented at `https://git.cloudparallax.com/api/swagger`.

```bash
# GET — print JSON
tea api repos/gnanakeethan/something | jq .

# Custom method + body
tea api -X POST repos/owner/name/issues/42/comments \
  -d '{"body":"Thanks for the report."}'

# PATCH (e.g. rename a repo)
tea api -X PATCH repos/owner/name -d '{"name":"new-name"}'

# Headers
tea api -H "Accept: application/json" users/gnanakeethan
```

Method flag is `-X` / `--method` (NOT `-m`). `-d` accepts a raw JSON string, `@file` to read a file, or `@-` for stdin. For typed fields without hand-rolling JSON, use `-f key=val` (string) or `-F key=val` (typed/@file/JSON). When a body is passed via `-f`/`-F`/`-d`, the method defaults to POST unless `-X` is set.

---

## Behavior rules

- **Don't re-login** — the user is already authenticated as `gnanakeethan` against `git.cloudparallax.com`. Never run `tea login`/`tea logins add` unless they explicitly ask.
- **Prefer the subcommand over `tea api`** when one exists — it gives nicer output and handles pagination.
- **Inside a Gitea clone**, omit `--login`/`--repo`; tea infers them. Outside, always pass them explicitly.
- **For automation/parsing**, use `-o json` and pipe to `jq`. Don't grep the human table output.
- **Multi-line bodies** must be heredoc'd into `--description` / `-d` — there's no `--body-file`.
- **Confirm before destructive actions** — `releases delete`, `labels delete`, `pr clean`, `pr merge` (especially without explicit user request), `notifications read --mine` (clears your inbox). Show the user what will happen first.
- **`tea` is for Gitea, not GitHub** — if the remote is GitHub, use `gh` instead.
- **Pagination**: list commands default to `--limit 30 --page 1`. Bump `--limit` (max varies by Gitea install) or paginate when you need more.
- **Don't mix git operations** — for branch/commit/push work, use the project's normal VCS (`git` or `jj`). `tea` only manages Gitea-side state.

## Quick reference: cross-cutting flags

These work on most subcommands:

| Flag | Purpose |
|------|---------|
| `-r, --repo owner/name` | Override repo (otherwise inferred from cwd remote) |
| `-R, --remote <name>` | Discover login from a specific git remote |
| `-l, --login <name>` | Use a specific configured login |
| `-o, --output json\|yaml\|csv\|tsv\|table\|simple` | Output format on list/show |
| `-f, --fields a,b,c` | Pick which fields appear in list output |
| `--page N --limit N` | Paginate |

Run `tea <command> --help` to see all flags for a subcommand. The CLI's help is authoritative — if this skill's examples drift from current `tea` behavior, trust `--help`.
