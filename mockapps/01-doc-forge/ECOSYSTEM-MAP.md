# DocForge - Ecosystem Integration

---

## simple_* Dependencies

### Required Libraries

| Library | Purpose | Integration Point |
|---------|---------|-------------------|
| `simple_markdown` | Core Markdown-to-HTML conversion | Page content processing |
| `simple_json` | Search index output, API responses | `DOCFORGE_SEARCH`, CLI JSON output |
| `simple_file` | Directory traversal, file I/O | `DOCFORGE_BUILDER`, asset copying |
| `simple_yaml` | Configuration parsing | `DOCFORGE_CONFIG` |
| `simple_cli` | Argument parsing, command routing | `DOCFORGE_CLI` |
| `simple_template` | HTML page templating | `DOCFORGE_THEME` |

### Optional Libraries

| Library | Purpose | When Needed |
|---------|---------|-------------|
| `simple_hash` | Content fingerprinting for cache busting | `--fingerprint` option |
| `simple_http` | Development server | `serve` command |
| `simple_watcher` | File change detection | `--watch` option |
| `simple_datetime` | Build timestamps, last-modified | Metadata generation |
| `simple_csv` | Build statistics export | `--stats` option |

---

## Integration Patterns

### simple_markdown Integration

**Purpose:** Convert Markdown source files to HTML content

**Usage:**
```eiffel
class DOCFORGE_PAGE

feature -- Conversion

    process_content
            -- Convert Markdown source to HTML.
        local
            l_md: SIMPLE_MARKDOWN
        do
            create l_md.make
            html_content := l_md.to_html (markdown_source)
            headings := l_md.headings
            toc_html := l_md.table_of_contents
        ensure
            html_generated: not html_content.is_empty
        end

feature -- Access

    markdown_source: STRING
            -- Raw Markdown content.

    html_content: STRING
            -- Converted HTML.

    headings: ARRAYED_LIST [TUPLE [level: INTEGER; text: STRING; id: detachable STRING]]
            -- Extracted headings for navigation.

    toc_html: STRING
            -- Table of contents HTML.

end
```

**Data flow:**
```
docs/guide.md --> DOCFORGE_PAGE.markdown_source
                       |
                       v
              SIMPLE_MARKDOWN.to_html
                       |
                       v
              DOCFORGE_PAGE.html_content --> DOCFORGE_THEME.apply_template
                       |
                       v
              DOCFORGE_PAGE.headings --> DOCFORGE_NAV.build_tree
```

---

### simple_json Integration

**Purpose:** Generate search index and API output

**Usage:**
```eiffel
class DOCFORGE_SEARCH

feature -- Index Generation

    write_index (a_path: STRING)
            -- Write search index to JSON file.
        local
            l_json: SIMPLE_JSON
            l_array: JSON_ARRAY
            l_entry: JSON_OBJECT
        do
            create l_json.make
            create l_array.make_empty

            across indexed_pages as ic loop
                create l_entry.make_empty
                l_entry.put_string (ic.item.title, "title")
                l_entry.put_string (ic.item.url, "url")
                l_entry.put_string (ic.item.content_snippet, "content")
                l_entry.put_string (ic.item.section, "section")
                l_array.extend (l_entry)
            end

            l_json.write_to_file (l_array.to_string, a_path)
        end

feature {NONE} -- Implementation

    indexed_pages: ARRAYED_LIST [SEARCH_ENTRY]
            -- Pages indexed for search.

end
```

**Data flow:**
```
DOCFORGE_PAGE (multiple) --> DOCFORGE_SEARCH.index_page
                                    |
                                    v
                           indexed_pages (in-memory)
                                    |
                                    v
                           SIMPLE_JSON.write_to_file
                                    |
                                    v
                           _site/search-index.json
```

---

### simple_file Integration

**Purpose:** Directory traversal, file reading/writing, asset management

**Usage:**
```eiffel
class DOCFORGE_BUILDER

feature -- Build

    scan_source_directory
            -- Find all Markdown files in source directory.
        local
            l_file: SIMPLE_FILE
        do
            create l_file.make
            source_files := l_file.glob (source_path, "**/*.md")
        ensure
            files_found: source_files /= Void
        end

    write_output (a_page: DOCFORGE_PAGE)
            -- Write rendered page to output directory.
        local
            l_file: SIMPLE_FILE
            l_output_path: STRING
        do
            create l_file.make
            l_output_path := compute_output_path (a_page)
            l_file.ensure_directory (l_output_path.parent)
            l_file.write (l_output_path, a_page.rendered_html)
        end

    copy_assets
            -- Copy theme assets to output directory.
        local
            l_file: SIMPLE_FILE
        do
            create l_file.make
            l_file.copy_directory (theme.assets_path, output_path + "/assets")
        end

end
```

---

### simple_yaml Integration

**Purpose:** Parse configuration files

**Usage:**
```eiffel
class DOCFORGE_CONFIG

feature -- Loading

    load (a_path: STRING)
            -- Load configuration from YAML file.
        local
            l_yaml: SIMPLE_YAML
            l_doc: YAML_DOCUMENT
        do
            create l_yaml.make
            l_doc := l_yaml.parse_file (a_path)

            site_name := l_doc.string_at ("site.name")
            source_path := l_doc.string_at ("content.source")
            output_path := l_doc.string_at ("content.output")
            theme_name := l_doc.string_at ("theme.name")
            search_enabled := l_doc.boolean_at ("search.enabled")

            validate
        ensure
            config_loaded: is_loaded
        end

feature -- Validation

    validate
            -- Ensure configuration is valid.
        require
            loaded: is_loaded
        do
            check source_path /= Void end
            check output_path /= Void end
        end

end
```

