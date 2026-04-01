# shadcn-svelte Theming Reference

## Color Convention

- `--primary` → background color
- `--primary-foreground` → text color on that background

The `-foreground` suffix is always the text color for the corresponding background.

## CSS Variables (Zinc base, OKLCH)

Defined in `frontend/src/app.css` under `:root` (light) and `.dark` (dark).

### Core Variables

| Variable | Purpose |
|----------|---------|
| `--background` / `--foreground` | Page background and text |
| `--card` / `--card-foreground` | Card surfaces |
| `--popover` / `--popover-foreground` | Popovers, dropdowns |
| `--primary` / `--primary-foreground` | Primary actions |
| `--secondary` / `--secondary-foreground` | Secondary actions |
| `--muted` / `--muted-foreground` | Muted/disabled |
| `--accent` / `--accent-foreground` | Accent highlights |
| `--destructive` | Destructive actions (no foreground — uses contextual text) |
| `--border` | Default border color |
| `--input` | Input borders |
| `--ring` | Focus rings |
| `--radius` | Border radius base (0.625rem) |
| `--chart-1` through `--chart-5` | Chart colors |
| `--sidebar-*` | Sidebar-specific variants |

### Radius Scale

Defined in `@theme inline`:

```css
--radius-sm: calc(var(--radius) - 4px);
--radius-md: calc(var(--radius) - 2px);
--radius-lg: var(--radius);
--radius-xl: calc(var(--radius) + 4px);
```

### Adding New Colors

1. Define CSS variables in `:root` and `.dark`
2. Register in `@theme inline` block
3. Use as Tailwind utilities

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

Then use: `bg-warning text-warning-foreground`

## Dark Mode

Strategy: class-based via `@custom-variant dark (&:is(.dark *));`

Toggle by adding `.dark` class to a parent element (typically `<html>`).

## Base Colors Available

| Name | Character |
|------|-----------|
| zinc | Cool blue-gray (current) |
| neutral | Pure gray |
| stone | Warm gray |
| slate | Blue-tinted gray |
| gray | Standard gray |

All use OKLCH color space for perceptual uniformity.

## Custom Variants (app.css)

These are auto-added by shadcn-svelte CLI for Bits UI state styling:

- `data-open` / `data-closed` — dialog/popover states
- `data-checked` / `data-unchecked` — checkbox/switch states
- `data-selected` — selected items
- `data-disabled` — disabled elements
- `data-active` — active tabs/items
- `data-horizontal` / `data-vertical` — orientation variants
