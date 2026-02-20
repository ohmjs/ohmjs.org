# CLI Migration Plan

Unify around a single `ohm` CLI shipped by `@ohm-js/compiler`, with `compile`
(wasm-first batch compilation), `match` (wasm-first), and type generation as the
stable surface.

## End-State CLI Surface

Binary name: `ohm` (from `@ohm-js/compiler`)

### `ohm compile <patterns...>`

Compiles `.ohm` sources to wasm artifacts in batch (glob-aware), plus optional
type generation. This is the v18 successor to `generateBundles`.

Flags:

- `--cwd <dir>` — base directory for glob expansion
- `-o, --outDir <dir>` — where to write outputs (default: alongside source)
- `-t, --withTypes` — generate corresponding `.d.ts`
- `-g, --grammarName <name>` — compile only one grammar from a multi-grammar file
  (default: compile all)
- `-n, --dryRun` — print/plan without writing
- `--quiet` / `--verbose`

Output naming:

- `path/to/foo.ohm` → `path/to/foo.ohm.wasm`
- With `--withTypes`: `path/to/foo.ohm.d.ts`

### `ohm match <inputPath>`

Wasm-first matching. Accepts either a `.wasm` artifact or a source `.ohm` file
(compile-then-match).

Flags:

- `-g, --grammar <path>` — `.ohm` (compile in-memory, then match) or `.wasm`
  (load directly)
- `--grammarName <name>` — select grammar from multi-grammar file
- `--startRule <rule>` — optional start rule selection

Behavior: exit 0 on success, non-zero with failure message on mismatch.

### `ohm types <patterns...>` (optional)

Standalone type generation, useful when you want `.d.ts` without emitting wasm.

Flags: `--cwd`, `--outDir`, `--grammarName`, `--dryRun`

### Naming

- Primary verb: `ohm compile` (not `build`), since "compile to wasm" is the core
  v18 story.
- No default action — bare `ohm` shows help.

## Migration Phases

### Phase 0: Today

- `@ohm-js/compiler` ships `ohm2wasm` (single-file, no globs/batch)
- `@ohm-js/cli` ships `ohm` with `generateBundles` (v17 recipes) and `match`
  (v17 runtime)

### Phase 1: Introduce unified `ohm` in the compiler (v18 alpha → early beta)

Goal: make `@ohm-js/compiler` fully usable as the official CLI.

1. Add `ohm` bin entry to `@ohm-js/compiler`, alongside `ohm2wasm`.
2. Refactor `ohm2wasm` implementation into `ohm compile`:
   - Add glob support via `fast-glob`
   - Add `--outDir`, `--cwd`, `--withTypes`, batch compilation
   - If invoked as `ohm2wasm`, behave like `ohm compile <file>` with a
     deprecation warning.
3. Implement `ohm match` wasm-first:
   - `--grammar` accepts `.wasm` (load directly) or `.ohm` (compile-then-match)
4. Move `generateTypes` into `@ohm-js/compiler` (the compiler already bundles
   `ohm-js-legacy` internally via esbuild — use that for type generation without
   exposing it publicly).
5. Update docs to recommend `pnpm add -D @ohm-js/compiler` and `ohm compile`.

### Phase 2: Deprecate `@ohm-js/cli` (v18 beta)

Goal: keep the old install path working while steering users to the compiler.

1. Release a new major of `@ohm-js/cli` that:
   - Depends on `@ohm-js/compiler`
   - Forwards all args to the compiler's `ohm` CLI
   - Prints deprecation warning
2. Compatibility mapping:
   - `ohm generateBundles …` → forwards to `ohm compile …`
   - `ohm match …` → forwards to compiler's `ohm match …`
3. Deprecate the package on npm.

### Phase 3: Compiler CLI is the only real CLI (v18 stable)

1. `@ohm-js/compiler`'s `ohm` is the official CLI in all docs.
2. `@ohm-js/cli` remains as deprecated wrapper only — no new features.
3. `generateBundles` kept as deprecated alias for one stable cycle.

### Phase 4: Clean up (v19 or later)

- Stop publishing `@ohm-js/cli`, or keep as permanent thin wrapper.
- Optionally remove `ohm2wasm` alias, or keep it (low maintenance cost).

## Type Generation in v18

The compiler already bundles `ohm-js-legacy` via esbuild for internal use. Type
generation can reuse this internal representation to produce `.d.ts` files
without exposing legacy APIs publicly.

- Primary: `ohm compile --withTypes`
- Optional: `ohm types <patterns...>` for CI workflows that want types without
  wasm

## Risks and Guardrails

- **Artifact format churn**: lock down output naming (`.ohm.wasm`, `.ohm.d.ts`)
  early.
- **Multi-grammar files**: default is compile all; `--grammarName` selects one.
- **Dependencies**: anything needed at runtime by the CLI (`commander`,
  `fast-glob`) must be in `dependencies` of `@ohm-js/compiler`, not
  `devDependencies`.
- **Node version**: `ohm match` with `.ohm` input requires Node 24 (same as the
  compiler). Document clearly.

## Future Considerations (not now)

- `--emit wasm+js` for generating JS loader modules (depends on v18 runtime
  loading API stabilizing)
- `--watch` mode
- Incremental compilation / caching via `--cacheDir`
