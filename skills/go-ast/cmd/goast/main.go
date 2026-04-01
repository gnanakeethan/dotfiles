package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"go/ast"
	"go/parser"
	"go/token"
	"os"
	"path/filepath"
	"sort"
	"strings"
)

// Symbol kinds
const (
	KindFunc      = "func"
	KindMethod    = "method"
	KindStruct    = "struct"
	KindInterface = "interface"
	KindTypeAlias = "type"
	KindConst     = "const"
	KindVar       = "var"
)

type Symbol struct {
	Kind       string   `json:"kind"`
	Name       string   `json:"name"`
	File       string   `json:"file"`
	Line       int      `json:"line"`
	Exported   bool     `json:"exported"`
	Signature  string   `json:"signature,omitempty"`
	Receiver   string   `json:"receiver,omitempty"`
	Doc        string   `json:"doc,omitempty"`
	Fields     []Field  `json:"fields,omitempty"`
	Methods    []string `json:"methods,omitempty"`
	Embeds     []string `json:"embeds,omitempty"`
	Implements []string `json:"implements,omitempty"`
}

type Field struct {
	Name string `json:"name"`
	Type string `json:"type"`
	Tag  string `json:"tag,omitempty"`
	Doc  string `json:"doc,omitempty"`
}

type PackageInfo struct {
	Name    string   `json:"name"`
	Path    string   `json:"path"`
	Files   []string `json:"files"`
	Imports []string `json:"imports"`
	Symbols []Symbol `json:"symbols"`
}

func main() {
	var (
		targetPath  string
		filter      string
		kind        string
		name        string
		outputJSON  bool
		showPrivate bool
		detail      bool
	)

	flag.StringVar(&targetPath, "path", ".", "File or directory to parse")
	flag.StringVar(&filter, "filter", "", "Filter symbols by substring match")
	flag.StringVar(&kind, "kind", "", "Filter by kind: func, method, struct, interface, type, const, var")
	flag.StringVar(&name, "name", "", "Exact name match")
	flag.BoolVar(&outputJSON, "json", false, "Output as JSON")
	flag.BoolVar(&showPrivate, "private", false, "Include unexported symbols")
	flag.BoolVar(&detail, "detail", false, "Show detailed info (fields, methods, docs)")
	flag.Parse()

	// Positional arg overrides -path
	if flag.NArg() > 0 {
		targetPath = flag.Arg(0)
	}

	absPath, err := filepath.Abs(targetPath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		os.Exit(1)
	}

	info, err := os.Stat(absPath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		os.Exit(1)
	}

	fset := token.NewFileSet()
	var pkgInfo PackageInfo

	if info.IsDir() {
		pkgInfo, err = parseDirectory(fset, absPath, detail)
	} else {
		pkgInfo, err = parseSingleFile(fset, absPath, detail)
	}
	if err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		os.Exit(1)
	}

	// Apply filters
	filtered := filterSymbols(pkgInfo.Symbols, filter, kind, name, showPrivate)
	pkgInfo.Symbols = filtered

	if outputJSON {
		enc := json.NewEncoder(os.Stdout)
		enc.SetIndent("", "  ")
		enc.Encode(pkgInfo)
	} else {
		printText(pkgInfo, detail)
	}
}

func parseDirectory(fset *token.FileSet, dir string, detail bool) (PackageInfo, error) {
	pkgs, err := parser.ParseDir(fset, dir, func(fi os.FileInfo) bool {
		return !strings.HasSuffix(fi.Name(), "_test.go")
	}, parser.ParseComments)
	if err != nil {
		return PackageInfo{}, fmt.Errorf("parse dir: %w", err)
	}

	info := PackageInfo{Path: dir}
	importSet := make(map[string]bool)

	for _, pkg := range pkgs {
		info.Name = pkg.Name
		for filename, file := range pkg.Files {
			info.Files = append(info.Files, filepath.Base(filename))
			collectImports(file, importSet)
			symbols := extractSymbols(fset, file, filename, detail)
			info.Symbols = append(info.Symbols, symbols...)
		}
	}

	sort.Strings(info.Files)
	for imp := range importSet {
		info.Imports = append(info.Imports, imp)
	}
	sort.Strings(info.Imports)

	return info, nil
}

