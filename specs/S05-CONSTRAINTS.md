# S05: CONSTRAINTS - simple_markdown

**BACKWASH** | Generated: 2026-01-23 | Library: simple_markdown

## Technical Constraints

### Platform
- **OS**: Cross-platform (Windows, Linux, macOS)
- **Compiler**: EiffelStudio 25.02+
- **Concurrency**: SCOOP compatible

### Dependencies
- Eiffel base library only
- No external libraries
- No C code

## Design Constraints

### Markdown Processing
- Line-by-line processing (not AST-based)
- Single-pass for most elements
- Some lookahead for tables

### HTML Output
- Valid HTML5
- UTF-8 encoding
- Minimal formatting (no pretty-printing)

### Memory Model
- No persistent state between conversions
- Heading cache cleared on each conversion
- String-based (no streaming)

## Syntax Constraints

### CommonMark Limitations
- Reference-style links limited
- Complex nesting may not match spec exactly
- Setext headings not supported

### GFM Limitations
- Table alignment markers parsed but not enforced
- Autolinks for URLs only (not emails)

### Extended Syntax Limitations
- Definition lists not supported
- Abbreviations not supported

## Operational Constraints

### Input
- String or file input
- No streaming API
- UTF-8 expected

### Output
- HTML string output
- No streaming output
- No incremental processing

## Known Limitations

1. **No AST Access**
   - Cannot inspect parsed structure
   - No custom renderers

2. **No Incremental Updates**
   - Full re-parse required for changes
   - No change tracking

3. **Limited Nesting**
   - Deep list nesting may behave unexpectedly
   - Blockquote nesting is single-level
