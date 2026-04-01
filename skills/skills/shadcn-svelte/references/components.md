# shadcn-svelte Component Index

Install from `frontend/` directory:
```bash
pnpm dlx shadcn-svelte@latest add <name> -y -o
```

## Form & Input

| Component | CLI name | Import | Type |
|-----------|----------|--------|------|
| Button | `button` | `{ Button }` | Simple |
| Button Group | `button-group` | `* as ButtonGroup` | Compound |
| Calendar | `calendar` | `{ Calendar }` | Simple |
| Checkbox | `checkbox` | `{ Checkbox }` | Simple |
| Combobox | `combobox` | Custom (Command + Popover) | Composed |
| Date Picker | `date-picker` | Custom (Calendar + Popover) | Composed |
| Field | `field` | `* as Field` | Compound |
| Form (Formsnap) | `form` | `* as Form` | Compound |
| Input | `input` | `{ Input }` | Simple |
| Input Group | `input-group` | `* as InputGroup` | Compound |
| Input OTP | `input-otp` | `* as InputOTP` | Compound |
| Label | `label` | `{ Label }` | Simple |
| Native Select | `native-select` | `{ NativeSelect }` | Simple |
| Radio Group | `radio-group` | `* as RadioGroup` | Compound |
| Select | `select` | `* as Select` | Compound |
| Slider | `slider` | `{ Slider }` | Simple |
| Switch | `switch` | `{ Switch }` | Simple |
| Textarea | `textarea` | `{ Textarea }` | Simple |

## Layout & Navigation

| Component | CLI name | Import | Type |
|-----------|----------|--------|------|
| Accordion | `accordion` | `* as Accordion` | Compound |
| Breadcrumb | `breadcrumb` | `* as Breadcrumb` | Compound |
| Navigation Menu | `navigation-menu` | `* as NavigationMenu` | Compound |
| Resizable | `resizable` | `* as Resizable` | Compound |
| Scroll Area | `scroll-area` | `{ ScrollArea }` | Simple |
| Separator | `separator` | `{ Separator }` | Simple |
| Sidebar | `sidebar` | `* as Sidebar` | Compound |
| Tabs | `tabs` | `* as Tabs` | Compound |

## Overlays & Dialogs

| Component | CLI name | Import | Type |
|-----------|----------|--------|------|
| Alert Dialog | `alert-dialog` | `* as AlertDialog` | Compound |
| Command | `command` | `* as Command` | Compound |
| Context Menu | `context-menu` | `* as ContextMenu` | Compound |
| Dialog | `dialog` | `* as Dialog` | Compound |
| Drawer | `drawer` | `* as Drawer` | Compound |
| Dropdown Menu | `dropdown-menu` | `* as DropdownMenu` | Compound |
| Hover Card | `hover-card` | `* as HoverCard` | Compound |
| Menubar | `menubar` | `* as Menubar` | Compound |
| Popover | `popover` | `* as Popover` | Compound |
| Sheet | `sheet` | `* as Sheet` | Compound |
| Tooltip | `tooltip` | `* as Tooltip` | Compound |

## Feedback & Status

| Component | CLI name | Import | Type |
|-----------|----------|--------|------|
| Alert | `alert` | `* as Alert` | Compound |
| Badge | `badge` | `{ Badge }` | Simple |
| Empty | `empty` | `* as Empty` | Compound |
| Progress | `progress` | `{ Progress }` | Simple |
| Skeleton | `skeleton` | `{ Skeleton }` | Simple |
| Sonner (toast) | `sonner` | `{ Toaster }` + `toast()` | Simple + fn |
| Spinner | `spinner` | `{ Spinner }` | Simple |

## Display & Media

| Component | CLI name | Import | Type |
|-----------|----------|--------|------|
| Aspect Ratio | `aspect-ratio` | `{ AspectRatio }` | Simple |
| Avatar | `avatar` | `* as Avatar` | Compound |
| Card | `card` | `* as Card` | Compound |
| Carousel | `carousel` | `* as Carousel` | Compound |
| Chart | `chart` | `* as Chart` | Compound |
| Data Table | `data-table` | Custom (TanStack Table) | Composed |
| Item | `item` | `* as Item` | Compound |
| Kbd | `kbd` | `{ Kbd }` | Simple |
| Table | `table` | `* as Table` | Compound |
| Typography | N/A | Tailwind prose classes | CSS |

## Misc

| Component | CLI name | Import | Type |
|-----------|----------|--------|------|
| Collapsible | `collapsible` | `* as Collapsible` | Compound |
| Pagination | `pagination` | `* as Pagination` | Compound |
| Range Calendar | `range-calendar` | `{ RangeCalendar }` | Simple |
| Toggle | `toggle` | `{ Toggle }` | Simple |
| Toggle Group | `toggle-group` | `* as ToggleGroup` | Compound |

## Import Convention

**Simple** (single export):
```svelte
import { Button } from "$lib/components/ui/button/index.js";
```

**Compound** (multiple sub-components):
```svelte
import * as Card from "$lib/components/ui/card/index.js";
// Card.Root, Card.Header, Card.Title, Card.Description, Card.Content, Card.Footer
```

**Composed** (built from multiple primitives — Combobox, Date Picker, Data Table):
These are patterns, not single components. The CLI adds example code you customize.
