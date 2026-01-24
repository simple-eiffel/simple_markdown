# S04: FEATURE SPECIFICATIONS - simple_markdown

**BACKWASH** | Generated: 2026-01-23 | Library: simple_markdown

## SIMPLE_MARKDOWN Features

### Conversion Features

| Feature | Type | Description |
|---------|------|-------------|
| to_html | Query | Convert Markdown string to HTML |
| to_html_from_file | Query | Convert file contents to HTML |
| to_html_fragment | Query | Process inline elements only |

### Access Features

| Feature | Type | Description |
|---------|------|-------------|
| last_html | Query | Result of last conversion |
| headings | Query | Headings found (for TOC) |
| table_of_contents | Query | Generate TOC HTML |

### Detection Features

| Feature | Type | Description |
|---------|------|-------------|
| is_heading | Query | Is line a heading? |
| is_blockquote | Query | Is line a blockquote? |
| is_unordered_list_item | Query | Is line an unordered list item? |
| is_task_list_item | Query | Is line a task list item? |
| is_ordered_list_item | Query | Is line an ordered list item? |
| is_code_fence | Query | Is line a code fence? |
| is_horizontal_rule | Query | Is line a horizontal rule? |
| is_blank_line | Query | Is line blank? |
| is_footnote_definition | Query | Is line a footnote definition? |

## MD_INLINE_PROCESSOR Features

| Feature | Type | Description |
|---------|------|-------------|
| make | Command | Initialize processor |
| process | Query | Process inline elements in text |

### Inline Elements Processed
- Bold (**text** or __text__)
- Italic (*text* or _text_)
- Strikethrough (~~text~~)
- Highlight (==text==)
- Subscript (~text~)
- Superscript (^text^)
- Inline code (`code`)
- Links [text](url)
- Images ![alt](url)
- Footnote references [^id]
- Autolinks

## MD_TABLE_PROCESSOR Features

| Feature | Type | Description |
|---------|------|-------------|
| make | Command | Initialize processor |
| is_table_row | Query | Does line look like table row? |
| is_separator_row | Query | Is line a separator row? |
| convert_table_start | Query | Generate table start HTML |
| convert_table_end | Query | Generate table end HTML |
| convert_tbody_start | Query | Generate tbody start HTML |
| convert_tbody_end | Query | Generate tbody end HTML |
| convert_header_row | Query | Convert header row to HTML |
| convert_body_row | Query | Convert body row to HTML |

## MD_PARSE_STATE Features

| Feature | Type | Description |
|---------|------|-------------|
| make | Command | Initialize state |
| in_code_block | Query | Currently in code block? |
| in_list | Query | Currently in list? |
| list_type | Query | Type of current list |
| in_paragraph | Query | Currently in paragraph? |
| paragraph | Query | Accumulated paragraph text |
| in_table | Query | Currently in table? |
| table_header_done | Query | Has table header been processed? |
| set_* | Commands | State setters |
