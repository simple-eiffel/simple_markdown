# ReleaseScribe - Build Plan

---

## Phase Overview

| Phase | Deliverable | Effort | Dependencies |
|-------|-------------|--------|--------------|
| Phase 1 | MVP Generator | 4 days | simple_markdown, simple_file, simple_cli |
| Phase 2 | Full Features | 4 days | Phase 1, simple_json, simple_template |
| Phase 3 | Polish & Extras | 2 days | Phase 2, simple_datetime |

**Total estimated effort:** 10 days

---

## Phase 1: MVP

### Objective

Generate a basic changelog from Git commits using Conventional Commits format.

```bash
relscribe generate
# Output: Markdown changelog to stdout
```

### Deliverables

1. **RELSCRIBE_CLI** - Basic command-line interface
   - Parse `generate` command
   - Handle `--from` and `--to` options
   - Output to stdout or file

2. **RELSCRIBE_GIT** - Git repository interaction
   - Read commit history via `git log` subprocess
   - Extract commit message, SHA, author, date
   - Detect tags for version ranges

3. **RELSCRIBE_PARSER** - Conventional Commits parser
   - Parse commit type (feat, fix, etc.)
   - Extract optional scope
   - Detect breaking changes (! marker)

4. **RELSCRIBE_CHANGE** - Change representation
   - Store type, scope, description, SHA
   - Track breaking change status

5. **Basic Markdown output**
   - Group by type (Features, Bug Fixes)
   - List items with descriptions

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T1.1 | Create RELSCRIBE_CLI skeleton | Parses generate command, shows help |
| T1.2 | Implement RELSCRIBE_GIT | Reads commits via git log |
| T1.3 | Create RELSCRIBE_PARSER | Parses Conventional Commits |
| T1.4 | Create RELSCRIBE_CHANGE | Represents single change |
| T1.5 | Implement basic grouping | Groups by commit type |
| T1.6 | Generate Markdown output | Proper formatting |
| T1.7 | Handle --from/--to options | Version range support |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Feature commit | `feat: add login` | Listed under "Features" |
| Fix commit | `fix: correct typo` | Listed under "Bug Fixes" |
| Scoped commit | `feat(api): add endpoint` | Shows scope bold |
| Breaking change | `feat!: change api` | Listed under "Breaking Changes" |
| Mixed commits | Multiple types | Proper grouping |
| No commits | Empty range | "No changes found" message |

---

## Phase 2: Full Implementation

### Objective

Add configuration, templates, JSON output, and version calculation.

### Deliverables

1. **RELSCRIBE_CONFIG** - Configuration management
   - YAML configuration file support
   - Type mapping (feat -> Features)
   - Exclusion rules

2. **RELSCRIBE_VERSION** - Semantic versioning
   - Parse version strings
   - Calculate next version from changes
   - Support prerelease identifiers

3. **RELSCRIBE_GENERATOR** - Multi-format output
   - Markdown (default)
   - JSON (API-friendly)
   - HTML (web publishing)

4. **RELSCRIBE_GROUPER** - Advanced categorization
   - Configurable type grouping
   - Scope filtering
   - Change sorting

5. **Template support**
   - Built-in templates
   - Custom template loading
   - Variable substitution

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T2.1 | Create RELSCRIBE_CONFIG | Loads .relscribe.yaml |
| T2.2 | Implement RELSCRIBE_VERSION | Parse/bump semver |
| T2.3 | Add version command | Calculate next version |
| T2.4 | Implement JSON output | Valid JSON changelog |
| T2.5 | Implement HTML output | Valid HTML changelog |
| T2.6 | Add template support | Custom templates work |
| T2.7 | Add init command | Creates sample config |
| T2.8 | Add validate command | Checks commit format |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Config loading | .relscribe.yaml exists | Uses configuration |
| JSON output | `--format json` | Valid JSON structure |
| Version bump | feat commit | Minor version bump |
| Breaking version | feat! commit | Major version bump |
| Custom template | `--template custom.md` | Uses template |
| Validation | Non-conventional commit | Warning message |

