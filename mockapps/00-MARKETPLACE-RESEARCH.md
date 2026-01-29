# Marketplace Research: simple_markdown

**Generated:** 2026-01-24
**Library:** simple_markdown
**Skill:** /eiffel.mockapp

---

## Library Profile

### Core Capabilities

| Capability | Description | Business Value |
|------------|-------------|----------------|
| Markdown-to-HTML Conversion | Full CommonMark + GFM parsing | Transform content for web publishing |
| Table of Contents Generation | Auto-extract headings with IDs | Navigation for long documents |
| GFM Table Support | Parse/render markdown tables | Technical documentation tables |
| Task List Support | Checkbox items (- [ ] / - [x]) | Project tracking, checklists |
| Code Block Highlighting | Language-tagged fenced blocks | Developer documentation |
| Footnote Support | [^id] references | Academic/technical citations |
| Extended Syntax | Highlight, sub/superscript | Rich formatting options |
| File Processing | Direct file-to-HTML conversion | Batch document processing |
| Fragment Processing | Inline-only conversion | Embed in larger systems |

### API Surface

| Feature | Type | Use Case |
|---------|------|----------|
| `to_html (STRING): STRING` | Query | Primary conversion |
| `to_html_from_file (STRING): STRING` | Query | File-based workflows |
| `to_html_fragment (STRING): STRING` | Query | Inline processing |
| `table_of_contents: STRING` | Query | Navigation generation |
| `headings: ARRAYED_LIST [TUPLE]` | Query | Document structure extraction |
| `is_heading/is_blockquote/is_code_fence/...` | Query | Line-type detection |

### Existing Dependencies

| simple_* Library | Purpose in this library |
|------------------|------------------------|
| None | Pure EiffelBase implementation |

### Integration Points

- **Input formats:** Markdown strings, .md files
- **Output formats:** HTML strings
- **Data flow:** Text -> Parse -> Transform -> HTML

---

## Marketplace Analysis

### Industry Applications

| Industry | Application | Pain Point Solved |
|----------|-------------|-------------------|
| Software Development | API documentation | Manual HTML authoring is slow and error-prone |
| DevOps | Release notes & changelogs | Inconsistent formatting across releases |
| Technical Writing | User manuals, guides | Version control of documentation |
| Legal/Compliance | Contract templates | Structured document generation |
| SaaS/Product | Knowledge bases | Self-service customer support |
| Enterprise | Internal wikis | Knowledge sharing and onboarding |

### Commercial Products (Competitors/Inspirations)

| Product | Price Point | Key Features | Gap We Could Fill |
|---------|-------------|--------------|-------------------|
| MkDocs | Free (OSS) | Static site generation, theming | CLI-first, Eiffel ecosystem |
| Doctave | Free (OSS) | Single-binary, zero-config | Design by Contract quality |
| Docusaurus | Free (OSS) | React-based, MDX support | Simpler, no JavaScript required |
| Document360 | $182+/mo | Knowledge base, analytics | Self-hosted, no SaaS dependency |
| Read the Docs | Free-$150/mo | Hosting, versioning | Local-first, enterprise control |
| GitBook | $8+/user/mo | Collaboration, Git sync | CLI automation, batch processing |
| Mintlify | $600+/mo | AI-powered docs | Affordable, deterministic |
| Paligo | $490+/mo | CCMS, structured content | Lightweight alternative |

### Workflow Integration Points

| Workflow | Where This Library Fits | Value Added |
|----------|-------------------------|-------------|
| CI/CD Pipeline | Generate docs on commit | Automated documentation freshness |
| Release Process | Create changelog/notes | Consistent release communication |
| API Development | OpenAPI -> Markdown -> HTML | Unified doc format |
| Onboarding | Process README files | Standardized welcome pages |
| Compliance | Generate audit docs | Traceable documentation |
| Support Ticket | Convert KB articles | Searchable HTML support content |

### Target User Personas

| Persona | Role | Need | Willingness to Pay |
|---------|------|------|-------------------|
| DevOps Engineer | Build automation | Integrate docs into CI/CD | HIGH |
| Technical Writer | Documentation specialist | Convert Markdown to publishable HTML | HIGH |
| Software Developer | Code author | Maintain README/API docs | MEDIUM |
| Release Manager | Release coordination | Automated changelog generation | HIGH |
| Knowledge Manager | Internal docs owner | Build searchable knowledge bases | HIGH |
| Compliance Officer | Regulatory compliance | Generate audit-ready documents | HIGH |

---

## Mock App Candidates

### Candidate 1: DocForge

**One-liner:** Enterprise documentation site generator with multi-format output and full-text search indexing.

**Target market:** DevOps teams, technical writing departments, software companies needing documentation infrastructure.

**Revenue model:**
- Open core (CLI free, enterprise features paid)
- Professional: $49/seat/month (custom themes, API)
- Enterprise: $199/seat/month (SSO, audit logs, priority support)

