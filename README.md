<p align="center">
  <img src="https://raw.githubusercontent.com/simple-eiffel/claude_eiffel_op_docs/main/artwork/LOGO.png" alt="simple_ library logo" width="400">
</p>

# simple_markdown

**[Documentation](https://simple-eiffel.github.io/simple_markdown/)**

Production-ready Markdown to HTML conversion for Eiffel. CommonMark compliant with GitHub Flavored Markdown (GFM) and extended syntax support.

## Features

### CommonMark Core
- **Headings** (# through ######) with auto-generated IDs
- **Bold** (\*\*text\*\* or \_\_text\_\_)
- **Italic** (\*text\* or \_text\_)
- **Inline code** (\`code\`)
- **Code blocks** (\`\`\` with language hints)
- **Links** [text](url)
- **Images** ![alt](url)
- **Lists** (unordered -, *, + and ordered 1. 2. 3.)
- **Blockquotes** (> text)
- **Horizontal rules** (---, \*\*\*, \_\_\_)
- **Paragraphs**

### GFM Extensions
- **Strikethrough** (\~\~text\~\~)
- **Tables** (| col | col |)
- **Task lists** (- [ ] and - [x])
- **Autolinks** (URLs automatically linked)

### Extended Syntax
- **Footnotes** ([^1] references)
- **Highlight** (==text==)
- **Subscript** (\~text\~) / **Superscript** (^text^)
- **Heading IDs** (# Heading {#custom-id})
- **Table of contents** generation

## Installation

Add to your ECF:

```xml
<library name="simple_markdown" location="$SIMPLE_EIFFEL/simple_markdown/simple_markdown.ecf"/>
```

Set environment variable (one-time setup for all simple_* libraries):
```
SIMPLE_EIFFEL=D:\prod
```

## Usage

### Basic Conversion

```eiffel
local
    md: SIMPLE_MARKDOWN
    html: STRING
do
    create md.make
    html := md.to_html ("# Hello World%N%NThis is **bold** text.")
    -- Result: <h1 id="hello-world">Hello World</h1>
    --         <p>This is <strong>bold</strong> text.</p>
end
```

### Parse File

```eiffel
html := md.to_html_from_file ("README.md")
```

### Inline Only (No Block Wrapping)

```eiffel
html := md.to_html_fragment ("**bold** and *italic*")
-- Result: <strong>bold</strong> and <em>italic</em>
```

### GFM Tables

```eiffel
md.to_html ("| Name | Age |%N|------|-----|%N| John | 30  |")
-- Result: <table><thead>...</thead><tbody>...</tbody></table>
```

### Task Lists

```eiffel
md.to_html ("- [ ] Todo%N- [x] Done")
-- Result: <ul class="task-list"><li class="task-list-item">
--         <input type="checkbox" disabled> Todo</li>...
```

### Table of Contents

```eiffel
create md.make
html := md.to_html ("# Intro%N## Chapter 1%N## Chapter 2")
toc := md.table_of_contents
-- Result: <nav class="toc"><ul>
--         <li class="toc-h1"><a href="#intro">Intro</a></li>...
```

### Custom Heading IDs

```eiffel
md.to_html ("# Introduction {#intro}")
-- Result: <h1 id="intro">Introduction</h1>
```

## Architecture

The library uses focused helper classes:

| Class | Responsibility |
|-------|----------------|
| `SIMPLE_MARKDOWN` | Main API, block-level parsing |
| `MD_INLINE_PROCESSOR` | Inline elements (bold, links, etc.) |
| `MD_TABLE_PROCESSOR` | GFM table handling |
| `MD_PARSE_STATE` | Parser state tracking |

## API Reference

### Conversion

| Feature | Description |
|---------|-------------|
| `to_html (STRING): STRING` | Convert markdown to HTML |
| `to_html_from_file (STRING): STRING` | Convert file to HTML |
| `to_html_fragment (STRING): STRING` | Convert inline only |

### Access

| Feature | Description |
|---------|-------------|
| `last_html: STRING` | Result of last conversion |
| `headings: ARRAYED_LIST` | Headings for TOC |
| `table_of_contents: STRING` | Generate HTML TOC |

### Query

| Feature | Description |
|---------|-------------|
| `is_heading (STRING): BOOLEAN` | Check if line is heading |
| `is_blockquote (STRING): BOOLEAN` | Check if blockquote |
| `is_code_fence (STRING): BOOLEAN` | Check if code fence |
| `is_task_list_item (STRING): BOOLEAN` | Check if task list |

## Specifications

- [CommonMark Spec](https://spec.commonmark.org/)
- [GitHub Flavored Markdown](https://github.github.com/gfm/)
- [Extended Syntax Guide](https://www.markdownguide.org/extended-syntax/)

## Use Cases

- **Documentation** - Convert README.md to HTML
- **Blogs/CMS** - Process user content
- **Static sites** - Generate HTML pages
- **Email** - Rich text from markdown
- **Reports** - Technical documentation

## Dependencies

- EiffelBase only

## License

MIT License - Copyright (c) 2024-2025, Larry Rix