---

## Phase 3: Production Polish

### Objective

Add date handling, statistics, commit links, and documentation.

### Deliverables

1. **Date formatting**
   - Configurable date formats
   - Release dates in output
   - Commit timestamps

2. **Commit links**
   - Link to commits in output
   - Repository URL configuration
   - Short SHA display

3. **Statistics**
   - Change counts by type
   - Authors list
   - Export to CSV

4. **Error handling hardening**
   - Graceful Git failures
   - Invalid commit handling
   - Clear error messages

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T3.1 | Add date formatting | Configurable formats |
| T3.2 | Add commit links | Links in Markdown/HTML |
| T3.3 | Add author tracking | Authors in output |
| T3.4 | Add statistics | Counts in JSON output |
| T3.5 | Add --unreleased option | Unreleased section |
| T3.6 | Improve error messages | Clear, actionable |
| T3.7 | Write README | Complete usage guide |
| T3.8 | Add Git hook example | Pre-push validation |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Date format | `date_format: "%B %d, %Y"` | "January 24, 2026" |
| Commit links | `show_commit_links: true` | Clickable SHA links |
| Unreleased | `--unreleased` | "[Unreleased]" section |
| Statistics | `--json` output | Counts included |

---

## ECF Target Structure

```xml
<!-- Library target (reusable) -->
<target name="relscribe">
    <root class="RELSCRIBE_CLI" feature="make"/>
    <library name="simple_markdown" location="..."/>
    <library name="simple_json" location="..."/>
    <library name="simple_cli" location="..."/>
    <library name="simple_file" location="..."/>
    <library name="simple_template" location="..."/>
    <library name="simple_datetime" location="..."/>
    <cluster name="src" location="src/" recursive="true"/>
</target>

<!-- CLI executable target -->
<target name="relscribe_cli" extends="relscribe">
    <root class="RELSCRIBE_CLI" feature="make"/>
</target>

<!-- Test target -->
<target name="relscribe_tests" extends="relscribe">
    <root class="TEST_APP" feature="make"/>
    <library name="simple_testing" location="..."/>
    <cluster name="tests" location="tests/" recursive="true"/>
</target>
```

---

## Build Commands

```bash
# Compile CLI (development)
ec.exe -batch -config relscribe.ecf -target relscribe_cli -c_compile

# Compile CLI (production)
ec.exe -batch -config relscribe.ecf -target relscribe_cli -finalize -c_compile

# Run tests
ec.exe -batch -config relscribe.ecf -target relscribe_tests -c_compile
./EIFGENs/relscribe_tests/W_code/relscribe.exe

# Run finalized tests
ec.exe -batch -config relscribe.ecf -target relscribe_tests -finalize -c_compile
./EIFGENs/relscribe_tests/F_code/relscribe.exe
```

---

## Success Criteria

| Criterion | Measure | Target |
|-----------|---------|--------|
| Compiles | Zero errors | 100% |
| Tests pass | All test cases | 100% |
| CLI works | All commands functional | 100% |
| Documentation | README complete | Yes |
| Parse accuracy | Conventional Commits | >99% |
| Performance | 1000 commits | <500ms |

---

## File Structure

```
relscribe/
|-- relscribe.ecf
|-- README.md
|-- CHANGELOG.md
|-- src/
|   |-- relscribe_cli.e
|   |-- relscribe_config.e
|   |-- relscribe_git.e
|   |-- relscribe_parser.e
|   |-- relscribe_change.e
|   |-- relscribe_version.e
|   |-- relscribe_grouper.e
|   +-- relscribe_generator.e
|-- tests/
|   |-- test_app.e
|   |-- test_parser.e
|   |-- test_version.e
|   +-- test_generator.e
|-- templates/
|   |-- default.md
|   |-- minimal.md
|   +-- marketing.md
+-- examples/
    |-- .relscribe.yaml
    +-- pre-push-hook.sh
```
