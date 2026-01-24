# S07: SPECIFICATION SUMMARY - simple_markdown

**BACKWASH** | Generated: 2026-01-23 | Library: simple_markdown

## Library Identity

- **Name**: simple_markdown
- **Version**: 1.0
- **Category**: Content Processing
- **Status**: Production

## Purpose Statement

simple_markdown provides a pure-Eiffel Markdown to HTML converter with comprehensive syntax support including CommonMark, GitHub Flavored Markdown, and extended syntax features.

## Key Capabilities

1. **CommonMark Core**
   - Headings, paragraphs, lists
   - Code blocks and inline code
   - Links and images
   - Blockquotes, horizontal rules
   - Bold, italic formatting

2. **GFM Extensions**
   - Tables with alignment
   - Task lists with checkboxes
   - Strikethrough text
   - Autolinks

3. **Extended Syntax**
   - Footnotes
   - Highlight, subscript, superscript
   - Custom heading IDs
   - Table of contents generation

4. **Practical Features**
   - File input support
   - Fragment processing
   - Heading extraction for TOC

## Architecture Summary

- **Pattern**: Facade with internal processors
- **Processing**: Line-by-line state machine
- **Dependencies**: None (base library only)

## Quality Attributes

| Attribute | Target |
|-----------|--------|
| Correctness | CommonMark 95%+ |
| Performance | > 1MB/s |
| Memory | Linear in output size |
| Security | HTML escaping by default |

## API Surface

### Primary API
- `to_html (a_markdown: STRING): STRING`
- `to_html_from_file (a_path: STRING): STRING`
- `to_html_fragment (a_markdown: STRING): STRING`
- `table_of_contents: STRING`

### Secondary API
- Block detection queries (is_heading, is_list_item, etc.)
- headings attribute for TOC generation
