---
name: shadcn-svelte
description: Add, customize, and compose shadcn-svelte UI components in Svelte 5 + Tailwind CSS v4 projects. Use when creating UI, adding components, theming, or building pages with shadcn-svelte.
---

# shadcn-svelte Component Skill

Build UIs using shadcn-svelte — a collection of accessible, composable components for Svelte 5 + SvelteKit + Tailwind CSS v4 + Bits UI.

> **Version**: shadcn-svelte v1.2.x, Svelte 5, Tailwind CSS v4, Bits UI v2

## Project Setup (already configured)

| Item | Value |
|------|-------|
| Config | `frontend/components.json` |
| Base color | `zinc` (OKLCH) |
| CSS | `frontend/src/app.css` |
| Utils | `$lib/utils.ts` (`cn()` + type helpers) |
| UI components | `$lib/components/ui/<name>/` |
| Hooks | `$lib/hooks/` |
| Icons | `@lucide/svelte` (tree-shaking via `@lucide/svelte/icons/<name>`) |

## Adding Components

Use the CLI from the `frontend/` directory:

```bash
pnpm dlx shadcn-svelte@latest add <component> -y -o
```

Multiple at once:

```bash
pnpm dlx shadcn-svelte@latest add button card dialog dropdown-menu -y -o
```

All components:

```bash
pnpm dlx shadcn-svelte@latest add --all -y -o
```

## Component Usage Patterns

### Import convention

```svelte
<script lang="ts">
  import { Button } from "$lib/components/ui/button/index.js";
  import * as Card from "$lib/components/ui/card/index.js";
  import * as DropdownMenu from "$lib/components/ui/dropdown-menu/index.js";
</script>
```

- Simple components: named import (`Button`, `Badge`, `Input`)
- Compound components: namespace import (`Card.Root`, `Card.Header`, `Card.Content`)

### Svelte 5 runes (required)

```svelte
<script lang="ts">
  let { children } = $props();
  let count = $state(0);
  let doubled = $derived(count * 2);

  $effect(() => {
    console.log(count);
  });
</script>

{@render children?.()}
```

### Button variants

```svelte
<Button>Default</Button>
<Button variant="outline">Outline</Button>
<Button variant="secondary">Secondary</Button>
<Button variant="ghost">Ghost</Button>
<Button variant="destructive">Destructive</Button>
<Button variant="link">Link</Button>
<Button size="sm">Small</Button>
<Button size="lg">Large</Button>
<Button size="icon" aria-label="Settings"><GearIcon /></Button>
<Button href="/dashboard">Link Button</Button>
```

### Icons

```svelte
<script lang="ts">
  import ArrowUpIcon from "@lucide/svelte/icons/arrow-up";
</script>

<Button variant="outline" size="sm">
  <ArrowUpIcon /> Upload
</Button>
```

Icons inside buttons auto-size. No manual margin needed.

### Compound components (Dialog example)

```svelte
<script lang="ts">
  import * as Dialog from "$lib/components/ui/dialog/index.js";
  import { Button } from "$lib/components/ui/button/index.js";
</script>

<Dialog.Root>
  <Dialog.Trigger>
    {#snippet child({ props })}
      <Button {...props} variant="outline">Edit Profile</Button>
    {/snippet}
  </Dialog.Trigger>
  <Dialog.Content>
    <Dialog.Header>
      <Dialog.Title>Edit Profile</Dialog.Title>
      <Dialog.Description>Make changes to your profile.</Dialog.Description>
    </Dialog.Header>
    <!-- form fields here -->
    <Dialog.Footer>
      <Button type="submit">Save</Button>
    </Dialog.Footer>
  </Dialog.Content>
</Dialog.Root>
```

### Trigger child snippet pattern

When a trigger wraps a custom component, use the `child` snippet:

```svelte
<DropdownMenu.Trigger>
  {#snippet child({ props })}
    <Button {...props} variant="outline">Open</Button>
  {/snippet}
</DropdownMenu.Trigger>
```

## Theming

### CSS Variables (OKLCH, Tailwind v4)

Theme is defined in `src/app.css` using CSS variables with OKLCH colors.

Key variables: `--background`, `--foreground`, `--primary`, `--secondary`, `--muted`, `--accent`, `--destructive`, `--border`, `--input`, `--ring`, `--card`, `--popover`, `--sidebar-*`, `--chart-*`.

Each has a `-foreground` counterpart for text.

### Adding custom colors

```css
:root {
  --warning: oklch(0.84 0.16 84);
  --warning-foreground: oklch(0.28 0.07 46);
}
.dark {
  --warning: oklch(0.41 0.11 46);
  --warning-foreground: oklch(0.99 0.02 95);
}
@theme inline {
  --color-warning: var(--warning);
  --color-warning-foreground: var(--warning-foreground);
}
```

### Dark mode

Dark mode uses class strategy via `@custom-variant dark (&:is(.dark *));` in app.css.
Toggle by adding/removing `.dark` class on `<html>` or `<body>`.

## `cn()` Utility

```ts
import { cn } from "$lib/utils.js";

// Merges Tailwind classes with conflict resolution
cn("px-2 py-1", "px-4")          // → "py-1 px-4"
cn("bg-red-500", className)       // → merge with user override
cn(buttonVariants({ variant }), className)
```

## Available Components (50+)

| Category | Components |
|----------|-----------|
| Form & Input | Button, ButtonGroup, Calendar, Checkbox, Combobox, DatePicker, Field, Form (Formsnap), Input, InputGroup, InputOTP, Label, NativeSelect, RadioGroup, Select, Slider, Switch, Textarea |
| Layout & Nav | Accordion, Breadcrumb, NavigationMenu, Resizable, ScrollArea, Separator, Sidebar, Tabs |
| Overlays | AlertDialog, Command, ContextMenu, Dialog, Drawer, DropdownMenu, HoverCard, Menubar, Popover, Sheet, Tooltip |
| Feedback | Alert, Badge, Empty, Progress, Skeleton, Sonner (toast), Spinner |
| Display | AspectRatio, Avatar, Card, Carousel, Chart, DataTable, Item, Kbd, Table, Typography |
| Misc | Collapsible, Pagination, RangeCalendar, Toggle, ToggleGroup |

## Key Dependencies

| Package | Purpose |
|---------|---------|
| `bits-ui` | Headless UI primitives (accessible) |
| `tailwind-variants` | Variant-based styling (`tv()`) |
| `tailwind-merge` | Intelligent Tailwind class merging |
| `clsx` | Conditional class joining |
| `tw-animate-css` | Animation utilities for Tailwind v4 |
| `@lucide/svelte` | Icon library |

## Domain Knowledge

| Topic | Reference |
|-------|-----------|
| **CLI Usage** | [./references/cli.md](./references/cli.md) |
| **Theming** | [./references/theming.md](./references/theming.md) |
| **Component Index** | [./references/components.md](./references/components.md) |

## Rules

- Always use Svelte 5 runes (`$state`, `$derived`, `$effect`, `$props`) — never legacy stores
- Import from `$lib/components/ui/<name>/index.js` — always include `.js` extension
- Use `@lucide/svelte/icons/<name>` for tree-shaking — never import from root
- Use `cn()` from `$lib/utils.js` for class merging — never manual concatenation
- Every interactive element must have accessible labels (`aria-label` on icon-only buttons)
- Run `pnpm check` after changes — type errors are blocking
- Components live in `$lib/components/ui/` — don't hand-edit generated components unless customizing
- `data-slot` attributes on primitives are for styling — don't remove them
