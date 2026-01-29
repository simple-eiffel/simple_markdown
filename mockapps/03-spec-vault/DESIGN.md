# SpecVault - Technical Design

---

## Architecture

### Component Overview

```
+---------------------------------------------------------------+
|                         SpecVault                              |
+---------------------------------------------------------------+
|  CLI Interface Layer                                           |
|    - Argument parsing (simple_cli)                             |
|    - Command routing (add, update, audit, export, validate)    |
|    - Output formatting (table, JSON)                           |
+---------------------------------------------------------------+
|  Document Management Layer                                     |
|    - Document registry                                         |
|    - Version controller                                        |
|    - Cross-reference tracker                                   |
|    - Metadata manager                                          |
+---------------------------------------------------------------+
|  Processing Layer                                              |
|    - Markdown parser (simple_markdown)                         |
|    - Reference extractor                                       |
|    - Hash calculator (simple_hash)                             |
+---------------------------------------------------------------+
|  Storage Layer                                                 |
|    - SQLite database (simple_sql)                              |
|    - File system (simple_file)                                 |
|    - JSON export (simple_json)                                 |
+---------------------------------------------------------------+
|  Reporting Layer                                               |
|    - Audit trail generator                                     |
|    - Compliance report generator                               |
|    - Traceability matrix generator                             |
+---------------------------------------------------------------+
```

### Class Design

| Class | Responsibility | Key Features |
|-------|----------------|--------------|
| `SPECVAULT_CLI` | Command-line interface | `parse_args`, `execute`, `format_output` |
| `SPECVAULT_CONFIG` | Configuration management | `load`, `validate`, `project_settings` |
| `SPECVAULT_DOCUMENT` | Document representation | `id`, `title`, `version`, `content`, `metadata` |
| `SPECVAULT_VERSION` | Version tracking | `create_revision`, `compare`, `history` |
| `SPECVAULT_REGISTRY` | Document database | `add`, `update`, `find`, `list` |
| `SPECVAULT_REFERENCE` | Cross-reference tracking | `extract`, `validate`, `report_broken` |
| `SPECVAULT_AUDIT` | Audit trail management | `log_event`, `generate_report`, `export` |
| `SPECVAULT_EXPORT` | Output generation | `to_html`, `to_json`, `to_pdf` |
| `SPECVAULT_COMPLIANCE` | Compliance reporting | `generate_matrix`, `gap_analysis` |

### Command Structure

```bash
specvault <command> [options] [arguments]

Commands:
  init          Initialize SpecVault project
  add           Add document to vault
  update        Update existing document
  status        Show document status
  history       Show document version history
  diff          Compare document versions
  audit         Generate audit report
  export        Export document(s) to format
  validate      Validate cross-references
  search        Search documents

Global Options:
  --config FILE     Configuration file (default: .specvault.yaml)
  --vault PATH      Vault directory (default: current)
  --verbose         Verbose output
  --json            JSON output format
  --help            Show help

Add/Update Options:
  --title TEXT      Document title
  --type TYPE       Document type (spec|req|design|test)
  --author TEXT     Author name
  --comment TEXT    Change comment (required for update)

Audit Options:
  --from DATE       Start date (YYYY-MM-DD)
  --to DATE         End date (YYYY-MM-DD)
  --user TEXT       Filter by user
  --action TYPE     Filter by action type

Export Options:
  --format FMT      Output format: html|json|pdf|csv
  --output FILE     Output file/directory
  --template FILE   Custom template
  --include-history Include version history

Examples:
  specvault init myproject
  specvault add docs/SRS-001.md --type spec --title "Software Requirements"
  specvault update docs/SRS-001.md --comment "Added section 3.2"
  specvault audit --from 2026-01-01 --to 2026-01-31
  specvault export --format html --output site/
  specvault validate --fix
```

### Data Flow

```
Document Input           Processing              Storage              Output
--------------           ----------              -------              ------

docs/
  |
  +-- SRS-001.md  --->  SPECVAULT_DOCUMENT  --->  SQLite DB  --->  SPECVAULT_EXPORT
  |                          |                       |                   |
  +-- SRS-002.md             |                       |                   +-- HTML
  |                          v                       v                   +-- JSON
  +-- DES-001.md       simple_markdown          documents               +-- PDF
                             |                   versions                +-- CSV
                             v                   references
                      SPECVAULT_REFERENCE       audit_log
                             |                       |
                             v                       v
                      Cross-reference           SPECVAULT_AUDIT
                      validation                     |
                             |                       v
                             v                  Audit Report
                      Broken link report        Compliance Matrix
```

### Database Schema