func parseSingleFile(fset *token.FileSet, filename string, detail bool) (PackageInfo, error) {
	file, err := parser.ParseFile(fset, filename, nil, parser.ParseComments)
	if err != nil {
		return PackageInfo{}, fmt.Errorf("parse file: %w", err)
	}

	info := PackageInfo{
		Name:  file.Name.Name,
		Path:  filepath.Dir(filename),
		Files: []string{filepath.Base(filename)},
	}

	importSet := make(map[string]bool)
	collectImports(file, importSet)
	for imp := range importSet {
		info.Imports = append(info.Imports, imp)
	}
	sort.Strings(info.Imports)

	info.Symbols = extractSymbols(fset, file, filename, detail)
	return info, nil
}

func collectImports(file *ast.File, imports map[string]bool) {
	for _, imp := range file.Imports {
		path := strings.Trim(imp.Path.Value, `"`)
		imports[path] = true
	}
}

func extractSymbols(fset *token.FileSet, file *ast.File, filename string, detail bool) []Symbol {
	var symbols []Symbol
	relFile := filepath.Base(filename)

	for _, decl := range file.Decls {
		switch d := decl.(type) {
		case *ast.FuncDecl:
			sym := Symbol{
				Name:      d.Name.Name,
				File:      relFile,
				Line:      fset.Position(d.Pos()).Line,
				Exported:  d.Name.IsExported(),
				Signature: funcSignature(d),
			}
			if d.Recv != nil && len(d.Recv.List) > 0 {
				sym.Kind = KindMethod
				sym.Receiver = exprToString(d.Recv.List[0].Type)
			} else {
				sym.Kind = KindFunc
			}
			if detail && d.Doc != nil {
				sym.Doc = strings.TrimSpace(d.Doc.Text())
			}
			symbols = append(symbols, sym)

		case *ast.GenDecl:
			for _, spec := range d.Specs {
				switch s := spec.(type) {
				case *ast.TypeSpec:
					sym := Symbol{
						Name:     s.Name.Name,
						File:     relFile,
						Line:     fset.Position(s.Pos()).Line,
						Exported: s.Name.IsExported(),
					}
					doc := s.Doc
					if doc == nil {
						doc = d.Doc
					}
					if detail && doc != nil {
						sym.Doc = strings.TrimSpace(doc.Text())
					}

					switch t := s.Type.(type) {
					case *ast.StructType:
						sym.Kind = KindStruct
						if detail && t.Fields != nil {
							for _, f := range t.Fields.List {
								field := Field{
									Type: exprToString(f.Type),
								}
								if len(f.Names) > 0 {
									field.Name = f.Names[0].Name
								} else {
									// Embedded field
									field.Name = exprToString(f.Type)
									sym.Embeds = append(sym.Embeds, field.Name)
								}
								if f.Tag != nil {
									field.Tag = f.Tag.Value
								}
								if f.Doc != nil {
									field.Doc = strings.TrimSpace(f.Doc.Text())
								}
								sym.Fields = append(sym.Fields, field)
							}
						}
					case *ast.InterfaceType:
						sym.Kind = KindInterface
						if detail && t.Methods != nil {
							for _, m := range t.Methods.List {
								if len(m.Names) > 0 {
									sig := m.Names[0].Name
									if ft, ok := m.Type.(*ast.FuncType); ok {
										sig += funcTypeSignature(ft)
									}
									sym.Methods = append(sym.Methods, sig)
								} else {
									// Embedded interface
									sym.Embeds = append(sym.Embeds, exprToString(m.Type))
								}
							}
						}
					default:
						sym.Kind = KindTypeAlias
						sym.Signature = exprToString(s.Type)
					}
					symbols = append(symbols, sym)

				case *ast.ValueSpec:
					for _, ident := range s.Names {
						sym := Symbol{
							Name:     ident.Name,
							File:     relFile,
							Line:     fset.Position(ident.Pos()).Line,
							Exported: ident.IsExported(),
						}
						if d.Tok == token.CONST {
							sym.Kind = KindConst
						} else {
							sym.Kind = KindVar
						}
						if s.Type != nil {
							sym.Signature = exprToString(s.Type)
						}
						doc := s.Doc
						if doc == nil {
							doc = d.Doc
						}
						if detail && doc != nil {
							sym.Doc = strings.TrimSpace(doc.Text())
						}
						symbols = append(symbols, sym)
					}
				}
			}
		}
	}

	return symbols
}