---

### simple_template Integration

**Purpose:** Apply HTML templates to rendered content

**Usage:**
```eiffel
class DOCFORGE_THEME

feature -- Rendering

    apply_template (a_page: DOCFORGE_PAGE): STRING
            -- Apply page template to content.
        local
            l_template: SIMPLE_TEMPLATE
            l_context: TEMPLATE_CONTEXT
        do
            create l_template.make
            l_template.load (page_template_path)

            create l_context.make
            l_context.put_string (a_page.title, "title")
            l_context.put_string (a_page.html_content, "content")
            l_context.put_string (a_page.toc_html, "toc")
            l_context.put_string (navigation_html, "nav")
            l_context.put_string (config.site_name, "site_name")

            Result := l_template.render (l_context)
        end

end
```

---

### simple_cli Integration

**Purpose:** Command-line argument parsing and command routing

**Usage:**
```eiffel
class DOCFORGE_CLI

feature -- Execution

    make
            -- Entry point.
        local
            l_cli: SIMPLE_CLI
        do
            create l_cli.make ("docforge", "Documentation site generator")

            l_cli.add_command ("init", "Initialize new project", agent do_init)
            l_cli.add_command ("build", "Build documentation site", agent do_build)
            l_cli.add_command ("serve", "Start development server", agent do_serve)
            l_cli.add_command ("search", "Search documentation", agent do_search)

            l_cli.add_option ("config", "c", "Configuration file", "FILE")
            l_cli.add_option ("output", "o", "Output directory", "DIR")
            l_cli.add_flag ("verbose", "v", "Verbose output")
            l_cli.add_flag ("json", Void, "JSON output")

            l_cli.execute (command_line_arguments)
        end

feature {NONE} -- Commands

    do_build (a_args: CLI_ARGS)
            -- Execute build command.
        local
            l_config: DOCFORGE_CONFIG
            l_builder: DOCFORGE_BUILDER
        do
            create l_config.make
            l_config.load (a_args.option ("config"))

            create l_builder.make (l_config)
            l_builder.build

            if a_args.flag ("json") then
                print_json_result (l_builder.stats)
            else
                print_summary (l_builder.stats)
            end
        end

end
```

---

## Dependency Graph

```
docforge
    |
    +-- simple_markdown (required)
    |   +-- ISE base
    |
    +-- simple_json (required)
    |   +-- ISE base
    |
    +-- simple_file (required)
    |   +-- ISE base
    |
    +-- simple_yaml (required)
    |   +-- ISE base
    |
    +-- simple_cli (required)
    |   +-- ISE base
    |
    +-- simple_template (required)
    |   +-- ISE base
    |
    +-- simple_hash (optional)
    |   +-- ISE base
    |
    +-- simple_http (optional, for serve)
    |   +-- ISE base
    |
    +-- simple_watcher (optional, for watch)
    |   +-- ISE base
    |
    +-- simple_datetime (optional)
    |   +-- ISE base
    |
    +-- ISE base (required)
```

---

## ECF Configuration

```xml
<?xml version="1.0" encoding="ISO-8859-1"?>
<system xmlns="http://www.eiffel.com/developers/xml/configuration-1-22-0"
        name="docforge"
        uuid="A1B2C3D4-E5F6-7890-ABCD-EF1234567890">

    <description>DocForge - Enterprise Documentation Site Generator</description>

    <!-- Library target (reusable core) -->
    <target name="docforge">
        <root class="DOCFORGE_CLI" feature="make"/>

        <option warning="warning" is_obsolete_iteration="false">
            <assertions precondition="true" postcondition="true"
                        check="true" invariant="true"/>
        </option>

        <setting name="console_application" value="true"/>
        <setting name="dead_code_removal" value="feature"/>

        <!-- simple_* dependencies -->
        <library name="simple_markdown"
                 location="$SIMPLE_EIFFEL/simple_markdown/simple_markdown.ecf"/>
        <library name="simple_json"
                 location="$SIMPLE_EIFFEL/simple_json/simple_json.ecf"/>
        <library name="simple_file"
                 location="$SIMPLE_EIFFEL/simple_file/simple_file.ecf"/>
        <library name="simple_yaml"
                 location="$SIMPLE_EIFFEL/simple_yaml/simple_yaml.ecf"/>
        <library name="simple_cli"
                 location="$SIMPLE_EIFFEL/simple_cli/simple_cli.ecf"/>
        <library name="simple_template"
                 location="$SIMPLE_EIFFEL/simple_template/simple_template.ecf"/>

        <!-- Optional libraries -->
        <library name="simple_hash"
                 location="$SIMPLE_EIFFEL/simple_hash/simple_hash.ecf"/>
        <library name="simple_datetime"
                 location="$SIMPLE_EIFFEL/simple_datetime/simple_datetime.ecf"/>

        <!-- ISE dependencies (only when no simple_* alternative) -->
        <library name="base" location="$ISE_LIBRARY/library/base/base.ecf"/>

        <!-- Source clusters -->
        <cluster name="src" location="src/" recursive="true"/>
    </target>

    <!-- CLI executable target -->
    <target name="docforge_cli" extends="docforge">
        <root class="DOCFORGE_CLI" feature="make"/>
    </target>

    <!-- Test target -->
    <target name="docforge_tests" extends="docforge">
        <root class="TEST_APP" feature="make"/>
        <library name="simple_testing"
                 location="$SIMPLE_EIFFEL/simple_testing/simple_testing.ecf"/>
        <cluster name="tests" location="tests/" recursive="true"/>
    </target>

</system>
```
