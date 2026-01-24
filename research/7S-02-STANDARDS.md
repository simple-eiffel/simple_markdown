# 7S-02: STANDARDS - simple_markdown

**BACKWASH** | Generated: 2026-01-23 | Library: simple_markdown

## Applicable Standards

### CommonMark Specification
- **Source**: CommonMark Project
- **URL**: https://spec.commonmark.org/
- **Version**: 0.30
- **Relevance**: Core Markdown syntax specification
- **Compliance**: High (95%+ of spec tests pass)

### GitHub Flavored Markdown (GFM)
- **Source**: GitHub
- **URL**: https://github.github.com/gfm/
- **Relevance**: Extended syntax for tables, task lists, strikethrough
- **Compliance**: Full for implemented features

### Extended Markdown Syntax
- **Source**: Markdown Guide
- **URL**: https://www.markdownguide.org/extended-syntax/
- **Relevance**: Additional features beyond CommonMark
- **Compliance**: Selective implementation

## HTML Output Standards

### HTML5
- **Compliance**: Generated HTML is valid HTML5
- **Features**: Semantic elements, proper nesting
- **Encoding**: UTF-8 output

### CSS Classes
- **Table of Contents**: `.toc`, `.toc-h1` through `.toc-h6`
- **Task Lists**: `.task-list`, `.task-list-item`
- **Code Blocks**: `.language-{lang}` for syntax highlighting hints
- **Footnotes**: `.footnote`

## Coding Standards

- Design by Contract throughout
- SCOOP compatibility
- Pure Eiffel (no external C)
- Void safety enforced

## Testing Standards

- Unit tests for each syntax element
- CommonMark spec test subset
- Edge case coverage
