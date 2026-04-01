#!/usr/bin/env node
// svast — Svelte/SvelteKit AST symbol reader
// Parses .svelte, .ts, .js files to extract components, props, state, runes, exports, types, etc.

import { parseArgs } from 'node:util';
import { readFileSync, statSync, readdirSync } from 'node:fs';
import { resolve, basename, extname, join } from 'node:path';

// Lazy-loaded deps
let svelteParse, ts;

async function loadDeps() {
  try {
    const mod = await import('svelte/compiler');
    svelteParse = mod.parse;
  } catch {
    fatal('svelte not found. Run: cd ~/.claude/skills/svelte-ast && npm install');
  }
  try {
    ts = (await import('typescript')).default;
  } catch {
    fatal('typescript not found. Run: cd ~/.claude/skills/svelte-ast && npm install');
  }
}

function fatal(msg) {
  process.stderr.write(`error: ${msg}\n`);
  process.exit(1);
}

// ── Symbol kinds ─────────────────────────────────────────────────────
const K = {
  PROP:          'prop',
  STATE:         'state',
  DERIVED:       'derived',
  EFFECT:        'effect',
  FUNCTION:      'function',
  CONST:         'const',
  VAR:           'var',
  TYPE:          'type',
  INTERFACE:     'interface',
  IMPORT:        'import',
  SNIPPET:       'snippet',
  COMPONENT_USE: 'component-use',
  BINDING:       'binding',
  ACTION:        'action',
};

const TEMPLATE_KINDS = new Set([K.SNIPPET, K.COMPONENT_USE, K.BINDING, K.ACTION]);

// ── CLI ──────────────────────────────────────────────────────────────
async function main() {
  const { values: opts, positionals } = parseArgs({
    options: {
      detail:  { type: 'boolean', default: false, short: 'd' },
      json:    { type: 'boolean', default: false, short: 'j' },
      kind:    { type: 'string',  default: '',    short: 'k' },
      filter:  { type: 'string',  default: '',    short: 'f' },
      name:    { type: 'string',  default: '',    short: 'n' },
      ts:      { type: 'boolean', default: false, short: 't' },
      help:    { type: 'boolean', default: false, short: 'h' },
    },
    allowPositionals: true,
    strict: true,
  });

  if (opts.help) {
    write(`svast — Svelte/SvelteKit AST symbol reader

Usage: svast [flags] <path>

Flags:
  -d, --detail     Show detailed info (fields, members, template symbols)
  -j, --json       Output as JSON
  -k, --kind <k>   Filter: prop, state, derived, effect, function, const, var,
                    type, interface, import, snippet, component-use, binding, action
  -f, --filter <s> Substring match on symbol names
  -n, --name <s>   Exact name match
  -t, --ts         Include .ts/.js files when scanning directories
  -h, --help       Show this help

<path> can be a .svelte/.ts/.js file or a directory (recursive scan).
`);
    process.exit(0);
  }

  await loadDeps();

  const targetPath = resolve(positionals[0] || '.');
  let stat;
  try { stat = statSync(targetPath); }
  catch { fatal(`path not found: ${targetPath}`); }

  const files = stat.isDirectory()
    ? discoverFiles(targetPath, opts.ts)
    : [targetPath];

  if (files.length === 0) {
    fatal(`no .svelte${opts.ts ? '/.ts/.js' : ''} files found in ${targetPath}`);
  }

  const results = [];
  for (const file of files) {
    try {
      const result = parseFile(file);
      result.symbols = filterSymbols(result.symbols, opts);
      if (result.symbols.length > 0 || files.length === 1) {
        results.push(result);
      }
    } catch (e) {
      process.stderr.write(`warning: ${file}: ${e.message}\n`);
    }
  }

  if (opts.json) {
    const out = results.length === 1 ? results[0] : results;
    process.stdout.write(JSON.stringify(out, null, 2) + '\n');
  } else {
    printText(results, opts.detail);
  }
}

