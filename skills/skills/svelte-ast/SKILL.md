---
name: svelte-ast
description: "Parse Svelte/SvelteKit files using AST to extract props, state, derived, effects, functions, types, imports, snippets, and template usage. Use when exploring Svelte codebases, understanding component APIs, or finding symbols."
argument-hint: "[path] [--kind prop|state|derived|effect|function|const|var|type|interface|import|snippet|component-use|binding|action] [--filter name] [--detail] [--json] [--ts]"
allowed-tools: "Bash, Read, Grep, Glob"
---

# Svelte AST Reader

Use the `svast` CLI tool to parse Svelte, TypeScript, and JavaScript files using the Svelte compiler and TypeScript compiler APIs. This gives accurate, structured information about Svelte components without reading entire files.

## Tool Location

Binary: `svast` (npm-linked globally)
Source: `${CLAUDE_SKILL_DIR}/bin/svast.mjs`

## Usage

```bash
svast [flags] <path>
```

| Flag | Short | Description |
|------|-------|-------------|
| `--detail` | `-d` | Show detailed info (propsType, initializers, template symbols) |
| `--json` | `-j` | Output as JSON instead of text |
| `--kind <k>` | `-k` | Filter by kind (see kinds below) |
| `--filter <s>` | `-f` | Substring match on symbol names |
| `--name <s>` | `-n` | Exact name match |
| `--ts` | `-t` | Include `.ts`/`.js` files when scanning directories |
| `--help` | `-h` | Show usage help |

`<path>` can be a single `.svelte`/`.ts`/`.js` file or a directory (recursively scans, skipping `node_modules`, `.svelte-kit`, `dist`).

## Symbol Kinds

| Kind | Description |
|------|-------------|
| `prop` | `$props()` destructured properties |
| `state` | `$state()` / `$state.raw()` reactive variables |
| `derived` | `$derived()` / `$derived.by()` computed values |
| `effect` | `$effect()` / `$effect.pre()` side effects |
| `function` | Function declarations |
| `const` | Constant declarations |
| `var` | Let/var declarations |
| `type` | TypeScript type aliases |
| `interface` | TypeScript interfaces |
| `import` | Import statements |
| `snippet` | Svelte 5 `{#snippet}` blocks |
| `component-use` | Component usage in template (detail/filter only) |
| `binding` | `bind:` directives (detail/filter only) |
| `action` | `use:` directives (detail/filter only) |

## Dispatch on $ARGUMENTS

| Argument | Action |
|----------|--------|
| *(empty)* | Scan current directory for `.svelte` files |
| `<path>` | Parse the given file or directory |
| `<path> --detail` | Parse with full details (propsType, initializers, template) |
| `<path> --kind prop` | Show only props |
| `<path> --kind state` | Show only state variables |
| `<path> --kind function` | Show only functions |
| `<path> --kind snippet` | Show only snippet blocks |
| `<path> --kind import` | Show all imports |
| `<path> --ts` | Include `.ts`/`.js` files in directory scan |
| `<path> --json` | Output as JSON for programmatic use |
| `<path> --filter Button` | Find symbols matching "Button" |

## Examples

### List all symbols in a component
```bash
svast ./src/lib/components/Button.svelte
```

### Show props for all components in a directory
```bash
svast -k prop ./src/lib/components/ui/
```

### Show detailed component info (including template usage)
```bash
svast -d ./src/lib/components/Sidebar.svelte
```

### Find all state variables across components
```bash
svast -k state ./src/lib/components/
```

### Find all snippets in the project
```bash
svast -k snippet ./src/
```

### Include TypeScript files (SvelteKit routes)
```bash
svast -t ./src/routes/
```

### Show all functions matching a name
```bash
svast -k function -f handle ./src/
```

### JSON output for processing
```bash
svast -j -d ./src/lib/components/Button.svelte
```

### Find a specific symbol by exact name
```bash
svast -n open ./src/lib/components/ui/sidebar/
```

## SvelteKit File Type Detection

The tool automatically categorizes files:

| File | Type shown |
|------|------------|
| `+page.svelte` | `page` |
| `+layout.svelte` | `layout` |
| `+error.svelte` | `error-page` |
| `+page.server.ts` | `page-server` |
| `+page.ts` | `page-load` |
| `+layout.server.ts` | `layout-server` |
| `+server.ts` | `api-endpoint` |
| Other `.svelte` | `component` |
| Other `.ts`/`.js` | `module` |

## Output Format (text)

```
component sidebar-provider.svelte  (/path/to/sidebar-provider.svelte)
  lang=ts, module, style

--- IMPORTs ---
  import { cn } from "$lib/utils.js"  [line 3]
  import type { HTMLAttributes } from "svelte/elements"  [line 4]
--- PROPs ---
  prop children  [line 19]
  prop open = $bindable(true)  [line 15]
  prop ref = $bindable(null)  [line 14]
--- STATEs ---
  let count = $state(0)  [line 22]
--- DERIVEDs ---
  let doubled = $derived(...)  [line 24]
--- FUNCTIONs ---
  function handleClick()  [line 30]
--- SNIPPETs ---
  {#snippet icon()}  [line 40]

(10 symbols)
```

## When to Use

- **Exploring a Svelte component**: `svast -d ./path/to/Component.svelte` gives a quick overview
- **Finding all props**: `svast -k prop ./src/lib/components/` shows all component props
- **Understanding state shape**: `svast -k state -d ./src/` shows all reactive state
- **Mapping component APIs**: `svast -k prop -d ./src/lib/components/ui/` shows all public APIs
- **Finding snippets**: `svast -k snippet ./src/` shows all template snippets
- **SvelteKit route analysis**: `svast -t ./src/routes/` includes load functions and endpoints
- **Pre-read triage**: Use svast to identify which files contain relevant symbols, then Read those files

## Tips

- Use `-d` (detail) when you need propsType, initializer values, or template symbols
- Use `-k component-use` to see which components a file uses
- Use `-k binding` to audit all two-way bindings
- Use `-t` flag when scanning directories to also include route files (`.ts`/`.js`)
- The tool skips `node_modules`, `.svelte-kit`, `dist`, and test files automatically
- Use `-j` (JSON) when you need to process the output programmatically
- Combine with `Read` to dive into specific components after identifying them with svast
