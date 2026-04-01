# shadcn-svelte CLI Reference

## init

Initialize a new project. Run from the `frontend/` directory.

```bash
pnpm dlx shadcn-svelte@latest init
```

Options:
- `--preset <preset>` — design system preset
- `--base-color <name>` — choices: neutral, stone, zinc, mauve, olive, mist, taupe
- `--css <path>` — path to global CSS file
- `--lib-alias <path>` — import alias for lib (default: `$lib`)
- `--components-alias <path>` — import alias for components
- `--utils-alias <path>` — import alias for utils
- `--hooks-alias <path>` — import alias for hooks
- `--ui-alias <path>` — import alias for ui components
- `-o, --overwrite` — overwrite existing files
- `--no-deps` — skip dependency installation
- `--skip-preflight` — ignore preflight checks

## add

Add components to the project.

```bash
pnpm dlx shadcn-svelte@latest add [component...] [options]
```

Examples:
```bash
pnpm dlx shadcn-svelte@latest add button
pnpm dlx shadcn-svelte@latest add button card dialog -y -o
pnpm dlx shadcn-svelte@latest add --all -y -o
```

Options:
- `-y, --yes` — skip confirmation prompt
- `-o, --overwrite` — overwrite existing files
- `-a, --all` — install all components
- `--no-deps` — skip package dependency installation
- `-c, --cwd <path>` — working directory

## registry build

Build registry JSON files for publishing custom components.

```bash
pnpm dlx shadcn-svelte@latest registry build [registry.json]
```

Options:
- `-o, --output <path>` — destination directory (default: `./static/r`)

## Proxy

Set `HTTP_PROXY` or `http_proxy` environment variable for proxy support.
