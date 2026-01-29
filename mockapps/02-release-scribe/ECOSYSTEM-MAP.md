# ReleaseScribe - Ecosystem Integration

---

## simple_* Dependencies

### Required Libraries

| Library | Purpose | Integration Point |
|---------|---------|-------------------|
| `simple_markdown` | Output formatting | `RELSCRIBE_GENERATOR` Markdown output |
| `simple_json` | Configuration, API output | Config parsing, JSON changelog format |
| `simple_cli` | Argument parsing | `RELSCRIBE_CLI` command interface |
| `simple_file` | File I/O, Git interaction | Changelog writing, .git reading |
| `simple_template` | Custom templates | Release notes templating |
| `simple_datetime` | Dates and timestamps | Version dates, commit timestamps |

### Optional Libraries

| Library | Purpose | When Needed |
|---------|---------|-------------|
| `simple_yaml` | YAML configuration | When using .relscribe.yaml |
| `simple_http` | GitHub/GitLab API | Fetching PR/issue titles |
| `simple_hash` | Commit verification | Validating commit SHAs |
| `simple_csv` | Statistics export | `--stats` output option |

---

## Integration Patterns

### simple_markdown Integration

**Purpose:** Format release notes with proper Markdown structure

**Usage:**
```eiffel
class RELSCRIBE_GENERATOR

feature -- Markdown Generation

    generate_markdown: STRING
            -- Generate Markdown changelog from grouped changes.
        local
            l_md: SIMPLE_MARKDOWN
            l_result: STRING
        do
            create Result.make (1024)

            -- Header
            Result.append ("# ")
            Result.append (config.header)
            Result.append ("%N%N")

            -- Version section
            Result.append ("## [")
            Result.append (version.to_string)
            Result.append ("] - ")
            Result.append (release_date)
            Result.append ("%N%N")

            -- Breaking changes (if any)
            if not breaking_changes.is_empty then
                Result.append ("### Breaking Changes%N%N")
                across breaking_changes as ic loop
                    Result.append ("- ")
                    Result.append (ic.item.description)
                    Result.append ("%N")
                end
                Result.append ("%N")
            end

            -- Features
            if not features.is_empty then
                Result.append ("### Features%N%N")
                across features as ic loop
                    format_change (ic.item, Result)
                end
                Result.append ("%N")
            end

            -- Bug fixes
            if not fixes.is_empty then
                Result.append ("### Bug Fixes%N%N")
                across fixes as ic loop
                    format_change (ic.item, Result)
                end
            end

            -- Validate Markdown
            create l_md.make
            last_html := l_md.to_html (Result)
        ensure
            valid_markdown: last_html /= Void
        end

feature {NONE} -- Implementation

    format_change (a_change: RELSCRIBE_CHANGE; a_result: STRING)
            -- Format single change as Markdown list item.
        do
            a_result.append ("- ")
            if attached a_change.scope as l_scope then
                a_result.append ("**")
                a_result.append (l_scope)
                a_result.append (":** ")
            end
            a_result.append (a_change.description)
            if config.show_commit_links then
                a_result.append (" ([")
                a_result.append (a_change.short_sha)
                a_result.append ("](")
                a_result.append (config.repo_url)
                a_result.append ("/commit/")
                a_result.append (a_change.sha)
                a_result.append ("))")
            end
            a_result.append ("%N")
        end

end
```

**Data flow:**
```
RELSCRIBE_GROUPER.features/fixes/breaking_changes
                |
                v
        RELSCRIBE_GENERATOR.generate_markdown
                |
                v
        Markdown string with proper formatting
                |
                v
        SIMPLE_MARKDOWN.to_html (validation)
                |
                v
        SIMPLE_FILE.write (CHANGELOG.md)
```

---

### simple_json Integration

**Purpose:** Configuration parsing, JSON output format, API responses