// ── File Discovery ───────────────────────────────────────────────────
function discoverFiles(dir, includeTsFiles) {
  const svelteExt = new Set(['.svelte']);
  const tsExt     = new Set(['.ts', '.js', '.mts', '.mjs']);
  const skip      = new Set(['node_modules', '.svelte-kit', 'dist', 'build', '.git']);
  const files     = [];

  function walk(d) {
    for (const entry of readdirSync(d, { withFileTypes: true })) {
      if (entry.name.startsWith('.') && entry.name !== '.svelte') continue;
      if (skip.has(entry.name)) continue;
      const full = join(d, entry.name);
      if (entry.isDirectory()) { walk(full); continue; }
      const ext = extname(entry.name);
      if (svelteExt.has(ext) || (includeTsFiles && tsExt.has(ext))) {
        if (entry.name.includes('.test.') || entry.name.includes('.spec.')) continue;
        files.push(full);
      }
    }
  }

  walk(dir);
  files.sort();
  return files;
}

// ── Top-level dispatcher ─────────────────────────────────────────────
function parseFile(filePath) {
  const source = readFileSync(filePath, 'utf-8');
  return extname(filePath) === '.svelte'
    ? parseSvelteFile(filePath, source)
    : parseTsFile(filePath, source);
}

// ── Svelte file parsing ──────────────────────────────────────────────
function parseSvelteFile(filePath, source) {
  let ast;
  try { ast = svelteParse(source, { modern: true }); }
  catch { ast = svelteParse(source); }

  const result = {
    file: filePath,
    fileType: categorizeSvelteFile(filePath),
    scriptLang: 'js',
    hasModule: false,
    hasStyle: !!ast.css,
    symbols: [],
  };

  // Instance script (<script>)
  if (ast.instance) {
    const lang = getScriptLang(ast.instance, source);
    result.scriptLang = lang;
    const scriptSrc = extractScriptText(source, ast.instance);
    if (scriptSrc) {
      const lineOff = lineFromOffset(source, source.indexOf('>', ast.instance.start) + 1) - 1;
      const syms = parseScript(scriptSrc, filePath, lang === 'ts', false, lineOff);
      result.symbols.push(...syms);
    }
  }

  // Module script (<script module> / <script context="module">)
  if (ast.module) {
    result.hasModule = true;
    const lang = getScriptLang(ast.module, source);
    result.scriptLang = lang;
    const scriptSrc = extractScriptText(source, ast.module);
    if (scriptSrc) {
      const lineOff = lineFromOffset(source, source.indexOf('>', ast.module.start) + 1) - 1;
      const syms = parseScript(scriptSrc, filePath, lang === 'ts', true, lineOff);
      for (const s of syms) if (s._exported) s.scope = 'module';
      result.symbols.push(...syms);
    }
  }

  // Template
  if (ast.fragment) {
    result.symbols.push(...extractTemplateSymbols(ast.fragment, source));
  }

  return result;
}

function extractScriptText(source, scriptNode) {
  if (!scriptNode) return null;
  const openEnd  = source.indexOf('>', scriptNode.start) + 1;
  const closeStart = source.lastIndexOf('</script', scriptNode.end);
  if (openEnd <= 0 || closeStart < 0) return null;
  return source.slice(openEnd, closeStart);
}

function getScriptLang(scriptNode, source) {
  if (!scriptNode?.attributes) return 'js';
  for (const attr of scriptNode.attributes) {
    if (attr.name !== 'lang') continue;
    if (typeof attr.value === 'string') return attr.value;
    if (Array.isArray(attr.value) && attr.value.length > 0) {
      const v = attr.value[0];
      return v.data || v.raw || 'js';
    }
  }
  return 'js';
}

function categorizeSvelteFile(p) {
  const n = basename(p);
  if (n === '+page.svelte')   return 'page';
  if (n === '+layout.svelte') return 'layout';
  if (n === '+error.svelte')  return 'error-page';
  return 'component';
}

// ── TypeScript / JavaScript file parsing ─────────────────────────────
function parseTsFile(filePath, source) {
  const isTs = /\.m?ts$/.test(filePath);
  return {
    file:       filePath,
    fileType:   categorizeTsFile(filePath),
    scriptLang: isTs ? 'ts' : 'js',
    symbols:    parseScript(source, filePath, isTs, true, 0),
  };
}

function categorizeTsFile(p) {
  const n = basename(p);
  if (/^\+page\.server\.[tj]s$/.test(n))   return 'page-server';
  if (/^\+page\.[tj]s$/.test(n))           return 'page-load';
  if (/^\+layout\.server\.[tj]s$/.test(n)) return 'layout-server';
  if (/^\+layout\.[tj]s$/.test(n))         return 'layout-load';
  if (/^\+server\.[tj]s$/.test(n))         return 'api-endpoint';
  return 'module';
}

