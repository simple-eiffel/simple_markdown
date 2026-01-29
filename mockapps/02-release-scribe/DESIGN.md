# ReleaseScribe - Technical Design

---

## Architecture

### Component Overview

```
+---------------------------------------------------------------+
|                       ReleaseScribe                            |
+---------------------------------------------------------------+
|  CLI Interface Layer                                           |
|    - Argument parsing (simple_cli)                             |
|    - Command routing (generate, init, validate)                |
|    - Output formatting (Markdown, JSON)                        |
+---------------------------------------------------------------+
|  Git Integration Layer                                         |
|    - Commit history reader                                     |
|    - Tag/version detector                                      |
|    - Conventional Commits parser                               |
+---------------------------------------------------------------+
|  Processing Layer                                              |
|    - Change categorizer                                        |
|    - Version calculator (semver)                               |
|    - Breaking change detector                                  |
+---------------------------------------------------------------+
|  Output Layer                                                  |
|    - Template engine (simple_template)                         |
|    - Markdown generator (simple_markdown)                      |
|    - File writer (simple_file)                                 |
+---------------------------------------------------------------+
```

### Class Design

| Class | Responsibility | Key Features |
|-------|----------------|--------------|
| `RELSCRIBE_CLI` | Command-line interface | `parse_args`, `execute`, `output_result` |
| `RELSCRIBE_CONFIG` | Configuration management | `load`, `validate`, `defaults` |
| `RELSCRIBE_GIT` | Git repository interaction | `read_commits`, `get_tags`, `detect_version` |
| `RELSCRIBE_PARSER` | Conventional Commits parsing | `parse_message`, `extract_type`, `extract_scope` |
| `RELSCRIBE_CHANGE` | Single change representation | `type`, `scope`, `description`, `breaking` |
| `RELSCRIBE_VERSION` | Semantic versioning | `parse`, `bump`, `compare`, `format` |
| `RELSCRIBE_GROUPER` | Change categorization | `group_by_type`, `sort_changes`, `filter` |
| `RELSCRIBE_GENERATOR` | Output generation | `generate_markdown`, `generate_json`, `generate_html` |

### Command Structure

```bash
relscribe <command> [options] [arguments]

Commands:
  generate      Generate changelog/release notes
  init          Initialize configuration file
  validate      Validate commit messages
  version       Calculate next version from commits

Global Options:
  --config FILE     Configuration file (default: .relscribe.yaml)
  --repo PATH       Repository path (default: current directory)
  --verbose         Verbose output
  --quiet           Suppress non-error output
  --json            Output in JSON format
  --help            Show help

Generate Options:
  --from TAG        Start from tag (default: previous tag)
  --to REF          End at ref (default: HEAD)
  --output FILE     Output file (default: stdout)
  --format FMT      Output format: markdown|html|json (default: markdown)
  --template FILE   Custom template file
  --unreleased      Include unreleased changes section

Version Options:
  --bump TYPE       Force bump type: major|minor|patch
  --prerelease ID   Add prerelease identifier (alpha, beta, rc)

Examples:
  relscribe generate --from v1.0.0 --to HEAD
  relscribe generate --unreleased --output CHANGELOG.md
  relscribe version --bump minor
  relscribe validate HEAD~10..HEAD
```

### Data Flow

```
Git Repository              Parsing                 Processing              Output
--------------              -------                 ----------              ------

.git/
  |
  +-- commits  ------>  RELSCRIBE_GIT  ------>  RELSCRIBE_PARSER  ------>  RELSCRIBE_CHANGE[]
  |                          |                        |                         |
  +-- tags                   |                        |                         v
                             v                        v                    RELSCRIBE_GROUPER
                    commit messages         type, scope, body                   |
                             |                        |                         v
                             v                        v               Categorized changes:
                     RELSCRIBE_VERSION      RELSCRIBE_CHANGE            - Features
                             |                        |                 - Bug Fixes
                             v                        |                 - Breaking Changes
                    next_version              is_breaking?              - etc.
                                                                             |
                                                                             v
.relscribe.yaml  ------->  RELSCRIBE_CONFIG  ----------------->  RELSCRIBE_GENERATOR
                                                                             |
                                                                             v
                                                                  CHANGELOG.md / JSON / HTML
```

### Conventional Commits Parsing

```
<type>[optional scope][!]: <description>

[optional body]

[optional footer(s)]
```

**Supported types:**
| Type | Description | Changelog Section |
|------|-------------|-------------------|
| `feat` | New feature | Features |
| `fix` | Bug fix | Bug Fixes |
| `docs` | Documentation | Documentation |
| `style` | Formatting | Styles |
| `refactor` | Code restructure | Refactoring |
| `perf` | Performance | Performance |
| `test` | Testing | Tests |
| `build` | Build system | Build |
| `ci` | CI configuration | CI |
| `chore` | Maintenance | Chores |
| `revert` | Revert commit | Reverts |

**Breaking change indicators:**
- `!` after type/scope: `feat!: major change`
- `BREAKING CHANGE:` in footer
- `BREAKING-CHANGE:` in footer

### Configuration Schema

```yaml
# .relscribe.yaml
output:
  file: "CHANGELOG.md"
  format: "markdown"           # markdown | html | json
  header: "# Changelog"

commits:
  types:
    feat: "Features"
    fix: "Bug Fixes"
    docs: "Documentation"
    perf: "Performance"
    refactor: "Code Refactoring"
    test: "Tests"
    build: "Build System"
    ci: "CI/CD"
    chore: false               # false = exclude from changelog
    style: false

  scopes:
    api: "API"
    cli: "CLI"
    core: "Core"

versioning:
  strategy: "semver"           # semver | calver | custom
  prefix: "v"                  # Tag prefix
  prerelease: null             # alpha, beta, rc

template:
  path: null                   # Custom template path
  date_format: "%Y-%m-%d"
  show_authors: false
  show_commit_links: true
  repo_url: "https://github.com/org/repo"

filtering:
  include_merge_commits: false
  include_reverts: true
  exclude_patterns: []
```

### Error Handling

| Error Type | Handling | User Message |
|------------|----------|--------------|
| Not a Git repository | Fail | "Not a Git repository. Run from repository root or use --repo" |
| No commits found | Warn | "No commits found between v1.0.0 and HEAD" |
| Invalid commit format | Warn/skip | "Warning: Commit abc123 doesn't follow Conventional Commits format" |
| Unknown tag | Fail | "Tag 'v1.0.0' not found. Available: v0.9.0, v0.8.0" |
| Template error | Fail | "Template error in custom.md line 5: undefined variable 'foo'" |
| Invalid config | Fail | "Configuration error: 'output.format' must be markdown, html, or json" |

---

## GUI/TUI Future Path

**CLI foundation enables:**

1. **Shared parsing engine** - `RELSCRIBE_PARSER` and `RELSCRIBE_GROUPER` work identically across all interfaces.

2. **Configuration-driven** - All settings in `.relscribe.yaml`, GUI becomes visual config editor.

3. **Streaming output** - Changelog generation can stream to GUI preview.

**What would change for TUI:**
- Add `simple_tui` for terminal interface
- Interactive commit browser
- Version bump preview
- Side-by-side diff view

**What would change for GUI:**
- Visual commit timeline
- Drag-drop change reordering
- Template preview editor
- GitHub/GitLab integration panel

**Shared components between CLI/GUI:**
- `RELSCRIBE_GIT` - same Git interaction
- `RELSCRIBE_PARSER` - same commit parsing
- `RELSCRIBE_GROUPER` - same categorization
- `RELSCRIBE_GENERATOR` - same output generation
