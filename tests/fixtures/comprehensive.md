# Comprehensive Markdown Test

**Documentation** | **Build Video** | [External Link](https://example.com)

This file tests all markdown features supported by the simple_markdown library.

## CommonMark Core Features

### Headings

# H1 Heading
## H2 Heading
### H3 Heading
#### H4 Heading
##### H5 Heading
###### H6 Heading

### Emphasis

This is **bold text** and this is __also bold__.

This is *italic text* and this is _also italic_.

This is ***bold and italic*** combined.

### Inline Code

Use `print ("Hello")` to output text. The `SIMPLE_MARKDOWN` class is the main API.

HTML in code should be escaped: `<script>alert('xss')</script>`

### Links and Images

[Simple Markdown Docs](https://ljr1981.github.io/simple_markdown/)

![Logo](https://example.com/logo.png)

### Lists

Unordered list:
- First item
- Second item
- Third item

Alternative markers:
* Star item
+ Plus item

Ordered list:
1. First step
2. Second step
3. Third step

### Blockquotes

> This is a blockquote.
> It can span multiple lines.

### Code Blocks

```eiffel
class HELLO_WORLD

create
    make

feature {NONE}

    make
        do
            print ("Hello, World!")
        end

end
```

```xml
<library name="simple_markdown" location="$SIMPLE_MARKDOWN\simple_markdown.ecf"/>
```

### Horizontal Rules

---

***

___

### Paragraphs

This is the first paragraph with some text.

This is the second paragraph separated by a blank line.

## GFM Extensions

### Strikethrough

This is ~~deleted text~~ that should be struck through.

### Tables

| Feature | Description | Status |
|---------|-------------|--------|
| `to_html` | Convert markdown to HTML | Done |
| `to_html_from_file` | Convert file to HTML | Done |
| `table_of_contents` | Generate TOC | Done |

### Task Lists

- [ ] Unchecked task
- [x] Completed task
- [ ] Another pending task

### Autolinks

Visit https://example.com for more info.

Check http://test.org/path?query=1 too.

## Extended Syntax

### Highlight

This is ==highlighted text== that should use mark tags.

### Superscript and Subscript

The formula is x^2^ + y^2^ = z^2^.

Water is H~2~O and carbon dioxide is CO~2~.

### Footnotes

Here is a footnote reference[^1] in the text.

Another footnote[^note] here.

[^1]: This is the footnote definition.
[^note]: Named footnotes work too.

### Custom Heading IDs

### Introduction {#intro}

This heading has a custom ID.

## Edge Cases

### Empty Elements

****

____

### Nested Formatting

This is **bold with *italic* inside** it.

### Special Characters

Ampersand: & less than: < greater than: >

### Windows Line Endings

This paragraph uses CRLF line endings.
The parser should handle them correctly.

## End of Test File
