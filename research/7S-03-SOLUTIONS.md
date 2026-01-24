# 7S-03: SOLUTIONS - simple_markdown


**Date**: 2026-01-23

**BACKWASH** | Generated: 2026-01-23 | Library: simple_markdown

## Alternative Solutions Evaluated

### 1. External Library Binding
- **Options**: libcmark, commonmark.js via binding
- **Pros**: Fully compliant, well-tested
- **Cons**: External dependency, complex integration
- **Decision**: Rejected - prefer pure Eiffel

### 2. Regex-Only Parser
- **Approach**: Single-pass regex replacement
- **Pros**: Simple implementation
- **Cons**: Cannot handle nested structures properly
- **Decision**: Used for inline elements only

### 3. Full AST Parser
- **Approach**: Build complete abstract syntax tree
- **Pros**: Perfect compliance, extensible
- **Cons**: Complex, more memory, slower
- **Decision**: Future consideration for v2

### 4. Line-by-Line State Machine (Chosen)
- **Approach**: Process lines with state tracking
- **Pros**: Good balance of compliance and simplicity
- **Cons**: Some edge cases harder to handle
- **Decision**: Implemented

## Architecture Decisions

### Modular Processors
- **SIMPLE_MARKDOWN**: Main facade and block processing
- **MD_INLINE_PROCESSOR**: Inline element handling
- **MD_TABLE_PROCESSOR**: Table parsing
- **MD_PARSE_STATE**: State tracking during parsing

### Processing Strategy
1. Split input into lines
2. Process each line based on current state
3. Handle block-level elements (lists, code, tables)
4. Process inline elements within blocks
5. Close open blocks at end

### Inline Processing Order
1. Escape sequences
2. Code spans (to protect from further processing)
3. Images (before links)
4. Links
5. Bold/Italic
6. Extended syntax (strikethrough, highlight, etc.)

## Technology Stack

- Pure Eiffel
- Base library only
- No external dependencies