**Ecosystem leverage:**
- simple_markdown (core conversion)
- simple_json (configuration, search index)
- simple_file (directory traversal, output)
- simple_template (HTML templating)
- simple_yaml (configuration files)
- simple_hash (content fingerprinting)

**CLI-first value:**
- Scriptable in CI/CD pipelines
- Batch processing of large doc sets
- Version-controlled configuration

**GUI/TUI potential:**
- TUI: Interactive doc preview and navigation
- GUI: Visual theme editor, drag-drop organization

**Viability:** HIGH - Fills gap between free tools and expensive SaaS

---

### Candidate 2: ReleaseScribe

**One-liner:** Automated changelog and release notes generator from Git history with customizable templates.

**Target market:** Software teams, release managers, DevOps engineers who need consistent release communication.

**Revenue model:**
- Freemium (5 repos free, unlimited $19/mo)
- Team: $99/mo (10 repos, custom templates)
- Enterprise: $299/mo (unlimited, API, integrations)

**Ecosystem leverage:**
- simple_markdown (output formatting)
- simple_json (config, API output)
- simple_cli (argument parsing)
- simple_template (release note templates)
- simple_datetime (version dating)
- simple_file (file I/O)

**CLI-first value:**
- Git hook integration
- CI/CD automation
- Conventional commits parsing

**GUI/TUI potential:**
- TUI: Interactive release note editor
- GUI: Visual changelog timeline, drag-drop reordering

**Viability:** HIGH - Addresses pain point of manual changelog maintenance

---

### Candidate 3: SpecVault

**One-liner:** Technical specification document manager with version control, cross-referencing, and compliance tracking.

**Target market:** Regulated industries (medical devices, aerospace, automotive), enterprise software teams, legal/compliance departments.

**Revenue model:**
- Starter: $79/mo (5 users, basic compliance)
- Professional: $199/mo (25 users, full audit trail)
- Enterprise: $499/mo (unlimited, SSO, custom workflows)

**Ecosystem leverage:**
- simple_markdown (document conversion)
- simple_json (metadata, API)
- simple_file (document storage)
- simple_hash (content verification)
- simple_datetime (timestamps, versioning)
- simple_uuid (document identifiers)
- simple_csv (export, reporting)

**CLI-first value:**
- Batch document processing
- CI/CD compliance checks
- Scripted audits

**GUI/TUI potential:**
- TUI: Document navigator, diff viewer
- GUI: Visual spec editor, dependency graphs

**Viability:** HIGH - Premium pricing justified by compliance needs

---

## Selection Rationale

These three candidates were selected because they:

1. **Solve distinct problems** - Documentation generation, release management, and compliance tracking are separate markets with different buyers.

2. **Scale in complexity** - DocForge is feature-rich, ReleaseScribe is focused, SpecVault is specialized.

3. **Leverage ecosystem differently** - Each uses a different combination of simple_* libraries, demonstrating ecosystem breadth.

4. **Have clear revenue models** - All three have established pricing patterns in their markets.

5. **Support CLI-first design** - Each naturally fits the CLI workflow while having clear GUI/TUI upgrade paths.

### Alternatives Considered

- **Blog Engine** - Too crowded, low differentiation
- **Email Newsletter Tool** - Requires SMTP complexity beyond scope
- **Wiki System** - Needs database, authentication complexity
- **PDF Generator** - Requires additional rendering libraries

---

## Web Research Sources

### Documentation Tools
- [MkDocs](https://www.mkdocs.org/) - Static site generator reference
- [Doctave](https://cli.doctave.com/) - Single-binary CLI inspiration
- [Docusaurus](https://docusaurus.io/) - React-based docs platform
- [Document360](https://document360.com/blog/api-documentation-tools/) - Enterprise KB analysis

### Static Site Generators
- [Kinsta SSG Guide](https://kinsta.com/blog/static-site-generator/) - Market overview
- [Jamstack Generators](https://jamstack.org/generators/) - Comprehensive listing
- [Jekyll](https://jekyllrb.com/) - Blog-aware static sites

### Release Notes & Changelog
- [Keep a Changelog](https://changelog.seapagan.net/) - Markdown changelog format
- [GitGroomer](https://www.gitgroomer.com/changelog-generator/) - Conventional commits parsing
- [Towncrier](https://towncrier.readthedocs.io/en/stable/markdown.html) - Fragment-based changelogs

### Enterprise Documentation
- [Treblle API Docs](https://treblle.com/blog/best-openapi-documentation-tools) - API documentation tools
- [ClickHelp](https://clickhelp.com/clickhelp-technical-writing-blog/15-best-technical-writing-software-and-tools/) - Technical writing tools
- [Nuclino](https://www.nuclino.com/solutions/documentation-tools) - Documentation software

### Knowledge Base Software
- [Softr KB Guide](https://www.softr.io/blog/best-knowledge-base-software) - KB software comparison
- [Outline](https://github.com/outline/outline) - Open-source KB
- [Raneto](https://raneto.com/) - Markdown-powered knowledgebase
