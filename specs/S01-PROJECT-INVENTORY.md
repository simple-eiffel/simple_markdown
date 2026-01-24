# S01: PROJECT INVENTORY - simple_markdown

**BACKWASH** | Generated: 2026-01-23 | Library: simple_markdown

## Project Structure

```
simple_markdown/
  src/
    simple_markdown.e          # Main facade class
    md_inline_processor.e      # Inline element processing
    md_table_processor.e       # Table parsing and conversion
    md_parse_state.e           # Parser state tracking
  testing/
    test_app.e                 # Test application entry
    lib_tests.e                # Test suite
  research/                    # 7S research documents
  specs/                       # Specification documents
  simple_markdown.ecf          # Library ECF configuration
```

## File Counts

| Category | Count |
|----------|-------|
| Source (.e) | 6 |
| Configuration (.ecf) | 1 |
| Documentation (.md) | 15+ |

## Dependencies

### simple_* Ecosystem
- (none - self-contained)

### ISE Libraries
- base

## Build Targets

| Target | Type | Purpose |
|--------|------|---------|
| simple_markdown | library | Reusable library |
| simple_markdown_tests | executable | Test suite |

## Version

Current: 1.0
