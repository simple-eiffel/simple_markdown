# S06: BOUNDARIES - simple_markdown

**BACKWASH** | Generated: 2026-01-23 | Library: simple_markdown

## System Boundaries

```
+------------------+               +------------------+
|   Application    | -- String --> |  SIMPLE_MARKDOWN |
|                  | <-- HTML ---  |                  |
+------------------+               +------------------+
                                          |
                                          v
                                   +------------------+
                                   |  Internal        |
                                   |  Processors      |
                                   |  - Inline        |
                                   |  - Table         |
                                   |  - State         |
                                   +------------------+
```

## External Interfaces

### Input Boundaries

| Interface | Format | Source |
|-----------|--------|--------|
| Markdown String | UTF-8 text | Application |
| Markdown File | .md file | File system |

### Output Boundaries

| Interface | Format | Destination |
|-----------|--------|-------------|
| HTML String | UTF-8 HTML5 | Application |
| TOC HTML | UTF-8 HTML5 | Application |
| Headings List | Eiffel TUPLE list | Application |

## Module Boundaries

### Public Module (SIMPLE_MARKDOWN)
- to_html, to_html_from_file, to_html_fragment
- table_of_contents
- Syntax detection queries
- headings access

### Internal Modules
- MD_INLINE_PROCESSOR: Not exported
- MD_TABLE_PROCESSOR: Not exported
- MD_PARSE_STATE: Not exported

## Data Flow

```
Input Markdown
     |
     v
Split into Lines
     |
     v
For each line:
  +-- Detect Block Type
  |      |
  |      v
  +-- Update State
  |      |
  |      v
  +-- Process Block
  |      |
  |      v
  +-- Process Inline (via MD_INLINE_PROCESSOR)
  |      |
  |      v
  +-- Append to Result
     |
     v
Close Open Blocks
     |
     v
Output HTML
```

## Trust Boundaries

### Trusted
- Eiffel base library
- File system operations

### Untrusted
- Input Markdown content
- File paths (validated by base library)

## Versioning

- Library version: 1.0
- CommonMark target: 0.30
- GFM target: Current