```sql
-- Documents table
CREATE TABLE documents (
    id TEXT PRIMARY KEY,           -- UUID
    document_id TEXT UNIQUE,       -- User-friendly ID (SRS-001)
    title TEXT NOT NULL,
    doc_type TEXT NOT NULL,        -- spec, req, design, test
    file_path TEXT NOT NULL,
    current_version INTEGER,
    status TEXT DEFAULT 'draft',   -- draft, review, approved, obsolete
    created_at TEXT,
    created_by TEXT,
    updated_at TEXT,
    updated_by TEXT
);

-- Versions table
CREATE TABLE versions (
    id TEXT PRIMARY KEY,
    document_id TEXT NOT NULL,
    version INTEGER NOT NULL,
    content_hash TEXT NOT NULL,    -- SHA-256 of content
    change_comment TEXT,
    changed_by TEXT,
    changed_at TEXT,
    FOREIGN KEY (document_id) REFERENCES documents(id),
    UNIQUE (document_id, version)
);

-- Cross-references table
CREATE TABLE references (
    id TEXT PRIMARY KEY,
    source_doc TEXT NOT NULL,
    target_doc TEXT NOT NULL,
    reference_type TEXT,           -- cites, implements, verifies
    line_number INTEGER,
    valid BOOLEAN DEFAULT 1,
    FOREIGN KEY (source_doc) REFERENCES documents(id),
    FOREIGN KEY (target_doc) REFERENCES documents(id)
);

-- Audit log table
CREATE TABLE audit_log (
    id TEXT PRIMARY KEY,
    timestamp TEXT NOT NULL,
    user_name TEXT NOT NULL,
    action TEXT NOT NULL,          -- add, update, delete, export, approve
    document_id TEXT,
    version INTEGER,
    details TEXT,                  -- JSON details
    FOREIGN KEY (document_id) REFERENCES documents(id)
);

-- Custom metadata table
CREATE TABLE metadata (
    id TEXT PRIMARY KEY,
    document_id TEXT NOT NULL,
    key TEXT NOT NULL,
    value TEXT,
    FOREIGN KEY (document_id) REFERENCES documents(id),
    UNIQUE (document_id, key)
);
```

### Configuration Schema

```yaml
# .specvault.yaml
project:
  name: "My Product"
  id_prefix: "PRJ"
  organization: "Company Name"

vault:
  path: ".specvault"              # Database and cache location
  documents: "docs"               # Source documents directory

documents:
  types:
    spec:
      name: "Specification"
      prefix: "SRS"
      template: "templates/spec.md"
    req:
      name: "Requirement"
      prefix: "REQ"
      template: "templates/req.md"
    design:
      name: "Design Document"
      prefix: "DES"
      template: "templates/design.md"
    test:
      name: "Test Specification"
      prefix: "TST"
      template: "templates/test.md"

references:
  patterns:
    - "\\[([A-Z]{3}-\\d{3})\\]"    # [SRS-001]
    - "see\\s+([A-Z]{3}-\\d{3})"   # see SRS-001
  validate_on_save: true

audit:
  enabled: true
  retention_days: 365
  log_exports: true
  log_reads: false

compliance:
  standard: "ISO-13485"           # ISO-13485, FDA-21CFR11, DO-178C
  electronic_signatures: false
  approval_workflow: true

export:
  html:
    theme: "professional"
    include_toc: true
  pdf:
    page_size: "letter"
    margins: "1in"
```

### Error Handling

| Error Type | Handling | User Message |
|------------|----------|--------------|
| Document not found | Fail | "Document 'SRS-001' not found. Use 'specvault list' to see all documents" |
| Invalid document ID | Fail | "Invalid document ID format. Expected: SRS-001, got: srs001" |
| Broken reference | Warn | "Warning: SRS-001 references non-existent document DES-999" |
| Duplicate document | Fail | "Document 'SRS-001' already exists. Use 'update' to modify" |
| No change comment | Fail | "Change comment required. Use --comment to describe changes" |
| Database locked | Retry/fail | "Database is locked. Another process may be using SpecVault" |
| Hash mismatch | Warn | "Warning: File content doesn't match stored hash. Document may have been modified outside SpecVault" |

---

## GUI/TUI Future Path

**CLI foundation enables:**

1. **Shared database** - SQLite works identically whether accessed from CLI, TUI, or GUI.

2. **Same validation** - `SPECVAULT_REFERENCE.validate` works across all interfaces.

3. **Event system** - Audit logging captures actions from any interface.

**What would change for TUI:**
- Add `simple_tui` for terminal interface
- Document tree browser
- Version diff viewer (side-by-side)
- Interactive reference navigator

**What would change for GUI:**
- Document editor with live preview
- Visual relationship graph
- Approval workflow UI
- Dashboard with status indicators

**Shared components between CLI/GUI:**
- `SPECVAULT_REGISTRY` - same document operations
- `SPECVAULT_REFERENCE` - same cross-reference tracking
- `SPECVAULT_AUDIT` - same audit logging
- `SPECVAULT_EXPORT` - same output generation
