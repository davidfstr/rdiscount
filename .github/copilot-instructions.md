# RDiscount — Copilot Instructions

## Project Overview

RDiscount is a Ruby C extension wrapping David Parsons' [Discount](https://www.pell.portland.or.us/~orc/Code/discount/) Markdown library. It provides fast Markdown-to-HTML conversion from Ruby.

- **Ruby API**: `lib/rdiscount.rb`, `lib/markdown.rb`
- **C bridge**: `ext/rdiscount.c` (Ruby ↔ Discount glue, ~150 LOC)
- **Discount sources**: `ext/*.c`, `ext/*.h` (copied from `discount/` submodule via `rake gather`)
- **Tests**: `test/rdiscount_test.rb`, `test/markdown_test.rb`, plus conformance suites in `test/MarkdownTest_1.0*/`

## Build & Test

```bash
# Build the C extension
rake build

# Run all tests (unit + conformance)
rake test

# Unit tests only
rake test:unit

# Conformance tests (Markdown spec 1.0.3)
rake test:conformance
```

## Architecture

```
discount/          ← Git submodule (upstream Discount C library)
ext/               ← C extension: Discount sources + rdiscount.c bridge + extconf.rb
  rdiscount.c      ← Ruby-C bridge (do NOT overwrite during gather)
  extconf.rb       ← mkmf build config (do NOT overwrite during gather)
  config.h         ← RDiscount-specific (do NOT overwrite during gather)
lib/
  rdiscount.rb     ← Ruby API class, VERSION constant (single source of truth)
  markdown.rb      ← BlueCloth compatibility alias
test/              ← Test::Unit tests + MarkdownTest conformance suites
ext.diff           ← Patches applied to Discount sources in ext/ after copying
```

### How Discount sources flow into ext/

1. `git submodule update --init` fetches `discount/`
2. `cd discount && ./configure.sh` generates config
3. `rake gather` copies `*.c`, `*.h` from `discount/` → `ext/` (skipping files with `main()` and RDiscount-specific files)
4. `ext.diff` is applied via `patch -p1 -d ext`

See [BUILDING](../BUILDING) for the full upgrade procedure.

## Key Conventions

- **Version**: Single source of truth is `VERSION` constant in `lib/rdiscount.rb`. The gemspec extracts it automatically.
- **Testing pattern**: Create `RDiscount.new(text, *flags)`, call `.to_html`, assert output HTML.
- **Locale**: The C bridge sets `LC_CTYPE=C` during processing for consistent ASCII behavior regardless of Ruby's UTF-8 locale.
- **Default flags**: Always enabled: `MKD_TABSTOP | MKD_NOHEADER | MKD_DLEXTRA | MKD_FENCEDCODE | MKD_GITHUBTAGS`.
- **Flag mapping**: Ruby boolean accessors (e.g., `:smart`, `:autolink`) map to Discount C flags in the `ACCESSOR_2_FLAG[]` array in `ext/rdiscount.c`.

## Files You Should NOT Edit Directly

The following files in `ext/` are **copied from discount/** by `rake gather` and will be overwritten:
- All `*.c` and `*.h` files EXCEPT `rdiscount.c`, `extconf.rb`, `config.h`, `ruby-config.h`

To make persistent changes to Discount sources, update `ext.diff` instead.

## Release Process

1. Update `VERSION` in `lib/rdiscount.rb`
2. `rake rdiscount.gemspec` — regenerates file manifest
3. `rake test` — verify all tests pass
4. `gem build rdiscount.gemspec`
5. `gem push rdiscount-X.Y.Z.gem`
