# SpecVault - Build Plan

---

## Phase Overview

| Phase | Deliverable | Effort | Dependencies |
|-------|-------------|--------|--------------|
| Phase 1 | MVP Registry | 5 days | simple_markdown, simple_sql, simple_cli, simple_uuid |
| Phase 2 | Full Features | 6 days | Phase 1, simple_hash, simple_json |
| Phase 3 | Compliance | 4 days | Phase 2, simple_csv, simple_datetime |

**Total estimated effort:** 15 days

---

## Phase 1: MVP

### Objective

Basic document registry: add documents, track versions, list documents.

```bash
specvault init myproject
specvault add docs/SRS-001.md --title "Software Requirements"
specvault list
specvault history SRS-001
```

### Deliverables

1. **SPECVAULT_CLI** - Basic command-line interface
   - Parse init, add, list, history commands
   - Handle document path and title arguments
   - Display formatted output

2. **SPECVAULT_DOCUMENT** - Document representation
   - Store ID, title, type, content
   - Track current version
   - Parse Markdown content

3. **SPECVAULT_REGISTRY** - SQLite document database
   - Create database schema
   - Add/retrieve documents
   - Track versions

4. **SPECVAULT_VERSION** - Version tracking
   - Create version records
   - Store change comments
   - Track timestamps

5. **Database initialization**
   - Create .specvault directory
   - Initialize SQLite database
   - Create tables

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T1.1 | Create SPECVAULT_CLI skeleton | Parses commands, shows help |
| T1.2 | Implement database schema | Creates all tables |
| T1.3 | Create SPECVAULT_DOCUMENT | Stores document data |
| T1.4 | Implement init command | Creates project structure |
| T1.5 | Implement add command | Adds document to registry |
| T1.6 | Implement list command | Shows all documents |
| T1.7 | Implement history command | Shows version history |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Init project | `specvault init test` | Creates .specvault directory |
| Add document | `specvault add doc.md --title "Test"` | Document in registry |
| List empty | `specvault list` | "No documents found" |
| List with docs | After add | Table of documents |
| History | `specvault history SRS-001` | Version list |
| Duplicate add | Add same doc twice | Error message |

---

## Phase 2: Full Implementation

### Objective

Add update tracking, cross-reference validation, export capabilities.

### Deliverables

1. **SPECVAULT_VERSION** (enhanced) - Full version management
   - Content hash verification
   - Version comparison
   - Diff generation

2. **SPECVAULT_REFERENCE** - Cross-reference tracking
   - Extract references from content
   - Validate references exist
   - Report broken links

3. **SPECVAULT_EXPORT** - Output generation
   - HTML export with templates
   - JSON export for API
   - Batch export all documents

4. **Configuration support**
   - YAML configuration file
   - Custom document types
   - Reference patterns

5. **Update command**
   - Require change comment
   - Create new version
   - Update current version pointer

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T2.1 | Add content hashing | Hash stored with version |
| T2.2 | Implement update command | Creates new version |
| T2.3 | Create SPECVAULT_REFERENCE | Extracts references |
| T2.4 | Implement validate command | Reports broken refs |
| T2.5 | Implement HTML export | Valid HTML output |
| T2.6 | Implement JSON export | Valid JSON output |
| T2.7 | Add configuration support | Loads .specvault.yaml |
| T2.8 | Implement status command | Shows document details |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Update document | `specvault update doc.md --comment "Fix typo"` | Version incremented |
| Hash verification | Modify file externally | Warning on status |
| Reference extraction | Doc with [SRS-002] | Reference tracked |
| Broken reference | Doc references non-existent | Warning on validate |
| HTML export | `specvault export --format html` | Valid HTML files |
| JSON export | `specvault export --format json` | Valid JSON output |

---

## Phase 3: Production Polish

### Objective

Add audit trail, compliance reporting, search, and documentation.

### Deliverables

1. **SPECVAULT_AUDIT** - Audit trail management
   - Log all document operations
   - Query audit history
   - Export audit log

2. **SPECVAULT_COMPLIANCE** - Compliance reporting
   - Traceability matrix generation
   - Gap analysis
   - Compliance status report

3. **Search functionality**
   - Full-text search in documents
   - Filter by type/status
   - Search metadata