// ── Script parsing (shared) ──────────────────────────────────────────
function parseScript(source, fileName, isTypeScript, _isModule, lineOffset) {
  const sf = ts.createSourceFile(
    fileName, source, ts.ScriptTarget.Latest, true,
    isTypeScript ? ts.ScriptKind.TS : ts.ScriptKind.JS,
  );
  const symbols = [];
  ts.forEachChild(sf, node => visitNode(node, sf, symbols, source, false));
  for (const s of symbols) if (s.line) s.line += lineOffset;
  return symbols;
}

function visitNode(node, sf, symbols, src, isExported) {
  const SK = ts.SyntaxKind;
  const exported = isExported || hasMod(node, SK.ExportKeyword);

  // ── Variable statement ────────────────────────────────────────
  if (node.kind === SK.VariableStatement) {
    const decls   = node.declarationList;
    const isConst = (decls.flags & ts.NodeFlags.Const) !== 0;
    for (const d of decls.declarations) {
      processVarDecl(d, sf, symbols, src, exported, isConst);
    }
    return;
  }

  // ── Function declaration ──────────────────────────────────────
  if (node.kind === SK.FunctionDeclaration && node.name) {
    symbols.push({
      kind:      K.FUNCTION,
      name:      node.name.text,
      line:      lineOf(sf, node),
      exported,
      _exported: exported,
      signature: funcSig(node, src),
      async:     !!node.modifiers?.some(m => m.kind === SK.AsyncKeyword),
    });
    return;
  }

  // ── Type alias ────────────────────────────────────────────────
  if (node.kind === SK.TypeAliasDeclaration) {
    symbols.push({
      kind:      K.TYPE,
      name:      node.name.text,
      line:      lineOf(sf, node),
      exported,
      _exported: exported,
      signature: node.type ? slice(src, node.type) : '',
    });
    return;
  }

  // ── Interface ─────────────────────────────────────────────────
  if (node.kind === SK.InterfaceDeclaration) {
    const sym = {
      kind:      K.INTERFACE,
      name:      node.name.text,
      line:      lineOf(sf, node),
      exported,
      _exported: exported,
      members:   [],
    };
    if (node.members) {
      for (const m of node.members) {
        if (m.name) sym.members.push(slice(src, m).trim().replace(/;$/, ''));
      }
    }
    symbols.push(sym);
    return;
  }

  // ── Import ────────────────────────────────────────────────────
  if (node.kind === SK.ImportDeclaration) {
    const modSpec = node.moduleSpecifier?.text || '';
    const names   = [];
    let isType    = !!node.importClause?.isTypeOnly;

    if (node.importClause) {
      if (node.importClause.name) names.push(node.importClause.name.text);
      const nb = node.importClause.namedBindings;
      if (nb) {
        if (nb.kind === SK.NamedImports) {
          for (const el of nb.elements) names.push(el.name.text);
        } else if (nb.kind === SK.NamespaceImport) {
          names.push(`* as ${nb.name.text}`);
        }
      }
    }

    symbols.push({
      kind:   K.IMPORT,
      name:   names.join(', '),
      line:   lineOf(sf, node),
      source: modSpec,
      isType,
    });
    return;
  }

  // ── Expression statement ($effect) ────────────────────────────
  if (node.kind === SK.ExpressionStatement) {
    const expr = node.expression;
    if (expr.kind === SK.CallExpression) {
      const callee = calleeText(expr.expression, src);
      if (callee === '$effect' || callee === '$effect.pre' || callee === '$effect.root') {
        symbols.push({
          kind:    K.EFFECT,
          name:    callee,
          line:    lineOf(sf, node),
          variant: callee.includes('.') ? callee.split('.')[1] : 'default',
        });
      }
    }
    return;
  }

  // ── Export named declaration (export const / export function) ──
  if (node.kind === SK.ExportDeclaration) return;
}

