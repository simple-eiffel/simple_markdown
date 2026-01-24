# S03: CONTRACTS - simple_markdown

**BACKWASH** | Generated: 2026-01-23 | Library: simple_markdown

## SIMPLE_MARKDOWN Contracts

### make
```eiffel
ensure
  last_html_empty: last_html.is_empty
  headings_empty: headings.is_empty
```

### to_html (a_markdown: STRING): STRING
```eiffel
require
  markdown_not_void: a_markdown /= Void
ensure
  last_html_set: last_html.same_string (Result)
```

### to_html_from_file (a_path: STRING): STRING
```eiffel
require
  path_not_void: a_path /= Void
  path_not_empty: not a_path.is_empty
```

### to_html_fragment (a_markdown: STRING): STRING
```eiffel
require
  markdown_not_void: a_markdown /= Void
```

## Query Contracts

### is_heading (a_line: STRING): BOOLEAN
```eiffel
require
  line_not_void: a_line /= Void
```

### is_blockquote (a_line: STRING): BOOLEAN
```eiffel
require
  line_not_void: a_line /= Void
```

### is_unordered_list_item (a_line: STRING): BOOLEAN
```eiffel
require
  line_not_void: a_line /= Void
```

### is_task_list_item (a_line: STRING): BOOLEAN
```eiffel
require
  line_not_void: a_line /= Void
```

### is_ordered_list_item (a_line: STRING): BOOLEAN
```eiffel
require
  line_not_void: a_line /= Void
```

### is_code_fence (a_line: STRING): BOOLEAN
```eiffel
require
  line_not_void: a_line /= Void
```

### is_horizontal_rule (a_line: STRING): BOOLEAN
```eiffel
require
  line_not_void: a_line /= Void
```

### is_blank_line (a_line: STRING): BOOLEAN
```eiffel
require
  line_not_void: a_line /= Void
```

### is_footnote_definition (a_line: STRING): BOOLEAN
```eiffel
require
  line_not_void: a_line /= Void
```

## Implementation Contracts

### process_line (...)
```eiffel
require
  line_not_void: a_line /= Void
  result_not_void: a_result /= Void
  state_not_void: a_state /= Void
```

### convert_heading (a_line: STRING): STRING
```eiffel
require
  line_not_void: a_line /= Void
  is_heading: is_heading (a_line)
```

## Class Invariants

### SIMPLE_MARKDOWN
```eiffel
invariant
  last_html_exists: last_html /= Void
  headings_exist: headings /= Void
  inline_processor_exists: inline_processor /= Void
  table_processor_exists: table_processor /= Void
```
