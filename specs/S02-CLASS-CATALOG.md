# S02: CLASS CATALOG - simple_markdown

**BACKWASH** | Generated: 2026-01-23 | Library: simple_markdown

## Core Classes

### SIMPLE_MARKDOWN
- **Purpose**: Main facade for Markdown conversion
- **Role**: Block-level processing, coordinates inline/table processors
- **Key Features**:
  - `to_html`: Convert Markdown string to HTML
  - `to_html_from_file`: Convert file to HTML
  - `to_html_fragment`: Process inline elements only
  - `table_of_contents`: Generate TOC HTML
  - Block detection (heading, list, code, etc.)

### MD_INLINE_PROCESSOR
- **Purpose**: Process inline Markdown elements
- **Role**: Convert inline syntax to HTML
- **Key Features**:
  - Bold/Italic processing
  - Links and images
  - Code spans
  - Extended syntax (strikethrough, highlight, sub/superscript)

### MD_TABLE_PROCESSOR
- **Purpose**: Parse and convert tables
- **Role**: GFM table syntax handling
- **Key Features**:
  - Table row detection
  - Header/separator/body distinction
  - Cell alignment support

### MD_PARSE_STATE
- **Purpose**: Track parser state during processing
- **Role**: State container for multi-line constructs
- **Key Features**:
  - Code block state
  - List state (type, level)
  - Paragraph accumulation
  - Table state

## Class Relationships

```
SIMPLE_MARKDOWN
    |
    +-- MD_INLINE_PROCESSOR (composition)
    |
    +-- MD_TABLE_PROCESSOR (composition)
    |
    +-- MD_PARSE_STATE (local creation)
```

## Design Patterns

### Facade Pattern
- SIMPLE_MARKDOWN as the single entry point
- Hides internal processors from consumers

### State Pattern
- MD_PARSE_STATE tracks parsing context
- State determines line processing behavior

### Strategy Pattern (implicit)
- Different processing for different line types
- Block type detection drives strategy