function processVarDecl(d, sf, symbols, src, exported, isConst) {
  const init = d.initializer;
  const typeAnn = d.type ? slice(src, d.type).trim() : undefined;

  // ── $props() ──────────────────────────────────────────────────
  if (init && isCall(init) && calleeName(init) === '$props') {
    if (d.name.kind === ts.SyntaxKind.ObjectBindingPattern) {
      // Get type from type parameter if present: $props<Type>()
      let propsType = undefined;
      if (init.typeArguments?.length > 0) {
        propsType = slice(src, init.typeArguments[0]).trim();
      } else if (typeAnn) {
        propsType = typeAnn;
      }
      for (const el of d.name.elements) {
        const pName = el.name.kind === ts.SyntaxKind.Identifier
          ? el.name.text
          : slice(src, el.name).trim();
        symbols.push({
          kind:     K.PROP,
          name:     pName,
          line:     lineOf(sf, el),
          exported: true,
          default:  el.initializer ? slice(src, el.initializer).trim() : undefined,
          propsType,
        });
      }
    } else {
      symbols.push({
        kind:     K.PROP,
        name:     d.name.text || slice(src, d.name).trim(),
        line:     lineOf(sf, d),
        exported: true,
        typeAnnotation: typeAnn,
      });
    }
    return;
  }

  // ── $state() / $state.raw() ───────────────────────────────────
  if (init && isCall(init)) {
    const cn = calleeName(init);
    if (cn === '$state' || cn === '$state.raw') {
      symbols.push({
        kind:     K.STATE,
        name:     d.name.text || slice(src, d.name).trim(),
        line:     lineOf(sf, d),
        exported, _exported: exported,
        initial:  init.arguments.length > 0 ? slice(src, init.arguments[0]).trim() : undefined,
        variant:  cn === '$state.raw' ? 'raw' : 'default',
        typeAnnotation: typeAnn,
        typeParam: init.typeArguments?.length > 0 ? slice(src, init.typeArguments[0]).trim() : undefined,
      });
      return;
    }

    // ── $derived() / $derived.by() ──────────────────────────────
    if (cn === '$derived' || cn === '$derived.by') {
      symbols.push({
        kind:     K.DERIVED,
        name:     d.name.text || slice(src, d.name).trim(),
        line:     lineOf(sf, d),
        exported, _exported: exported,
        expression: cn === '$derived' && init.arguments.length > 0
          ? slice(src, init.arguments[0]).trim() : undefined,
        variant: cn === '$derived.by' ? 'by' : 'default',
        typeAnnotation: typeAnn,
      });
      return;
    }

    // ── $bindable() (inside $props destructuring — but can also be standalone) ──
    if (cn === '$bindable') {
      symbols.push({
        kind:    K.PROP,
        name:    d.name.text || slice(src, d.name).trim(),
        line:    lineOf(sf, d),
        exported: true,
        bindable: true,
        default: init.arguments.length > 0 ? slice(src, init.arguments[0]).trim() : undefined,
      });
      return;
    }
  }

  // ── Regular variable / const ──────────────────────────────────
  const varName = d.name.text || slice(src, d.name).trim();
  symbols.push({
    kind:     isConst ? K.CONST : K.VAR,
    name:     varName,
    line:     lineOf(sf, d),
    exported, _exported: exported,
    typeAnnotation: typeAnn,
    initial:  isConst && init ? summarize(slice(src, init).trim(), 60) : undefined,
  });
}

// ── Template analysis ────────────────────────────────────────────────
function extractTemplateSymbols(fragment, source) {
  const symbols = [];
  const seenComponents = new Set();
  walkTemplate(fragment, symbols, source, seenComponents);
  return symbols;
}

function walkTemplate(node, symbols, source, seen) {
  if (!node) return;

  // Snippet blocks
  if (node.type === 'SnippetBlock') {
    const name = node.expression?.name || node.expression?.value || 'anonymous';
    const params = [];
    if (node.parameters) {
      for (const p of node.parameters) params.push(source.slice(p.start, p.end));
    }
    symbols.push({
      kind:   K.SNIPPET,
      name,
      line:   lineFromOffset(source, node.start),
      params,
    });
  }

  // Component usage (deduplicated)
  if (node.type === 'Component' || node.type === 'InlineComponent') {
    const name = node.name || 'unknown';
    if (!seen.has(name)) {
      seen.add(name);
      symbols.push({
        kind: K.COMPONENT_USE,
        name,
        line: lineFromOffset(source, node.start),
      });
    }
  }

  // Check attributes on elements and components for bind:/use: directives
  if (node.attributes && Array.isArray(node.attributes)) {
    for (const attr of node.attributes) {
      if (attr.type === 'BindDirective' || attr.type === 'Binding') {
        symbols.push({
          kind: K.BINDING,
          name: attr.name,
          line: lineFromOffset(source, attr.start),
          element: node.name || node.type,
        });
      }
      if (attr.type === 'UseDirective' || attr.type === 'Action') {
        symbols.push({
          kind: K.ACTION,
          name: attr.name,
          line: lineFromOffset(source, attr.start),
          element: node.name || node.type,
        });
      }
    }
  }

  // Recurse into children
  const children = node.nodes || node.children || node.body
    || (node.fragment?.nodes) || [];
  if (Array.isArray(children)) {
    for (const child of children) walkTemplate(child, symbols, source, seen);
  }

  // Block branches
  for (const branch of ['consequent', 'alternate', 'pending', 'then', 'catch', 'fallback']) {
    if (node[branch]) walkTemplate(node[branch], symbols, source, seen);
  }
}