**Usage:**
```eiffel
class RELSCRIBE_GENERATOR

feature -- JSON Generation

    generate_json: STRING
            -- Generate JSON changelog.
        local
            l_json: SIMPLE_JSON
            l_root: JSON_OBJECT
            l_releases: JSON_ARRAY
            l_release: JSON_OBJECT
            l_changes: JSON_ARRAY
        do
            create l_json.make

            create l_root.make_empty
            l_root.put_string (config.project_name, "project")
            l_root.put_string (version.to_string, "version")
            l_root.put_string (release_date, "date")

            create l_changes.make_empty
            across all_changes as ic loop
                l_changes.extend (change_to_json (ic.item))
            end
            l_root.put (l_changes, "changes")

            -- Statistics
            l_root.put_integer (features.count, "features_count")
            l_root.put_integer (fixes.count, "fixes_count")
            l_root.put_integer (breaking_changes.count, "breaking_count")
            l_root.put_integer (all_changes.count, "total_count")

            Result := l_root.to_string
        end

feature {NONE} -- JSON Helpers

    change_to_json (a_change: RELSCRIBE_CHANGE): JSON_OBJECT
            -- Convert change to JSON object.
        do
            create Result.make_empty
            Result.put_string (a_change.commit_type, "type")
            if attached a_change.scope as l_scope then
                Result.put_string (l_scope, "scope")
            end
            Result.put_string (a_change.description, "description")
            Result.put_string (a_change.sha, "sha")
            Result.put_boolean (a_change.is_breaking, "breaking")
            if attached a_change.author as l_author then
                Result.put_string (l_author, "author")
            end
        end

end
```

---

### simple_cli Integration

**Purpose:** Command-line interface, argument parsing, help generation

**Usage:**
```eiffel
class RELSCRIBE_CLI

feature -- Entry Point

    make
            -- Application entry point.
        local
            l_cli: SIMPLE_CLI
        do
            create l_cli.make ("relscribe", "Automated changelog generator")

            -- Commands
            l_cli.add_command ("generate", "Generate changelog/release notes", agent do_generate)
            l_cli.add_command ("init", "Initialize configuration", agent do_init)
            l_cli.add_command ("validate", "Validate commit messages", agent do_validate)
            l_cli.add_command ("version", "Calculate next version", agent do_version)

            -- Global options
            l_cli.add_option ("config", "c", "Configuration file", "FILE")
            l_cli.add_option ("repo", "r", "Repository path", "PATH")
            l_cli.add_flag ("verbose", "v", "Verbose output")
            l_cli.add_flag ("quiet", "q", "Suppress non-error output")
            l_cli.add_flag ("json", "j", "JSON output format")

            -- Generate options
            l_cli.add_option ("from", "f", "Start from tag", "TAG")
            l_cli.add_option ("to", "t", "End at ref", "REF")
            l_cli.add_option ("output", "o", "Output file", "FILE")
            l_cli.add_option ("format", Void, "Output format", "FMT")
            l_cli.add_option ("template", Void, "Custom template", "FILE")
            l_cli.add_flag ("unreleased", "u", "Include unreleased section")

            l_cli.execute (command_line_arguments)
        end

feature {NONE} -- Commands

    do_generate (a_args: CLI_ARGS)
            -- Execute generate command.
        local
            l_config: RELSCRIBE_CONFIG
            l_git: RELSCRIBE_GIT
            l_grouper: RELSCRIBE_GROUPER
            l_generator: RELSCRIBE_GENERATOR
            l_output: STRING
        do
            -- Load configuration
            create l_config.make
            l_config.load (a_args.option_or_default ("config", ".relscribe.yaml"))

            -- Read Git history
            create l_git.make (a_args.option_or_default ("repo", "."))
            l_git.read_commits (
                a_args.option ("from"),
                a_args.option_or_default ("to", "HEAD")
            )

            -- Group changes
            create l_grouper.make (l_config)
            l_grouper.process (l_git.commits)

            -- Generate output
            create l_generator.make (l_config, l_grouper)
            inspect a_args.option_or_default ("format", "markdown")
            when "markdown" then
                l_output := l_generator.generate_markdown
            when "json" then
                l_output := l_generator.generate_json
            when "html" then
                l_output := l_generator.generate_html
            end

            -- Write or print
            if attached a_args.option ("output") as l_path then
                write_file (l_path, l_output)
            else
                print (l_output)
            end
        end

end
```

---

### simple_datetime Integration

**Purpose:** Version dates, commit timestamps, date formatting

**Usage:**
```eiffel
class RELSCRIBE_GENERATOR

feature -- Date Handling

    release_date: STRING
            -- Current date formatted for changelog.
        local
            l_dt: SIMPLE_DATETIME
        do
            create l_dt.make_now
            Result := l_dt.format (config.date_format)
        ensure
            not_empty: not Result.is_empty
        end

end

class RELSCRIBE_CHANGE

feature -- Access

    commit_date: SIMPLE_DATETIME
            -- When commit was made.

    format_date (a_format: STRING): STRING
            -- Format commit date.
        do
            Result := commit_date.format (a_format)
        end

end
```

