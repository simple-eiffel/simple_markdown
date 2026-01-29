# DocForge - Build Plan

---

## Phase Overview

| Phase | Deliverable | Effort | Dependencies |
|-------|-------------|--------|--------------|
| Phase 1 | MVP CLI | 5 days | simple_markdown, simple_file, simple_cli |
| Phase 2 | Full Build Engine | 5 days | Phase 1, simple_yaml, simple_template |
| Phase 3 | Search & Polish | 3 days | Phase 2, simple_json |

**Total estimated effort:** 13 days

---

## Phase 1: MVP

### Objective

Demonstrate core value: convert a directory of Markdown files to HTML with zero configuration.

```bash
docforge build docs/
# Output: _site/ with converted HTML files
```

### Deliverables

1. **DOCFORGE_CLI** - Basic command-line interface
   - Parse `build` command with source directory argument
   - Handle `--output` option for output directory
   - Display build summary

2. **DOCFORGE_BUILDER** - Core build logic
   - Scan source directory for .md files
   - Process each file through simple_markdown
   - Write HTML to output directory

3. **DOCFORGE_PAGE** - Page representation
   - Store source path, Markdown content, HTML output
   - Extract title from first heading
   - Track conversion status

4. **Basic HTML wrapper** - Minimal template
   - Valid HTML5 structure
   - Page title in `<title>` and `<h1>`
   - Basic CSS for readability

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T1.1 | Create DOCFORGE_CLI skeleton | Parses `build` command, prints help |
| T1.2 | Implement directory scanning | Finds all .md files recursively |
| T1.3 | Create DOCFORGE_PAGE class | Stores source/output paths and content |
| T1.4 | Integrate simple_markdown | Converts Markdown to HTML |
| T1.5 | Write HTML output | Creates output directory structure |
| T1.6 | Add minimal HTML template | Wraps content in valid HTML5 |
| T1.7 | Display build summary | Shows files processed, time taken |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Empty directory | `docforge build empty/` | "No Markdown files found" message |
| Single file | `docs/README.md` | `_site/README.html` with converted content |
| Nested structure | `docs/guide/start.md` | `_site/guide/start.html` |
| GFM features | Tables, task lists | Proper HTML rendering |
| Error handling | Non-existent source | Clear error message, exit code 1 |

---

## Phase 2: Full Implementation

### Objective

Add configuration, templating, and navigation for production-quality documentation sites.

### Deliverables

1. **DOCFORGE_CONFIG** - Configuration management
   - YAML configuration file support
   - Sensible defaults for all options
   - Environment variable expansion

2. **DOCFORGE_THEME** - Theme and templating
   - Load theme from directory
   - Apply templates with variables
   - Copy static assets

3. **DOCFORGE_NAV** - Navigation generation
   - Build navigation tree from directory structure
   - Generate sidebar HTML
   - Support manual ordering

4. **`init` command** - Project scaffolding
   - Create sample docforge.yaml
   - Create sample docs/index.md
   - Create default theme files

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T2.1 | Create DOCFORGE_CONFIG class | Loads YAML, validates schema |
| T2.2 | Add configuration file support | `--config` option, auto-detect docforge.yaml |
| T2.3 | Implement DOCFORGE_THEME | Loads templates, applies variables |
| T2.4 | Create default theme | Professional CSS, responsive layout |
| T2.5 | Add navigation generation | Auto-generates from directory structure |
| T2.6 | Implement `init` command | Creates project scaffold |
| T2.7 | Add page metadata support | YAML frontmatter parsing |
| T2.8 | Add `--clean` option | Removes output before build |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Custom config | `docforge build --config custom.yaml` | Uses custom configuration |
| Default config | `docforge build` (docforge.yaml exists) | Auto-loads configuration |
| Navigation | Multiple pages in structure | Sidebar with links |
| Theme application | Custom theme directory | Uses custom templates |
| Init command | `docforge init my-docs` | Creates scaffold in my-docs/ |

---

## Phase 3: Production Polish

### Objective

Add search, error handling hardening, and production features.

