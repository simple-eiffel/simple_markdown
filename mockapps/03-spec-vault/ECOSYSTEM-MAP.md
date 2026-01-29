# SpecVault - Ecosystem Integration

---

## simple_* Dependencies

### Required Libraries

| Library | Purpose | Integration Point |
|---------|---------|-------------------|
| `simple_markdown` | Document parsing and rendering | Content processing, HTML export |
| `simple_json` | Configuration, API output, metadata | Config parsing, JSON export |
| `simple_cli` | Argument parsing, command routing | `SPECVAULT_CLI` interface |
| `simple_file` | File I/O, directory operations | Document reading, export writing |
| `simple_sql` | SQLite database operations | Document registry, audit log |
| `simple_hash` | Content fingerprinting | Version verification, change detection |
| `simple_uuid` | Unique identifiers | Document IDs, version IDs |
| `simple_datetime` | Timestamps | Audit entries, version dates |

### Optional Libraries

| Library | Purpose | When Needed |
|---------|---------|-------------|
| `simple_yaml` | YAML configuration | When using .specvault.yaml |
| `simple_csv` | CSV export | Compliance matrix export |
| `simple_template` | Custom export templates | Custom report templates |
| `simple_diff` | Content comparison | Version diff display |

---

## Integration Patterns

### simple_markdown Integration

**Purpose:** Parse document content, extract structure, generate HTML

**Usage:**
```eiffel
class SPECVAULT_DOCUMENT

feature -- Content Processing

    parse_content
            -- Parse Markdown content and extract structure.
        local
            l_md: SIMPLE_MARKDOWN
        do
            create l_md.make
            html_content := l_md.to_html (markdown_content)
            headings := l_md.headings

            -- Extract document metadata from first heading
            if not headings.is_empty then
                extracted_title := headings.first.text
            end

            -- Generate table of contents for navigation
            toc_html := l_md.table_of_contents
        ensure
            html_generated: html_content /= Void
        end

    extract_references
            -- Extract cross-references from content.
        local
            l_md: SIMPLE_MARKDOWN
            l_pattern: REGULAR_EXPRESSION
            l_matches: LIST [STRING]
        do
            create references.make (10)

            -- Find [DOC-NNN] patterns
            create l_pattern.make ("\[([A-Z]{3}-\d{3})\]")
            across l_pattern.matches (markdown_content) as ic loop
                references.extend (ic.item)
            end
        end

feature -- Access

    markdown_content: STRING
    html_content: STRING
    headings: ARRAYED_LIST [TUPLE [level: INTEGER; text: STRING; id: detachable STRING]]
    toc_html: STRING
    references: ARRAYED_LIST [STRING]

end
```

**Data flow:**
```
docs/SRS-001.md --> SPECVAULT_DOCUMENT.markdown_content
                          |
                          v
                   SIMPLE_MARKDOWN.to_html
                          |
                          +--> html_content (for export)
                          |
                          +--> headings (for TOC, structure)
                          |
                          +--> references (for cross-ref validation)
```

---

### simple_sql Integration

**Purpose:** Document registry, version tracking, audit logging

**Usage:**
```eiffel
class SPECVAULT_REGISTRY

feature -- Document Management

    add_document (a_doc: SPECVAULT_DOCUMENT)
            -- Add new document to registry.
        local
            l_sql: SIMPLE_SQL
            l_uuid: SIMPLE_UUID
        do
            create l_sql.make
            l_sql.open (database_path)

            create l_uuid.make
            a_doc.set_id (l_uuid.generate)

            l_sql.execute ("INSERT INTO documents (id, document_id, title, doc_type, file_path, current_version, status, created_at, created_by) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
                <<a_doc.id, a_doc.document_id, a_doc.title, a_doc.doc_type, a_doc.file_path, 1, "draft", current_timestamp, current_user>>)

            -- Create initial version
            create_version (a_doc, "Initial version")

            -- Log audit event
            log_event ("add", a_doc.id, 1, "Document added")

            l_sql.close
        ensure
            document_added: has_document (a_doc.document_id)
        end

    update_document (a_doc: SPECVAULT_DOCUMENT; a_comment: STRING)
            -- Update existing document with new version.
        require
            exists: has_document (a_doc.document_id)
            comment_provided: not a_comment.is_empty
        local
            l_sql: SIMPLE_SQL
            l_new_version: INTEGER
        do
            create l_sql.make
            l_sql.open (database_path)

            -- Get next version number
            l_new_version := a_doc.current_version + 1

            -- Update document record
            l_sql.execute ("UPDATE documents SET current_version = ?, updated_at = ?, updated_by = ? WHERE id = ?",
                <<l_new_version, current_timestamp, current_user, a_doc.id>>)

            -- Create new version
            create_version (a_doc, a_comment)

            -- Log audit event
            log_event ("update", a_doc.id, l_new_version, a_comment)

            l_sql.close
        end

feature {NONE} -- Implementation

    create_version (a_doc: SPECVAULT_DOCUMENT; a_comment: STRING)
            -- Create version record for document.
        local
            l_sql: SIMPLE_SQL
            l_uuid: SIMPLE_UUID
            l_hash: SIMPLE_HASH
        do
            create l_sql.make
            create l_uuid.make
            create l_hash.make

            l_sql.execute ("INSERT INTO versions (id, document_id, version, content_hash, change_comment, changed_by, changed_at) VALUES (?, ?, ?, ?, ?, ?, ?)",
                <<l_uuid.generate, a_doc.id, a_doc.current_version, l_hash.sha256 (a_doc.markdown_content), a_comment, current_user, current_timestamp>>)
        end

    log_event (a_action: STRING; a_doc_id: STRING; a_version: INTEGER; a_details: STRING)
            -- Log audit event.
        local
            l_sql: SIMPLE_SQL
            l_uuid: SIMPLE_UUID
        do
            create l_sql.make
            create l_uuid.make

            l_sql.execute ("INSERT INTO audit_log (id, timestamp, user_name, action, document_id, version, details) VALUES (?, ?, ?, ?, ?, ?, ?)",
                <<l_uuid.generate, current_timestamp, current_user, a_action, a_doc_id, a_version, a_details>>)
        end

end
```

