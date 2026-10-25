# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- Testing config updates, AutoTest fixes, .gitignore cleanup
- Migrate to simple_testing library
- Remove redundant result_not_void postconditions
- Add EiffelStudio AutoTest coverage tags to all tests
- Add test coverage documentation to note clause
- Add stress tests with real-world markdown fixtures
- Initial implementation of simple_markdown library

## [1.1.0] - 2026-10-25

### Added - Markdown to and from a rich document (LG-12, for simple_bible)

simple_bible keeps notes as Markdown and edits them in a live-preview editor
(simple_widgets GW-13). That needs Markdown read into a document model and
written back out, in Unicode, so pointed Hebrew and polytonic Greek survive.

- `MD_DOCUMENT_READER.read (markdown): SIMPLE_DOCUMENT` and `read_inline`, on
  the simple_document model. Blocks: headings (levels 4 to 6 read as 3),
  paragraphs (lines join with a space; a trailing backslash or two spaces
  break the line), bulleted and numbered items nested by indent (a list that
  starts indented takes its depth from the indent, so one item read alone
  keeps its depth), quotes by depth, rules, fenced code blocks kept as typed,
  and pipe tables with inline Markdown in cells. Inline: escapes, code, links,
  autolinks, bold, italic (an underscore inside a word stays a letter), both,
  strikethrough and superscript, nested.
- `MD_DOCUMENT_WRITER.write (document): STRING_32` and `write_block`, which
  the reader reads back into the same document. Italic is written with
  underscores so it never fuses with bold into `***`; text that looks like
  syntax is escaped; spaces at a span's edge move outside its delimiters.
- `SIMPLE_MARKDOWN.to_document` and `from_document`.
- Tests: blocks, hard breaks, inline spans and nesting, escapes, a round trip
  of every block and span kind (read, write, read: the same document; writing
  again: the same text), a Hebrew and Greek round trip, writer escapes, and
  each block's own source reading back as that block. 46 pass.

### Changed

- Depends on simple_document.
- Concurrency is SCOOP only (the ECF said `use="thread"`); the test target now
  repeats the assertion options, so contracts run in the tests.
- The HTML conversion (`to_html`) is unchanged.

## [1.0.0] - 2025-12-08

### Added
- Initial release
- Core functionality implemented
- Test suite with comprehensive coverage
- Documentation and examples

[Unreleased]: https://github.com/simple-eiffel/simple_markdown/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/simple-eiffel/simple_markdown/releases/tag/v1.0.0