---

### simple_template Integration

**Purpose:** Custom release notes templates

**Usage:**
```eiffel
class RELSCRIBE_GENERATOR

feature -- Template Rendering

    generate_from_template: STRING
            -- Generate output using custom template.
        local
            l_template: SIMPLE_TEMPLATE
            l_context: TEMPLATE_CONTEXT
        do
            create l_template.make
            l_template.load (config.template_path)

            create l_context.make
            l_context.put_string (version.to_string, "version")
            l_context.put_string (release_date, "date")
            l_context.put_list (features, "features")
            l_context.put_list (fixes, "fixes")
            l_context.put_list (breaking_changes, "breaking")
            l_context.put_integer (all_changes.count, "total_changes")
            l_context.put_string (config.project_name, "project")

            Result := l_template.render (l_context)
        end

end
```

**Example template:**
```
# {{ project }} Release Notes

## Version {{ version }} ({{ date }})

{% if breaking %}
### Breaking Changes

{% for change in breaking %}
- {{ change.description }}
{% endfor %}
{% endif %}

### New Features

{% for feature in features %}
- {% if feature.scope %}**{{ feature.scope }}:** {% endif %}{{ feature.description }}
{% endfor %}

### Bug Fixes

{% for fix in fixes %}
- {% if fix.scope %}**{{ fix.scope }}:** {% endif %}{{ fix.description }}
{% endfor %}

---
*{{ total_changes }} changes in this release*
```

---

## Dependency Graph

```
relscribe
    |
    +-- simple_markdown (required)
    |   +-- ISE base
    |
    +-- simple_json (required)
    |   +-- ISE base
    |
    +-- simple_cli (required)
    |   +-- ISE base
    |
    +-- simple_file (required)
    |   +-- ISE base
    |
    +-- simple_template (required)
    |   +-- ISE base
    |
    +-- simple_datetime (required)
    |   +-- ISE base
    |
    +-- simple_yaml (optional, for config)
    |   +-- ISE base
    |
    +-- simple_http (optional, for GitHub API)
    |   +-- ISE base
    |
    +-- ISE base (required)
```

---

## ECF Configuration

```xml
<?xml version="1.0" encoding="ISO-8859-1"?>
<system xmlns="http://www.eiffel.com/developers/xml/configuration-1-22-0"
        name="relscribe"
        uuid="B2C3D4E5-F6A7-8901-BCDE-F23456789012">

    <description>ReleaseScribe - Automated Changelog Generator</description>

    <!-- Library target (reusable core) -->
    <target name="relscribe">
        <root class="RELSCRIBE_CLI" feature="make"/>

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
        <library name="simple_cli"
                 location="$SIMPLE_EIFFEL/simple_cli/simple_cli.ecf"/>
        <library name="simple_file"
                 location="$SIMPLE_EIFFEL/simple_file/simple_file.ecf"/>
        <library name="simple_template"
                 location="$SIMPLE_EIFFEL/simple_template/simple_template.ecf"/>
        <library name="simple_datetime"
                 location="$SIMPLE_EIFFEL/simple_datetime/simple_datetime.ecf"/>

        <!-- Optional libraries -->
        <library name="simple_yaml"
                 location="$SIMPLE_EIFFEL/simple_yaml/simple_yaml.ecf"/>

        <!-- ISE dependencies -->
        <library name="base" location="$ISE_LIBRARY/library/base/base.ecf"/>
        <library name="process" location="$ISE_LIBRARY/library/process/process.ecf"/>

        <!-- Source clusters -->
        <cluster name="src" location="src/" recursive="true"/>
    </target>

    <!-- CLI executable target -->
    <target name="relscribe_cli" extends="relscribe">
        <root class="RELSCRIBE_CLI" feature="make"/>
    </target>

    <!-- Test target -->
    <target name="relscribe_tests" extends="relscribe">
        <root class="TEST_APP" feature="make"/>
        <library name="simple_testing"
                 location="$SIMPLE_EIFFEL/simple_testing/simple_testing.ecf"/>
        <cluster name="tests" location="tests/" recursive="true"/>
    </target>

</system>
```