---

### simple_hash Integration

**Purpose:** Content fingerprinting for version verification

**Usage:**
```eiffel
class SPECVAULT_VERSION

feature -- Verification

    verify_content (a_content: STRING): BOOLEAN
            -- Verify content matches stored hash.
        local
            l_hash: SIMPLE_HASH
        do
            create l_hash.make
            Result := l_hash.sha256 (a_content).same_string (content_hash)
        end

    content_changed (a_old: STRING; a_new: STRING): BOOLEAN
            -- Check if content has changed.
        local
            l_hash: SIMPLE_HASH
        do
            create l_hash.make
            Result := not l_hash.sha256 (a_old).same_string (l_hash.sha256 (a_new))
        end

feature -- Access

    content_hash: STRING
            -- SHA-256 hash of version content.

end
```

---

### simple_uuid Integration

**Purpose:** Generate unique identifiers for documents and versions

**Usage:**
```eiffel
class SPECVAULT_DOCUMENT

feature -- Creation

    make (a_document_id: STRING; a_title: STRING; a_type: STRING)
            -- Create new document with unique internal ID.
        local
            l_uuid: SIMPLE_UUID
        do
            create l_uuid.make
            id := l_uuid.generate
            document_id := a_document_id
            title := a_title
            doc_type := a_type
            current_version := 0
            status := "draft"
        ensure
            id_set: id /= Void
            document_id_set: document_id.same_string (a_document_id)
        end

feature -- Access

    id: STRING
            -- Internal UUID.

    document_id: STRING
            -- User-friendly document ID (SRS-001).

end
```

---

### simple_json Integration

**Purpose:** Configuration, API output, metadata export

**Usage:**
```eiffel
class SPECVAULT_EXPORT

feature -- JSON Export

    export_document_json (a_doc: SPECVAULT_DOCUMENT): STRING
            -- Export document as JSON.
        local
            l_json: SIMPLE_JSON
            l_obj: JSON_OBJECT
            l_versions: JSON_ARRAY
            l_refs: JSON_ARRAY
        do
            create l_json.make

            create l_obj.make_empty
            l_obj.put_string (a_doc.id, "id")
            l_obj.put_string (a_doc.document_id, "document_id")
            l_obj.put_string (a_doc.title, "title")
            l_obj.put_string (a_doc.doc_type, "type")
            l_obj.put_string (a_doc.status, "status")
            l_obj.put_integer (a_doc.current_version, "version")

            -- Add version history
            create l_versions.make_empty
            across a_doc.versions as ic loop
                l_versions.extend (version_to_json (ic.item))
            end
            l_obj.put (l_versions, "versions")

            -- Add references
            create l_refs.make_empty
            across a_doc.references as ic loop
                l_refs.extend_string (ic.item)
            end
            l_obj.put (l_refs, "references")

            -- Add custom metadata
            l_obj.put (metadata_to_json (a_doc), "metadata")

            Result := l_obj.to_string
        end

    export_audit_json (a_from: STRING; a_to: STRING): STRING
            -- Export audit log as JSON.
        local
            l_json: SIMPLE_JSON
            l_array: JSON_ARRAY
        do
            create l_json.make
            create l_array.make_empty

            across audit_entries (a_from, a_to) as ic loop
                l_array.extend (audit_entry_to_json (ic.item))
            end

            Result := l_array.to_string
        end

end
```