// ── Helpers ──────────────────────────────────────────────────────────
function hasMod(node, kind) {
  return node.modifiers?.some(m => m.kind === kind) || false;
}

function lineOf(sf, node) {
  return sf.getLineAndCharacterOfPosition(node.getStart(sf)).line + 1;
}

function lineFromOffset(source, offset) {
  if (offset == null) return 0;
  let line = 1;
  for (let i = 0; i < offset && i < source.length; i++) {
    if (source[i] === '\n') line++;
  }
  return line;
}

function slice(src, node) {
  return src.slice(node.pos, node.end);
}

function isCall(node) {
  return node.kind === ts.SyntaxKind.CallExpression;
}

function calleeName(callExpr) {
  return calleeText(callExpr.expression, '');
}

function calleeText(expr, _src) {
  if (expr.kind === ts.SyntaxKind.Identifier) return expr.text;
  if (expr.kind === ts.SyntaxKind.PropertyAccessExpression) {
    return `${calleeText(expr.expression, _src)}.${expr.name.text}`;
  }
  return '';
}

function funcSig(node, src) {
  const params = node.parameters.map(p => {
    const name = p.name.text || slice(src, p.name).trim();
    const type = p.type ? slice(src, p.type).trim() : '';
    const rest = p.dotDotDotToken ? '...' : '';
    const opt  = p.questionToken ? '?' : '';
    return type ? `${rest}${name}${opt}: ${type}` : `${rest}${name}${opt}`;
  });
  const ret = node.type ? slice(src, node.type).trim() : '';
  return `(${params.join(', ')})${ret ? ': ' + ret : ''}`;
}

function summarize(text, maxLen) {
  if (text.length > maxLen) return text.slice(0, maxLen - 3) + '...';
  return text;
}

// ── Filtering ────────────────────────────────────────────────────────
function filterSymbols(symbols, opts) {
  let result = symbols;

  // Unless filtering by a specific template kind, hide template details by default
  const showTemplate = opts.detail || (opts.kind && TEMPLATE_KINDS.has(opts.kind));

  if (!showTemplate) {
    result = result.filter(s => !TEMPLATE_KINDS.has(s.kind) || s.kind === K.SNIPPET);
  }

  if (opts.kind)   result = result.filter(s => s.kind === opts.kind);
  if (opts.name)   result = result.filter(s => s.name === opts.name);
  if (opts.filter) {
    const f = opts.filter.toLowerCase();
    result = result.filter(s => s.name.toLowerCase().includes(f));
  }

  result.sort((a, b) => {
    const ka = kindOrd(a.kind), kb = kindOrd(b.kind);
    if (ka !== kb) return ka - kb;
    return (a.name || '').localeCompare(b.name || '');
  });

  return result;
}

function kindOrd(k) {
  const order = {
    [K.IMPORT]:        0,
    [K.PROP]:          1,
    [K.STATE]:         2,
    [K.DERIVED]:       3,
    [K.EFFECT]:        4,
    [K.INTERFACE]:     5,
    [K.TYPE]:          6,
    [K.FUNCTION]:      7,
    [K.CONST]:         8,
    [K.VAR]:           9,
    [K.SNIPPET]:      10,
    [K.COMPONENT_USE]:11,
    [K.BINDING]:      12,
    [K.ACTION]:       13,
  };
  return order[k] ?? 99;
}

