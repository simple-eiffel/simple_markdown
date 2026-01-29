# DocForge - Technical Design

---

## Architecture

### Component Overview

```
+---------------------------------------------------------------+
|                         DocForge                               |
+---------------------------------------------------------------+
|  CLI Interface Layer                                           |
|    - Argument parsing (simple_cli)                             |
|    - Command routing (build, serve, init, search)              |
|    - Output formatting (console, JSON)                         |
+---------------------------------------------------------------+
|  Build Engine Layer                                            |
|    - Directory scanner (simple_file)                           |
|    - Markdown processor (simple_markdown)                      |
|    - Template engine (simple_template)                         |
|    - Search indexer                                            |
+---------------------------------------------------------------+
|  Output Layer                                                  |
|    - HTML writer (simple_file)                                 |
|    - Search index writer (simple_json)                         |
|    - Asset copier                                              |
+---------------------------------------------------------------+
|  Configuration Layer                                           |
|    - YAML parser (simple_yaml)                                 |
|    - Schema validator                                          |
|    - Environment resolver                                      |
+---------------------------------------------------------------+
```

### Class Design

| Class | Responsibility | Key Features |
|-------|----------------|--------------|
| `DOCFORGE_CLI` | Command-line interface | `parse_args`, `execute`, `format_output` |
| `DOCFORGE_CONFIG` | Configuration management | `load`, `validate`, `merge_defaults` |
| `DOCFORGE_BUILDER` | Core build orchestration | `build_site`, `process_directory`, `generate_nav` |
| `DOCFORGE_PAGE` | Single page representation | `source_path`, `html_content`, `metadata`, `headings` |
| `DOCFORGE_NAV` | Navigation structure | `build_tree`, `render_html`, `render_json` |
| `DOCFORGE_SEARCH` | Search index generation | `index_page`, `write_index`, `search` |
| `DOCFORGE_THEME` | Theme management | `load_theme`, `apply_template`, `copy_assets` |
| `DOCFORGE_SERVER` | Development server | `serve`, `watch`, `reload` |

### Command Structure

```bash
docforge <command> [options] [arguments]

Commands:
  init          Initialize new documentation project
  build         Build documentation site
  serve         Start development server with live reload
  search        Search documentation content
  validate      Validate configuration and content

Global Options:
  --config FILE     Configuration file (default: docforge.yaml)
  --output DIR      Output directory (default: _site)
  --verbose         Verbose output
  --quiet           Suppress non-error output
  --json            Output in JSON format
  --help            Show help

Build Options:
  --clean           Clean output directory before build
  --drafts          Include draft pages
  --strict          Fail on warnings
  --parallel N      Parallel processing threads

Serve Options:
  --port PORT       Server port (default: 8000)
  --host HOST       Server host (default: localhost)
  --no-reload       Disable live reload

Examples:
  docforge init my-docs
  docforge build --clean --strict
  docforge serve --port 3000
  docforge search "api reference"
```

### Data Flow

```
Input                Processing              Transformation         Output
-----                ----------              --------------         ------

docs/
  |
  +-- index.md  -->  DOCFORGE_BUILDER  -->  DOCFORGE_PAGE  -->  _site/
  |                       |                     |                  |
  +-- guide/              |                     |                  +-- index.html
  |   +-- start.md        |                     |                  +-- guide/
  |   +-- config.md       |                     |                  |   +-- start.html
  |                       v                     v                  |   +-- config.html
  +-- api/           simple_markdown       DOCFORGE_NAV           |
      +-- ref.md     simple_template           |                  +-- api/
                          |                    |                  |   +-- ref.html
                          v                    v                  |
docforge.yaml  -->  DOCFORGE_CONFIG  -->  DOCFORGE_THEME  -->    +-- assets/
                                               |                  |   +-- style.css
                                               v                  |   +-- script.js
                                          DOCFORGE_SEARCH  -->   |
                                                                  +-- search-index.json
```

### Configuration Schema

```yaml
# docforge.yaml
site:
  name: "My Documentation"
  description: "Project documentation"
  url: "https://docs.example.com"
  language: "en"

content:
  source: "docs"
  output: "_site"
  extensions: [".md", ".markdown"]
  exclude: ["_drafts", "*.draft.md"]

navigation:
  auto: true                    # Auto-generate from directory structure
  order: "alphabetical"         # alphabetical, manual, date
  max_depth: 3                  # Navigation tree depth

theme:
  name: "default"               # Built-in theme name
  custom: "themes/custom"       # Or custom theme path
  colors:
    primary: "#2563eb"
    secondary: "#1e40af"

search:
  enabled: true
  index_content: true           # Index full content, not just titles
  min_length: 3                 # Minimum search term length

build:
  clean: true                   # Clean output before build
  minify: true                  # Minify HTML/CSS/JS
  sitemap: true                 # Generate sitemap.xml

metadata:
  author: "Documentation Team"
  version: "1.0.0"
```

### Error Handling

| Error Type | Handling | User Message |
|------------|----------|--------------|
| Missing source directory | Fail with clear message | "Source directory 'docs' not found. Create it or specify --source" |
| Invalid Markdown | Warn and continue | "Warning: Malformed Markdown in guide/start.md line 45" |
| Missing template | Fail | "Theme 'custom' not found. Available: default, minimal, corporate" |
| Config parse error | Fail with line number | "Invalid YAML in docforge.yaml line 12: expected string, got list" |
| Permission denied | Fail | "Cannot write to '_site'. Check permissions." |
| Broken internal link | Warn (strict: fail) | "Warning: Broken link in api/ref.md: '../missing.md'" |

---

## GUI/TUI Future Path

**CLI foundation enables:**

1. **Shared engine** - `DOCFORGE_BUILDER` and `DOCFORGE_PAGE` classes work identically whether invoked from CLI, TUI, or GUI.

2. **Configuration-driven** - All settings live in `docforge.yaml`, so GUI is just a visual editor for the same file.

3. **Watch mode** - `--serve` already supports file watching; GUI just needs to display the preview.

**What would change for TUI:**
- Add `simple_tui` for terminal interface
- Navigation tree browser with vim-like keybindings
- Live preview pane (Markdown on left, rendered HTML on right)
- Build status and error display

**What would change for GUI:**
- Add `simple_gui` wrapper (future library)
- Visual theme editor with color pickers
- Drag-drop page organization
- WYSIWYG Markdown editor with live preview

**Shared components between CLI/GUI:**
- `DOCFORGE_BUILDER` - identical build logic
- `DOCFORGE_CONFIG` - same configuration parsing
- `DOCFORGE_SEARCH` - same search index
- `DOCFORGE_THEME` - same template rendering