---

### simple_csv Integration

**Purpose:** Compliance matrix and report export

**Usage:**
```eiffel
class SPECVAULT_COMPLIANCE

feature -- Matrix Export

    export_traceability_matrix (a_path: STRING)
            -- Export traceability matrix to CSV.
        local
            l_csv: SIMPLE_CSV
            l_writer: CSV_WRITER
        do
            create l_csv.make
            l_writer := l_csv.create_writer (a_path)

            -- Header row
            l_writer.write_row (<<"Source", "Source Title", "Target", "Target Title", "Relationship", "Status">>)

            -- Data rows
            across all_references as ic loop
                l_writer.write_row (<<
                    ic.item.source_doc,
                    document_title (ic.item.source_doc),
                    ic.item.target_doc,
                    document_title (ic.item.target_doc),
                    ic.item.reference_type,
                    validation_status (ic.item)
                >>)
            end

            l_writer.close
        end

    export_audit_csv (a_path: STRING; a_from: STRING; a_to: STRING)
            -- Export audit log to CSV for compliance review.
        local
            l_csv: SIMPLE_CSV
            l_writer: CSV_WRITER
        do
            create l_csv.make
            l_writer := l_csv.create_writer (a_path)

            -- Header row
            l_writer.write_row (<<"Timestamp", "User", "Action", "Document", "Version", "Details">>)

            -- Data rows
            across audit_entries (a_from, a_to) as ic loop
                l_writer.write_row (<<
                    ic.item.timestamp,
                    ic.item.user_name,
                    ic.item.action,
                    ic.item.document_id,
                    ic.item.version.out,
                    ic.item.details
                >>)
            end

            l_writer.close
        end

end
```

---

## Dependency Graph

```
specvault
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
    +-- simple_sql (required)
    |   +-- ISE base
    |
    +-- simple_hash (required)
    |   +-- ISE base
    |
    +-- simple_uuid (required)
    |   +-- ISE base
    |
    +-- simple_datetime (required)
    |   +-- ISE base
    |
    +-- simple_yaml (optional)
    |   +-- ISE base
    |
    +-- simple_csv (optional)
    |   +-- ISE base
    |
    +-- simple_template (optional)
    |   +-- ISE base
    |
    +-- simple_diff (optional)
    |   +-- ISE base
    |
    +-- ISE base (required)
```

---

## ECF Configuration

```xml
<?xml version="1.0" encoding="ISO-8859-1"?>
<system xmlns="http://www.eiffel.com/developers/xml/configuration-1-22-0"
        name="specvault"
        uuid="C3D4E5F6-A7B8-9012-CDEF-345678901234">

    <description>SpecVault - Technical Specification Document Manager</description>

    <!-- Library target (reusable core) -->
    <target name="specvault">
        <root class="SPECVAULT_CLI" feature="make"/>

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
        <library name="simple_sql"
                 location="$SIMPLE_EIFFEL/simple_sql/simple_sql.ecf"/>
        <library name="simple_hash"
                 location="$SIMPLE_EIFFEL/simple_hash/simple_hash.ecf"/>
        <library name="simple_uuid"
                 location="$SIMPLE_EIFFEL/simple_uuid/simple_uuid.ecf"/>
        <library name="simple_datetime"
                 location="$SIMPLE_EIFFEL/simple_datetime/simple_datetime.ecf"/>

        <!-- Optional libraries -->
        <library name="simple_yaml"
                 location="$SIMPLE_EIFFEL/simple_yaml/simple_yaml.ecf"/>
        <library name="simple_csv"
                 location="$SIMPLE_EIFFEL/simple_csv/simple_csv.ecf"/>
        <library name="simple_template"
                 location="$SIMPLE_EIFFEL/simple_template/simple_template.ecf"/>

        <!-- ISE dependencies -->
        <library name="base" location="$ISE_LIBRARY/library/base/base.ecf"/>

        <!-- Source clusters -->
        <cluster name="src" location="src/" recursive="true"/>
    </target>

    <!-- CLI executable target -->
    <target name="specvault_cli" extends="specvault">
        <root class="SPECVAULT_CLI" feature="make"/>
    </target>

    <!-- Test target -->
    <target name="specvault_tests" extends="specvault">
        <root class="TEST_APP" feature="make"/>
        <library name="simple_testing"
                 location="$SIMPLE_EIFFEL/simple_testing/simple_testing.ecf"/>
        <cluster name="tests" location="tests/" recursive="true"/>
    </target>

</system>
```
