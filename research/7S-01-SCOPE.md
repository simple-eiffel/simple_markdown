# 7S-01: SCOPE - simple_markdown


**Date**: 2026-01-23

**BACKWASH** | Generated: 2026-01-23 | Library: simple_markdown

## Problem Statement

Eiffel applications need to convert Markdown content to HTML for documentation, web content generation, and content management. Existing solutions require external dependencies or lack Eiffel-specific integration and Design by Contract.

## Library Purpose

simple_markdown provides a comprehensive Markdown to HTML converter that is:

1. **CommonMark Compliant** - Standard Markdown syntax support
2. **GFM Extended** - GitHub Flavored Markdown extensions
3. **Extended Syntax** - Additional features like footnotes, highlights
4. **Pure Eiffel** - No external dependencies beyond base
5. **DBC Enabled** - Full contract coverage

## Target Users

- Eiffel developers building documentation tools
- Web applications generating HTML from Markdown
- Content management systems
- Blog/CMS implementations

## Scope Boundaries

### In Scope

**CommonMark Core:**
- Headings (# through ######)
- Bold (**text** or __text__)
- Italic (*text* or _text_)
- Inline code (`code`)
- Code blocks (``` with language hints)
- Links [text](url)
- Images ![alt](url)
- Unordered lists (-, *, +)
- Ordered lists (1. 2. 3.)
- Blockquotes (>)
- Horizontal rules (---, ***, ___)
- Paragraphs

**GFM Extensions:**
- Strikethrough (~~text~~)
- Tables (| col | col |)
- Task lists (- [ ] and - [x])
- Autolinks

**Extended Syntax:**
- Footnotes ([^1] references)
- Highlight (==text==)
- Subscript (~text~) / Superscript (^text^)
- Heading IDs (# Heading {#custom-id})
- Table of contents generation

### Out of Scope
- LaTeX/math rendering
- Custom block types
- Plugin system
- AST export

## Success Metrics

- CommonMark compliance > 95%
- Processing speed > 1MB/s
- Zero memory leaks
