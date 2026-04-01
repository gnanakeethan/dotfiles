---
name: go-ast
description: "Parse Go source code using AST to extract symbols (functions, methods, structs, interfaces, types, constants, variables) with signatures, fields, docs. Use when exploring Go codebases, understanding package APIs, or finding symbols."
argument-hint: "[path] [--kind func|method|struct|interface|type|const|var] [--filter name] [--detail] [--private] [--json]"
allowed-tools: "Bash, Read, Grep, Glob"
---

# Go AST Reader

Use the `goast` CLI tool (installed at `~/go/bin/goast`) to parse Go source files using the `go/ast` package. This gives accurate, structured information about Go code without reading entire files.

## Tool Location

Binary: `~/go/bin/goast`
Source: `${CLAUDE_SKILL_DIR}/cmd/goast/main.go`

## Usage

```bash
goast [flags] <path>
```

**Flags MUST come before the positional path argument** (Go `flag` package requirement).

| Flag | Description |
|------|-------------|
| `-detail` | Show struct fields, interface methods, and doc comments |
| `-private` | Include unexported (lowercase) symbols |
| `-json` | Output as JSON instead of text |
| `-kind <k>` | Filter by kind: `func`, `method`, `struct`, `interface`, `type`, `const`, `var` |
| `-filter <s>` | Filter symbols by case-insensitive substring match |
| `-name <s>` | Filter by exact name match |

`<path>` can be a single `.go` file or a directory (parses entire package, excluding `_test.go` files).

## Dispatch on $ARGUMENTS

| Argument | Action |
|----------|--------|
| *(empty)* | Parse current directory, show all exported symbols |
| `<path>` | Parse the given file or directory |
| `<path> --detail` | Parse with full details (fields, methods, docs) |
| `<path> --kind struct` | Show only structs |
| `<path> --kind interface --detail` | Show interfaces with their method sets |
| `<path> --kind func` | Show only standalone functions |
| `<path> --kind method --filter Controller` | Show methods matching "Controller" |
| `<path> --json` | Output as JSON for programmatic use |

## Examples

### List all exported symbols in a package
```bash
goast ./controllers/
```

### Show struct fields and docs
```bash
goast -detail -kind struct ./models/
```

### Find all methods on a type
```bash
goast -detail -kind method -filter OrderController ./controllers/
```

### Show interface definitions
```bash
goast -detail -kind interface ./services/
```

### Include private symbols
```bash
goast -detail -private ./internal/handler/
```

### JSON output for processing
```bash
goast -json -detail ./models/order.go
```

### Find a specific symbol by name
```bash
goast -name CreateOrder -detail ./controllers/
```

## Output Format (text)

```
package controllers  (/path/to/controllers)
files: order.go, user.go, ...
imports: 15 packages

--- INTERFACEs ---
  type OrderService interface  [order.go:10]
    Create(ctx context.Context, req CreateReq) (*Order, error)
    Get(ctx context.Context, id string) (*Order, error)

--- STRUCTs ---
  type OrderController struct  [order.go:20]
    service OrderService
    logger  *zap.Logger

--- FUNCs ---
  func NewOrderController(s OrderService, l *zap.Logger) *OrderController  [order.go:30]

--- METHODs ---
  func (*OrderController) Create(ctx context.Context) error  [order.go:40]

(4 symbols)
```

## Output Format (JSON)

```json
{
  "name": "controllers",
  "path": "/path/to/controllers",
  "files": ["order.go"],
  "imports": ["context", "go.uber.org/zap"],
  "symbols": [
    {
      "kind": "struct",
      "name": "OrderController",
      "file": "order.go",
      "line": 20,
      "exported": true,
      "fields": [
        {"name": "service", "type": "OrderService"},
        {"name": "logger", "type": "*zap.Logger"}
      ]
    }
  ]
}
```

## When to Use

- **Exploring a new package**: `goast -detail ./path/to/pkg/` gives a quick overview
- **Finding function signatures**: `goast -kind func -detail ./path/` shows all func signatures
- **Understanding struct shapes**: `goast -kind struct -detail ./models/` shows all fields and tags
- **Mapping interfaces**: `goast -kind interface -detail ./path/` shows interface contracts
- **Finding methods on a type**: `goast -kind method -filter TypeName ./path/`
- **Pre-read triage**: Use goast to identify which files contain relevant symbols, then Read those files

## Tips

- Always use `-detail` when you need field/method/doc information
- Use `-kind method -filter ReceiverName` to find all methods on a specific type
- Use `-json` when you need to process the output programmatically
- The tool skips `_test.go` files by default when parsing directories
- Combine with `Read` to dive into specific functions after identifying them with goast
