# DocForge

**Enterprise Documentation Site Generator**

---

## Executive Summary

DocForge is an enterprise-grade documentation site generator that transforms directories of Markdown files into searchable, navigable HTML documentation sites. Unlike heavyweight platforms that require databases and complex setups, DocForge follows the Unix philosophy: do one thing well.

The tool processes Markdown content through simple_markdown, applies customizable templates, generates navigation structures, and creates full-text search indexes. Output is static HTML that can be deployed anywhere: GitHub Pages, S3, Netlify, or internal servers.

DocForge differentiates itself by being CLI-first (perfect for CI/CD integration), configuration-as-code (version-controlled settings), and built on Eiffel's Design by Contract foundation (predictable, reliable behavior).

---

## Problem Statement

**The problem:** Technical teams need to publish documentation but face a painful choice:
- **Free tools** (MkDocs, Jekyll) require Python/Ruby ecosystems and complex configuration
- **SaaS platforms** (GitBook, Readme) create vendor lock-in and ongoing costs
- **Enterprise tools** (Paligo, MadCap) are expensive and overkill for most needs

**Current solutions:**
- Teams cobble together multiple tools (Pandoc + custom scripts + search services)
- Writers manually format HTML or use WYSIWYG editors with inconsistent output
- Documentation becomes stale because the publishing process is too painful

**Our approach:**
- Single binary, zero dependencies (like Doctave, but in Eiffel)
- Convention over configuration (sensible defaults, override when needed)
- CI/CD native (designed for automation, not GUI workflows)
- Full-text search included (no external services required)

---

## Target Users

| User Type | Description | Key Needs |
|-----------|-------------|-----------|
| **Primary: DevOps Engineer** | Maintains documentation infrastructure | CI/CD integration, automation, reliability |
| **Primary: Technical Writer** | Authors and publishes documentation | Preview, batch processing, templates |
| **Secondary: Developer** | Writes README and API docs | Quick setup, minimal config |
| **Secondary: Release Manager** | Publishes versioned documentation | Version management, deployment |

---

## Value Proposition

**For** DevOps teams and technical writers
**Who** need to publish Markdown documentation as professional HTML sites
**DocForge** is a CLI documentation generator
**That** converts Markdown to searchable HTML with zero configuration
**Unlike** MkDocs (requires Python), GitBook (SaaS dependency), or Paligo (expensive)
**We** provide a single binary with built-in search and enterprise features

---

## Revenue Model

| Model | Description | Price Point |
|-------|-------------|-------------|
| **Community** | Open source CLI, basic features | Free |
| **Professional** | Custom themes, API output, priority support | $49/seat/month |
| **Enterprise** | SSO, audit logs, custom integrations, SLA | $199/seat/month |

### Feature Matrix

| Feature | Community | Professional | Enterprise |
|---------|-----------|--------------|------------|
| Markdown conversion | Yes | Yes | Yes |
| Built-in search | Yes | Yes | Yes |
| Default themes | 3 | 10+ | Custom |
| Configuration | YAML | YAML + API | YAML + API |
| Output formats | HTML | HTML + JSON | HTML + JSON + PDF |
| Support | Community | Email | Dedicated |
| Audit logging | No | No | Yes |
| SSO integration | No | No | Yes |

---

## Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Build speed | >100 pages/second | Benchmark suite |
| Zero-config success | 95% of projects work without config | User telemetry |
| Search accuracy | >90% relevant first result | Query testing |
| CI/CD adoption | 60% of users run in pipelines | User survey |
| Documentation freshness | <24h from commit to publish | Integration metrics |