func funcSignature(fd *ast.FuncDecl) string {
	var b strings.Builder
	b.WriteString("(")
	if fd.Type.Params != nil {
		writeFieldList(&b, fd.Type.Params.List)
	}
	b.WriteString(")")
	if fd.Type.Results != nil && len(fd.Type.Results.List) > 0 {
		b.WriteString(" ")
		if len(fd.Type.Results.List) == 1 && len(fd.Type.Results.List[0].Names) == 0 {
			b.WriteString(exprToString(fd.Type.Results.List[0].Type))
		} else {
			b.WriteString("(")
			writeFieldList(&b, fd.Type.Results.List)
			b.WriteString(")")
		}
	}
	return b.String()
}

func funcTypeSignature(ft *ast.FuncType) string {
	var b strings.Builder
	b.WriteString("(")
	if ft.Params != nil {
		writeFieldList(&b, ft.Params.List)
	}
	b.WriteString(")")
	if ft.Results != nil && len(ft.Results.List) > 0 {
		b.WriteString(" ")
		if len(ft.Results.List) == 1 && len(ft.Results.List[0].Names) == 0 {
			b.WriteString(exprToString(ft.Results.List[0].Type))
		} else {
			b.WriteString("(")
			writeFieldList(&b, ft.Results.List)
			b.WriteString(")")
		}
	}
	return b.String()
}

func writeFieldList(b *strings.Builder, fields []*ast.Field) {
	for i, f := range fields {
		if i > 0 {
			b.WriteString(", ")
		}
		if len(f.Names) > 0 {
			for j, n := range f.Names {
				if j > 0 {
					b.WriteString(", ")
				}
				b.WriteString(n.Name)
			}
			b.WriteString(" ")
		}
		b.WriteString(exprToString(f.Type))
	}
}

func exprToString(expr ast.Expr) string {
	switch e := expr.(type) {
	case *ast.Ident:
		return e.Name
	case *ast.SelectorExpr:
		return exprToString(e.X) + "." + e.Sel.Name
	case *ast.StarExpr:
		return "*" + exprToString(e.X)
	case *ast.ArrayType:
		if e.Len == nil {
			return "[]" + exprToString(e.Elt)
		}
		return "[" + exprToString(e.Len) + "]" + exprToString(e.Elt)
	case *ast.MapType:
		return "map[" + exprToString(e.Key) + "]" + exprToString(e.Value)
	case *ast.ChanType:
		switch e.Dir {
		case ast.SEND:
			return "chan<- " + exprToString(e.Value)
		case ast.RECV:
			return "<-chan " + exprToString(e.Value)
		default:
			return "chan " + exprToString(e.Value)
		}
	case *ast.FuncType:
		return "func" + funcTypeSignature(e)
	case *ast.InterfaceType:
		if e.Methods == nil || len(e.Methods.List) == 0 {
			return "interface{}"
		}
		return "interface{...}"
	case *ast.StructType:
		return "struct{...}"
	case *ast.Ellipsis:
		return "..." + exprToString(e.Elt)
	case *ast.ParenExpr:
		return "(" + exprToString(e.X) + ")"
	case *ast.BasicLit:
		return e.Value
	case *ast.IndexExpr:
		return exprToString(e.X) + "[" + exprToString(e.Index) + "]"
	case *ast.IndexListExpr:
		var indices []string
		for _, idx := range e.Indices {
			indices = append(indices, exprToString(idx))
		}
		return exprToString(e.X) + "[" + strings.Join(indices, ", ") + "]"
	case nil:
		return ""
	default:
		return fmt.Sprintf("<%T>", expr)
	}
}