### Deliverables

1. **DOCFORGE_SEARCH** - Full-text search
   - Index page content during build
   - Write JSON search index
   - Include search JavaScript in theme

2. **`serve` command** - Development server
   - Serve output directory
   - Watch for file changes
   - Live reload on change

3. **Error handling hardening**
   - Graceful failure modes
   - Clear error messages
   - Warning vs error distinction

4. **Performance optimization**
   - Parallel file processing
   - Incremental builds (change detection)

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T3.1 | Create DOCFORGE_SEARCH class | Indexes pages, writes JSON |
| T3.2 | Add search JavaScript | Client-side search in browser |
| T3.3 | Implement `serve` command | Starts HTTP server |
| T3.4 | Add file watching | Detects changes, triggers rebuild |
| T3.5 | Add `--strict` mode | Fails on warnings |
| T3.6 | Add broken link detection | Warns/fails on missing links |
| T3.7 | Add `--parallel` option | Multi-threaded processing |
| T3.8 | Write README documentation | Complete usage guide |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Search index | Build with search enabled | search-index.json generated |
| Search query | `docforge search "api"` | Matching pages listed |
| Development server | `docforge serve` | Server at localhost:8000 |
| Broken link detection | Link to missing file | Warning in output |
| Strict mode | `docforge build --strict` (with warnings) | Exit code 1 |

---

## ECF Target Structure

```xml
<!-- Library target (reusable) -->
<target name="docforge">
    <root class="DOCFORGE_CLI" feature="make"/>
    <library name="simple_markdown" location="..."/>
    <library name="simple_json" location="..."/>
    <library name="simple_file" location="..."/>
    <library name="simple_yaml" location="..."/>
    <library name="simple_cli" location="..."/>
    <library name="simple_template" location="..."/>
    <cluster name="src" location="src/" recursive="true"/>
</target>

<!-- CLI executable target -->
<target name="docforge_cli" extends="docforge">
    <root class="DOCFORGE_CLI" feature="make"/>
</target>

<!-- Test target -->
<target name="docforge_tests" extends="docforge">
    <root class="TEST_APP" feature="make"/>
    <library name="simple_testing" location="..."/>
    <cluster name="tests" location="tests/" recursive="true"/>
</target>
```

---

## Build Commands

```bash
# Compile CLI (development)
ec.exe -batch -config docforge.ecf -target docforge_cli -c_compile

# Compile CLI (production)
ec.exe -batch -config docforge.ecf -target docforge_cli -finalize -c_compile

# Run tests
ec.exe -batch -config docforge.ecf -target docforge_tests -c_compile
./EIFGENs/docforge_tests/W_code/docforge.exe

# Run finalized tests
ec.exe -batch -config docforge.ecf -target docforge_tests -finalize -c_compile
./EIFGENs/docforge_tests/F_code/docforge.exe
```

---

## Success Criteria

| Criterion | Measure | Target |
|-----------|---------|--------|
| Compiles | Zero errors | 100% |
| Tests pass | All test cases | 100% |
| CLI works | All commands functional | 100% |
| Documentation | README complete | Yes |
| Performance | Build 100 pages | <1 second |
| Zero config | Works without docforge.yaml | Yes |

---

## File Structure

```
docforge/
|-- docforge.ecf
|-- README.md
|-- CHANGELOG.md
|-- src/
|   |-- docforge_cli.e
|   |-- docforge_config.e
|   |-- docforge_builder.e
|   |-- docforge_page.e
|   |-- docforge_nav.e
|   |-- docforge_search.e
|   |-- docforge_theme.e
|   +-- docforge_server.e
|-- tests/
|   |-- test_app.e
|   |-- test_builder.e
|   |-- test_config.e
|   +-- test_search.e
|-- themes/
|   +-- default/
|       |-- page.html
|       |-- assets/
|       |   |-- style.css
|       |   +-- search.js
+-- examples/
    +-- basic/
        |-- docforge.yaml
        +-- docs/
            |-- index.md
            +-- guide/
                +-- start.md
```