// ── Text output ──────────────────────────────────────────────────────
function printText(results, detail) {
  for (let i = 0; i < results.length; i++) {
    const r = results[i];
    if (i > 0) write('\n');

    const fname = basename(r.file);
    write(`${r.fileType} ${fname}  (${r.file})\n`);

    const meta = [];
    if (r.scriptLang) meta.push(`lang=${r.scriptLang}`);
    if (r.hasModule)  meta.push('module');
    if (r.hasStyle)   meta.push('style');
    if (meta.length)  write(`  ${meta.join(', ')}\n`);
    write('\n');

    if (r.symbols.length === 0) {
      write('  (no matching symbols)\n');
      continue;
    }

    let curKind = '';
    let propsTypeShown = false;
    for (const s of r.symbols) {
      if (s.kind !== curKind) {
        curKind = s.kind;
        write(`--- ${curKind.toUpperCase()}s ---\n`);
        propsTypeShown = false;
      }
      // Show propsType once when entering prop section with detail
      if (detail && s.kind === K.PROP && s.propsType && !propsTypeShown) {
        write(`  ($props type: ${summarize(s.propsType.replace(/\s+/g, ' '), 80)})\n`);
        propsTypeShown = true;
      }
      printSymbol(s, detail);
    }

    write(`\n(${r.symbols.length} symbols)\n`);
  }
}

function printSymbol(s, detail) {
  const loc = s.line ? `  [line ${s.line}]` : '';

  switch (s.kind) {
    case K.IMPORT: {
      const tp = s.isType ? 'type ' : '';
      write(`  import ${tp}{ ${s.name} } from "${s.source}"${loc}\n`);
      break;
    }
    case K.PROP: {
      const def  = s.default ? ` = ${s.default}` : '';
      const bind = s.bindable ? ' (bindable)' : '';
      write(`  prop ${s.name}${def}${bind}${loc}\n`);
      break;
    }
    case K.STATE: {
      const v    = s.variant === 'raw' ? '.raw' : '';
      const init = s.initial ? `(${s.initial})` : '()';
      const tp   = s.typeParam ? `<${s.typeParam}>` : '';
      write(`  let ${s.name} = $state${v}${tp}${init}${loc}\n`);
      break;
    }
    case K.DERIVED: {
      const v   = s.variant === 'by' ? '.by' : '';
      const expr = s.expression && detail ? ` <- ${s.expression}` : '';
      write(`  let ${s.name} = $derived${v}(...)${expr}${loc}\n`);
      break;
    }
    case K.EFFECT: {
      write(`  ${s.name}(...)${loc}\n`);
      break;
    }
    case K.FUNCTION: {
      const a = s.async ? 'async ' : '';
      const e = s.exported ? 'export ' : '';
      write(`  ${e}${a}function ${s.name}${s.signature || '(...)'}${loc}\n`);
      break;
    }
    case K.CONST: {
      const e = s.exported ? 'export ' : '';
      const v = s.initial && detail ? ` = ${s.initial}` : '';
      const t = s.typeAnnotation ? `: ${s.typeAnnotation}` : '';
      write(`  ${e}const ${s.name}${t}${v}${loc}\n`);
      break;
    }
    case K.VAR: {
      const t = s.typeAnnotation ? `: ${s.typeAnnotation}` : '';
      write(`  let ${s.name}${t}${loc}\n`);
      break;
    }
    case K.TYPE: {
      const e = s.exported ? 'export ' : '';
      const sig = detail && s.signature ? ` = ${s.signature}` : '';
      write(`  ${e}type ${s.name}${sig}${loc}\n`);
      break;
    }
    case K.INTERFACE: {
      const e = s.exported ? 'export ' : '';
      write(`  ${e}interface ${s.name}${loc}\n`);
      if (detail && s.members?.length) {
        for (const m of s.members) write(`    ${m}\n`);
      }
      break;
    }
    case K.SNIPPET: {
      const p = s.params?.length ? `(${s.params.join(', ')})` : '()';
      write(`  {#snippet ${s.name}${p}}${loc}\n`);
      break;
    }
    case K.COMPONENT_USE: {
      write(`  <${s.name} />${loc}\n`);
      break;
    }
    case K.BINDING: {
      const on = s.element ? ` on <${s.element}>` : '';
      write(`  bind:${s.name}${on}${loc}\n`);
      break;
    }
    case K.ACTION: {
      const on = s.element ? ` on <${s.element}>` : '';
      write(`  use:${s.name}${on}${loc}\n`);
      break;
    }
    default:
      write(`  ${s.kind} ${s.name}${loc}\n`);
  }
}

function write(s) { process.stdout.write(s); }

main().catch(e => fatal(e.message));
