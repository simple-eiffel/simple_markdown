# 7S-04: SIMPLE-STAR - simple_markdown

**BACKWASH** | Generated: 2026-01-23 | Library: simple_markdown

## Ecosystem Dependencies

### Required simple_* Libraries

| Library | Purpose | Version |
|---------|---------|---------|
| (none) | Self-contained | - |

### ISE Base Libraries Used

| Library | Purpose |
|---------|---------|
| base | Core data structures, strings, files |

## Integration Points

### No External Dependencies
- simple_markdown is intentionally self-contained
- Uses only Eiffel base library
- Can be used without other simple_* libraries

### Optional Integrations

**With simple_http:**
- Generate HTML responses from Markdown content
- Dynamic content conversion

**With simple_file:**
- Batch convert Markdown files
- Directory processing

**With simple_template:**
- Markdown content in templates
- Dynamic documentation generation

## Ecosystem Fit

### Category
Content Processing / Documentation

### Phase
Phase 4 - Production ready with documentation

### Maturity
Production-ready

### Consumers
- simple_doc (documentation generation)
- simple_blog (blog content)
- Any application needing Markdown conversion

## Reuse Patterns

### Basic Usage
```eiffel
md: SIMPLE_MARKDOWN
create md.make
html := md.to_html ("# Hello World")
```

### File Conversion
```eiffel
html := md.to_html_from_file ("README.md")
```

### Table of Contents
```eiffel
md.to_html (content)
toc := md.table_of_contents
```

### Fragment Processing
```eiffel
fragment := md.to_html_fragment ("**bold** and *italic*")
```