4. **Diff command**
   - Compare versions
   - Show changes inline
   - Export diff

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T3.1 | Implement audit logging | All actions logged |
| T3.2 | Implement audit command | Shows audit history |
| T3.3 | Add CSV export | Valid CSV files |
| T3.4 | Create traceability matrix | Cross-reference report |
| T3.5 | Implement search command | Finds documents |
| T3.6 | Implement diff command | Shows version changes |
| T3.7 | Add compliance report | Status summary |
| T3.8 | Write README documentation | Complete usage guide |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Audit logging | Add document | Event in audit log |
| Audit query | `specvault audit --from 2026-01-01` | Filtered events |
| Traceability matrix | `specvault export --format csv --matrix` | Valid CSV |
| Search | `specvault search "requirement"` | Matching documents |
| Diff versions | `specvault diff SRS-001 --v1 1 --v2 2` | Change list |

---

## ECF Target Structure

```xml
<!-- Library target (reusable) -->
<target name="specvault">
    <root class="SPECVAULT_CLI" feature="make"/>
    <library name="simple_markdown" location="..."/>
    <library name="simple_json" location="..."/>
    <library name="simple_cli" location="..."/>
    <library name="simple_file" location="..."/>
    <library name="simple_sql" location="..."/>
    <library name="simple_hash" location="..."/>
    <library name="simple_uuid" location="..."/>
    <library name="simple_datetime" location="..."/>
    <library name="simple_csv" location="..."/>
    <cluster name="src" location="src/" recursive="true"/>
</target>

<!-- CLI executable target -->
<target name="specvault_cli" extends="specvault">
    <root class="SPECVAULT_CLI" feature="make"/>
</target>

<!-- Test target -->
<target name="specvault_tests" extends="specvault">
    <root class="TEST_APP" feature="make"/>
    <library name="simple_testing" location="..."/>
    <cluster name="tests" location="tests/" recursive="true"/>
</target>
```

---

## Build Commands

```bash
# Compile CLI (development)
ec.exe -batch -config specvault.ecf -target specvault_cli -c_compile

# Compile CLI (production)
ec.exe -batch -config specvault.ecf -target specvault_cli -finalize -c_compile

# Run tests
ec.exe -batch -config specvault.ecf -target specvault_tests -c_compile
./EIFGENs/specvault_tests/W_code/specvault.exe

# Run finalized tests
ec.exe -batch -config specvault.ecf -target specvault_tests -finalize -c_compile
./EIFGENs/specvault_tests/F_code/specvault.exe
```

---

## Success Criteria

| Criterion | Measure | Target |
|-----------|---------|--------|
| Compiles | Zero errors | 100% |
| Tests pass | All test cases | 100% |
| CLI works | All commands functional | 100% |
| Documentation | README complete | Yes |
| Audit completeness | All actions logged | 100% |
| Reference validation | All refs checked | 100% |
| Compliance reports | Matrix generates | Yes |

---

## File Structure

```
specvault/
|-- specvault.ecf
|-- README.md
|-- CHANGELOG.md
|-- src/
|   |-- specvault_cli.e
|   |-- specvault_config.e
|   |-- specvault_document.e
|   |-- specvault_version.e
|   |-- specvault_registry.e
|   |-- specvault_reference.e
|   |-- specvault_audit.e
|   |-- specvault_export.e
|   +-- specvault_compliance.e
|-- tests/
|   |-- test_app.e
|   |-- test_registry.e
|   |-- test_reference.e
|   |-- test_audit.e
|   +-- test_export.e
|-- templates/
|   |-- spec.md
|   |-- req.md
|   |-- design.md
|   |-- test.md
|   +-- export/
|       |-- page.html
|       +-- report.html
+-- examples/
    |-- .specvault.yaml
    +-- docs/
        |-- SRS-001.md
        |-- SRS-002.md
        +-- DES-001.md
```

---

## Compliance Checklist

For FDA 21 CFR Part 11 compliance:

| Requirement | Implementation | Status |
|-------------|----------------|--------|
| Audit trail | SPECVAULT_AUDIT logs all actions | Phase 3 |
| Electronic signatures | Planned for Enterprise tier | Future |
| Access controls | User tracking in audit | Phase 3 |
| Document integrity | SHA-256 hashing | Phase 2 |
| Version control | Full history retained | Phase 1 |
| Backup/recovery | SQLite file-based | Phase 1 |