func filterSymbols(symbols []Symbol, filter, kind, name string, showPrivate bool) []Symbol {
	var result []Symbol
	for _, s := range symbols {
		if !showPrivate && !s.Exported {
			continue
		}
		if kind != "" && s.Kind != kind {
			continue
		}
		if name != "" && s.Name != name {
			continue
		}
		if filter != "" && !strings.Contains(strings.ToLower(s.Name), strings.ToLower(filter)) {
			continue
		}
		result = append(result, s)
	}

	// Sort: kind first, then name
	sort.Slice(result, func(i, j int) bool {
		ki := kindOrder(result[i].Kind)
		kj := kindOrder(result[j].Kind)
		if ki != kj {
			return ki < kj
		}
		return result[i].Name < result[j].Name
	})

	return result
}

func kindOrder(k string) int {
	switch k {
	case KindInterface:
		return 0
	case KindStruct:
		return 1
	case KindTypeAlias:
		return 2
	case KindFunc:
		return 3
	case KindMethod:
		return 4
	case KindConst:
		return 5
	case KindVar:
		return 6
	default:
		return 7
	}
}

func printText(pkg PackageInfo, detail bool) {
	fmt.Printf("package %s  (%s)\n", pkg.Name, pkg.Path)
	fmt.Printf("files: %s\n", strings.Join(pkg.Files, ", "))

	if len(pkg.Imports) > 0 {
		fmt.Printf("imports: %d packages\n", len(pkg.Imports))
	}
	fmt.Println()

	if len(pkg.Symbols) == 0 {
		fmt.Println("(no matching symbols)")
		return
	}

	currentKind := ""
	for _, s := range pkg.Symbols {
		if s.Kind != currentKind {
			currentKind = s.Kind
			fmt.Printf("--- %ss ---\n", strings.ToUpper(currentKind))
		}

		location := fmt.Sprintf("%s:%d", s.File, s.Line)

		switch s.Kind {
		case KindFunc:
			fmt.Printf("  func %s%s  [%s]\n", s.Name, s.Signature, location)
		case KindMethod:
			fmt.Printf("  func (%s) %s%s  [%s]\n", s.Receiver, s.Name, s.Signature, location)
		case KindStruct:
			fmt.Printf("  type %s struct  [%s]\n", s.Name, location)
			if detail {
				for _, f := range s.Fields {
					if f.Tag != "" {
						fmt.Printf("    %s %s %s\n", f.Name, f.Type, f.Tag)
					} else {
						fmt.Printf("    %s %s\n", f.Name, f.Type)
					}
				}
			}
		case KindInterface:
			fmt.Printf("  type %s interface  [%s]\n", s.Name, location)
			if detail {
				for _, e := range s.Embeds {
					fmt.Printf("    %s  (embedded)\n", e)
				}
				for _, m := range s.Methods {
					fmt.Printf("    %s\n", m)
				}
			}
		case KindTypeAlias:
			fmt.Printf("  type %s = %s  [%s]\n", s.Name, s.Signature, location)
		case KindConst:
			if s.Signature != "" {
				fmt.Printf("  const %s %s  [%s]\n", s.Name, s.Signature, location)
			} else {
				fmt.Printf("  const %s  [%s]\n", s.Name, location)
			}
		case KindVar:
			if s.Signature != "" {
				fmt.Printf("  var %s %s  [%s]\n", s.Name, s.Signature, location)
			} else {
				fmt.Printf("  var %s  [%s]\n", s.Name, location)
			}
		}

		if detail && s.Doc != "" {
			lines := strings.Split(s.Doc, "\n")
			for _, l := range lines {
				fmt.Printf("      // %s\n", l)
			}
		}
	}

	fmt.Printf("\n(%d symbols)\n", len(pkg.Symbols))
}
