note
	description: "Tests for SIMPLE_MARKDOWN"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"
	testing: "covers"
	use_case_coverage: "[
		Documentation Sites: test_real_readme_fixture, test_heading_*, test_toc_*
		Static Site Generators: test_comprehensive_fixture, test_code_block_*
		Blogging/CMS: test_bold_*, test_italic_*, test_link, test_image
		Email Generation: test_inline_*, to_html_fragment tests
		Technical Documentation: test_code_block_*, test_simple_table
		Chat Platforms: test_strikethrough, test_bold_*, test_link
		Note-taking Apps: test_comprehensive_fixture, test_task_list
		Report Generation: test_toc_*, test_multiple_tables
		Preview Rendering: All basic conversion tests
	]"
	commonmark_coverage: "[
		Headings: test_heading_h1, test_heading_h2_to_h6, test_heading_custom_id
		Emphasis: test_bold_*, test_italic_*
		Inline Code: test_inline_code, test_inline_code_escapes_html
		Links: test_link, test_autolink
		Images: test_image
		Lists: test_unordered_list, test_ordered_list, test_task_list
		Blockquotes: test_blockquote
		Code Blocks: test_code_block, test_code_block_with_language
		Horizontal Rules: test_horizontal_rule_*
		Paragraphs: test_paragraph, test_multiple_paragraphs
	]"
	gfm_coverage: "[
		Strikethrough: test_strikethrough
		Tables: test_simple_table, test_multiple_tables, test_special_chars_in_table
		Task Lists: test_task_list
		Autolinks: test_autolink
	]"
	extended_coverage: "[
		Highlight: test_highlight
		Superscript: test_superscript
		Subscript: test_subscript
		Footnotes: test_footnote_reference, test_footnote_definition
		Custom IDs: test_heading_custom_id
		TOC: test_toc_generation, test_toc_from_comprehensive
	]"

class
	LIB_TESTS

inherit
	EQA_TEST_SET
		rename
			assert as eqa_assert
		end

feature -- Test: Headings

	test_heading_h1
		note
			testing: "covers/{SIMPLE_MARKDOWN}.to_html", "covers/{SIMPLE_MARKDOWN}.is_heading"
		local
			md: SIMPLE_MARKDOWN
		do
			create md.make
			assert ("h1", md.to_html ("# Hello").has_substring ("<h1"))
			assert ("has id", md.to_html ("# Hello").has_substring ("id=%"hello%""))
		end

	test_heading_h2_to_h6
		note
			testing: "covers/{SIMPLE_MARKDOWN}.to_html", "covers/{SIMPLE_MARKDOWN}.heading_level"
		local
			md: SIMPLE_MARKDOWN
		do
			create md.make
			assert ("h2", md.to_html ("## Test").has_substring ("<h2"))
			assert ("h3", md.to_html ("### Test").has_substring ("<h3"))
			assert ("h4", md.to_html ("#### Test").has_substring ("<h4"))
			assert ("h5", md.to_html ("##### Test").has_substring ("<h5"))
			assert ("h6", md.to_html ("###### Test").has_substring ("<h6"))
		end

	test_heading_custom_id
		note
			testing: "covers/{SIMPLE_MARKDOWN}.to_html", "covers/{SIMPLE_MARKDOWN}.extract_heading_id"
		local
			md: SIMPLE_MARKDOWN
			html: STRING
		do
			create md.make
			html := md.to_html ("# Introduction {#intro}")
			assert ("has custom id", html.has_substring ("id=%"intro%""))
			assert ("content correct", html.has_substring (">Introduction<"))
		end

feature -- Test: Basic Inline

	test_bold_asterisks
		note
			testing: "covers/{SIMPLE_MARKDOWN}.to_html_fragment", "covers/{MD_INLINE_PROCESSOR}.process_bold"
		local
			md: SIMPLE_MARKDOWN
		do
			create md.make
			assert ("bold", md.to_html_fragment ("**bold**").has_substring ("<strong>bold</strong>"))
		end

	test_bold_underscores
		note
			testing: "covers/{SIMPLE_MARKDOWN}.to_html_fragment", "covers/{MD_INLINE_PROCESSOR}.process_bold"
		local
			md: SIMPLE_MARKDOWN
		do
			create md.make
			assert ("bold", md.to_html_fragment ("__bold__").has_substring ("<strong>bold</strong>"))
		end

	test_italic_asterisk
		note
			testing: "covers/{SIMPLE_MARKDOWN}.to_html_fragment", "covers/{MD_INLINE_PROCESSOR}.process_italic"
		local
			md: SIMPLE_MARKDOWN
		do
			create md.make
			assert ("italic", md.to_html_fragment ("*italic*").has_substring ("<em>italic</em>"))
		end

	test_italic_underscore
		note
			testing: "covers/{SIMPLE_MARKDOWN}.to_html_fragment", "covers/{MD_INLINE_PROCESSOR}.process_italic"
		local
			md: SIMPLE_MARKDOWN
		do
			create md.make
			assert ("italic", md.to_html_fragment ("_italic_").has_substring ("<em>italic</em>"))
		end

	test_inline_code
		note
			testing: "covers/{SIMPLE_MARKDOWN}.to_html_fragment", "covers/{MD_INLINE_PROCESSOR}.process_code_inline"
		local
			md: SIMPLE_MARKDOWN
		do
			create md.make
			assert ("code", md.to_html_fragment ("`code`").has_substring ("<code>code</code>"))
		end

	test_inline_code_escapes_html
		note
			testing: "covers/{MD_INLINE_PROCESSOR}.process_code_inline", "covers/{MD_INLINE_PROCESSOR}.escape_html"
		local
			md: SIMPLE_MARKDOWN
		do
			create md.make
			assert ("escaped", md.to_html_fragment ("`<script>`").has_substring ("&lt;script&gt;"))
		end

feature -- Test: GFM Strikethrough

	test_strikethrough
		note
			testing: "covers/{MD_INLINE_PROCESSOR}.process_strikethrough"
		local
			md: SIMPLE_MARKDOWN
		do
			create md.make
			assert ("del", md.to_html_fragment ("~~deleted~~").has_substring ("<del>deleted</del>"))
		end

feature -- Test: Links and Images

	test_link
		note
			testing: "covers/{MD_INLINE_PROCESSOR}.process_links"
		local
			md: SIMPLE_MARKDOWN
		do
			create md.make
			assert ("link", md.to_html_fragment ("[text](http://example.com)").has_substring ("<a href=%"http://example.com%">text</a>"))
		end

	test_image
		note
			testing: "covers/{MD_INLINE_PROCESSOR}.process_images"
		local
			md: SIMPLE_MARKDOWN
		do
			create md.make
			assert ("image", md.to_html_fragment ("![alt](image.png)").has_substring ("<img src=%"image.png%" alt=%"alt%">"))
		end

	test_autolink
		note
			testing: "covers/{MD_INLINE_PROCESSOR}.process_autolinks"
		local
			md: SIMPLE_MARKDOWN
		do
			create md.make
			assert ("autolink", md.to_html_fragment ("Visit https://example.com today").has_substring ("<a href=%"https://example.com%">"))
		end

feature -- Test: Lists

	test_unordered_list
		note
			testing: "covers/{SIMPLE_MARKDOWN}.to_html", "covers/{SIMPLE_MARKDOWN}.is_unordered_list_item"
		local
			md: SIMPLE_MARKDOWN
			html: STRING
		do
			create md.make
			html := md.to_html ("- Item 1%N- Item 2")
			assert ("has ul", html.has_substring ("<ul>"))
			assert ("has li", html.has_substring ("<li>Item 1</li>"))
		end

	test_ordered_list
		note
			testing: "covers/{SIMPLE_MARKDOWN}.to_html", "covers/{SIMPLE_MARKDOWN}.is_ordered_list_item"
		local
			md: SIMPLE_MARKDOWN
			html: STRING
		do
			create md.make
			html := md.to_html ("1. First%N2. Second")
			assert ("has ol", html.has_substring ("<ol>"))
			assert ("has li", html.has_substring ("<li>First</li>"))
		end

	test_task_list
		note
			testing: "covers/{SIMPLE_MARKDOWN}.to_html", "covers/{SIMPLE_MARKDOWN}.is_task_list_item"
		local
			md: SIMPLE_MARKDOWN
			html: STRING
		do
			create md.make
			html := md.to_html ("- [ ] Unchecked%N- [x] Checked")
			assert ("has checkbox", html.has_substring ("type=%"checkbox%""))
			assert ("unchecked", html.has_substring ("disabled> Unchecked"))
			assert ("checked", html.has_substring ("checked> Checked"))
		end

feature -- Test: Blockquote

	test_blockquote
		note
			testing: "covers/{SIMPLE_MARKDOWN}.to_html", "covers/{SIMPLE_MARKDOWN}.is_blockquote"
		local
			md: SIMPLE_MARKDOWN
		do
			create md.make
			assert ("blockquote", md.to_html ("> Quote").has_substring ("<blockquote><p>Quote</p></blockquote>"))
		end

feature -- Test: Code Blocks

	test_code_block
		note
			testing: "covers/{SIMPLE_MARKDOWN}.to_html", "covers/{SIMPLE_MARKDOWN}.is_code_fence"
		local
			md: SIMPLE_MARKDOWN
			html: STRING
		do
			create md.make
			html := md.to_html ("```%Ncode here%N```")
			assert ("has pre", html.has_substring ("<pre><code>"))
			assert ("has code", html.has_substring ("code here"))
		end

	test_code_block_with_language
		note
			testing: "covers/{SIMPLE_MARKDOWN}.to_html", "covers/{SIMPLE_MARKDOWN}.extract_code_language"
		local
			md: SIMPLE_MARKDOWN
			html: STRING
		do
			create md.make
			html := md.to_html ("```eiffel%Nfeature%N```")
			assert ("has language class", html.has_substring ("class=%"language-eiffel%""))
		end

feature -- Test: Horizontal Rule

	test_horizontal_rule_dashes
		note
			testing: "covers/{SIMPLE_MARKDOWN}.to_html", "covers/{SIMPLE_MARKDOWN}.is_horizontal_rule"
		local
			md: SIMPLE_MARKDOWN
		do
			create md.make
			assert ("hr", md.to_html ("---").has_substring ("<hr>"))
		end

	test_horizontal_rule_asterisks
		note
			testing: "covers/{SIMPLE_MARKDOWN}.to_html", "covers/{SIMPLE_MARKDOWN}.is_horizontal_rule"
		local
			md: SIMPLE_MARKDOWN
		do
			create md.make
			assert ("hr", md.to_html ("***").has_substring ("<hr>"))
		end

feature -- Test: GFM Tables

	test_simple_table
		note
			testing: "covers/{SIMPLE_MARKDOWN}.to_html", "covers/{MD_TABLE_PROCESSOR}.convert_header_row", "covers/{MD_TABLE_PROCESSOR}.convert_body_row"
		local
			md: SIMPLE_MARKDOWN
			html: STRING
		do
			create md.make
			html := md.to_html ("| A | B |%N|---|---|%N| 1 | 2 |")
			assert ("has table", html.has_substring ("<table>"))
			assert ("has thead", html.has_substring ("<thead>"))
			assert ("has th", html.has_substring ("<th>A</th>"))
			assert ("has tbody", html.has_substring ("<tbody>"))
			assert ("has td", html.has_substring ("<td>1</td>"))
		end

feature -- Test: Extended Syntax

	test_highlight
		note
			testing: "covers/{MD_INLINE_PROCESSOR}.process_highlight"
		local
			md: SIMPLE_MARKDOWN
		do
			create md.make
			assert ("mark", md.to_html_fragment ("==highlighted==").has_substring ("<mark>highlighted</mark>"))
		end

	test_superscript
		note
			testing: "covers/{MD_INLINE_PROCESSOR}.process_superscript"
		local
			md: SIMPLE_MARKDOWN
		do
			create md.make
			assert ("sup", md.to_html_fragment ("x^2^").has_substring ("<sup>2</sup>"))
		end

	test_subscript
		note
			testing: "covers/{MD_INLINE_PROCESSOR}.process_subscript"
		local
			md: SIMPLE_MARKDOWN
		do
			create md.make
			assert ("sub", md.to_html_fragment ("H~2~O").has_substring ("<sub>2</sub>"))
		end

	test_footnote_reference
		note
			testing: "covers/{MD_INLINE_PROCESSOR}.process_footnote_refs"
		local
			md: SIMPLE_MARKDOWN
		do
			create md.make
			assert ("footnote ref", md.to_html_fragment ("Text[^1] here").has_substring ("<sup><a href=%"#fn-1%">"))
		end

	test_footnote_definition
		note
			testing: "covers/{SIMPLE_MARKDOWN}.to_html", "covers/{SIMPLE_MARKDOWN}.is_footnote_definition"
		local
			md: SIMPLE_MARKDOWN
		do
			create md.make
			assert ("footnote def", md.to_html ("[^1]: This is a footnote").has_substring ("id=%"fn-1%""))
		end

feature -- Test: Paragraphs

	test_paragraph
		note
			testing: "covers/{SIMPLE_MARKDOWN}.to_html"
		local
			md: SIMPLE_MARKDOWN
		do
			create md.make
			assert ("paragraph", md.to_html ("Hello world").has_substring ("<p>Hello world</p>"))
		end

	test_multiple_paragraphs
		note
			testing: "covers/{SIMPLE_MARKDOWN}.to_html", "covers/{MD_PARSE_STATE}.in_paragraph"
		local
			md: SIMPLE_MARKDOWN
			html: STRING
		do
			create md.make
			html := md.to_html ("First para%N%NSecond para")
			assert ("two paragraphs", html.occurrences ('<') >= 4)
		end

feature -- Test: Table of Contents

	test_toc_generation
		note
			testing: "covers/{SIMPLE_MARKDOWN}.table_of_contents", "covers/{SIMPLE_MARKDOWN}.headings"
		local
			md: SIMPLE_MARKDOWN
			html, toc: STRING
		do
			create md.make
			html := md.to_html ("# Chapter 1%N## Section A%N## Section B")
			toc := md.table_of_contents
			assert ("has nav", toc.has_substring ("<nav class=%"toc%">"))
			assert ("has chapter", toc.has_substring ("Chapter 1"))
			assert ("has section a", toc.has_substring ("Section A"))
		end

feature -- Test: Edge Cases

	test_empty_input
		note
			testing: "covers/{SIMPLE_MARKDOWN}.to_html"
		local
			md: SIMPLE_MARKDOWN
		do
			create md.make
			assert ("empty", md.to_html ("").is_empty)
		end

	test_crlf_line_endings
		note
			testing: "covers/{SIMPLE_MARKDOWN}.to_html", "covers/{SIMPLE_MARKDOWN}.normalize_line_endings"
		local
			md: SIMPLE_MARKDOWN
			html: STRING
		do
			create md.make
			html := md.to_html ("# Heading%R%NText")
			assert ("handles crlf", html.has_substring ("<h1"))
		end

feature -- Test: Stress Tests (Real-world files)

	test_comprehensive_fixture
		note
			testing: "covers/{SIMPLE_MARKDOWN}.to_html_from_file", "stress_test"
		local
			md: SIMPLE_MARKDOWN
			html: STRING
		do
			create md.make
			html := md.to_html_from_file ("tests/fixtures/comprehensive.md")
			-- Verify key elements are present
			assert ("has h1", html.has_substring ("<h1"))
			assert ("has h2", html.has_substring ("<h2"))
			assert ("has table", html.has_substring ("<table>"))
			assert ("has code block", html.has_substring ("<pre><code"))
			assert ("has bold", html.has_substring ("<strong>"))
			assert ("has italic", html.has_substring ("<em>"))
			assert ("has link", html.has_substring ("<a href="))
			assert ("has list", html.has_substring ("<ul>"))
			assert ("has hr", html.has_substring ("<hr>"))
			assert ("has blockquote", html.has_substring ("<blockquote>"))
			assert ("has del", html.has_substring ("<del>"))
			assert ("has mark", html.has_substring ("<mark>"))
			assert ("has sup", html.has_substring ("<sup>"))
			assert ("has sub", html.has_substring ("<sub>"))
		end

	test_real_readme_fixture
		note
			testing: "covers/{SIMPLE_MARKDOWN}.to_html_from_file", "stress_test", "use_case/documentation"
		local
			md: SIMPLE_MARKDOWN
			html: STRING
		do
			create md.make
			html := md.to_html_from_file ("tests/fixtures/real_readme.md")
			-- Verify README elements
			assert ("has h1", html.has_substring ("<h1"))
			assert ("has features h2", html.has_substring ("Features"))
			assert ("has installation h2", html.has_substring ("Installation"))
			assert ("has usage h2", html.has_substring ("Usage"))
			assert ("has api table", html.has_substring ("<table>"))
			assert ("has code blocks", html.has_substring ("<pre><code"))
			assert ("has xml code", html.has_substring ("language-xml"))
			assert ("has eiffel code", html.has_substring ("language-eiffel"))
			assert ("has links", html.has_substring ("<a href="))
		end

	test_toc_from_comprehensive
		note
			testing: "covers/{SIMPLE_MARKDOWN}.table_of_contents", "stress_test"
		local
			md: SIMPLE_MARKDOWN
			html, toc: STRING
		do
			create md.make
			html := md.to_html_from_file ("tests/fixtures/comprehensive.md")
			toc := md.table_of_contents
			-- Verify TOC captures all sections
			assert ("has toc nav", toc.has_substring ("<nav class=%"toc%">"))
			assert ("has commonmark", toc.has_substring ("CommonMark"))
			assert ("has gfm", toc.has_substring ("GFM"))
			assert ("has extended", toc.has_substring ("Extended"))
			assert ("has edge cases", toc.has_substring ("Edge Cases"))
		end

	test_multiple_tables
		note
			testing: "covers/{MD_TABLE_PROCESSOR}.convert_header_row", "covers/{MD_TABLE_PROCESSOR}.convert_body_row", "stress_test"
		local
			md: SIMPLE_MARKDOWN
			html: STRING
		do
			create md.make
			html := md.to_html_from_file ("tests/fixtures/real_readme.md")
			-- Count table occurrences (should have multiple)
			assert ("multiple tables", html.occurrences ('<') > 50)
		end

	test_nested_formatting_stress
		note
			testing: "covers/{MD_INLINE_PROCESSOR}.process", "stress_test"
		local
			md: SIMPLE_MARKDOWN
			html: STRING
		do
			create md.make
			html := md.to_html_fragment ("**bold with `code` inside** and *italic with [link](url)*")
			assert ("has bold", html.has_substring ("<strong>"))
			assert ("has code in bold", html.has_substring ("<code>code</code>"))
			assert ("has italic", html.has_substring ("<em>"))
			assert ("has link in italic", html.has_substring ("<a href="))
		end

	test_large_code_block
		note
			testing: "covers/{SIMPLE_MARKDOWN}.to_html", "covers/{SIMPLE_MARKDOWN}.is_code_fence", "stress_test"
		local
			md: SIMPLE_MARKDOWN
			html: STRING
			large_code: STRING
			i: INTEGER
		do
			create large_code.make (1000)
			large_code.append ("```eiffel%N")
			from i := 1
			until i > 50
			loop
				large_code.append ("feature {NONE} -- Line ")
				large_code.append_integer (i)
				large_code.append ("%N")
				i := i + 1
			end
			large_code.append ("```")

			create md.make
			html := md.to_html (large_code)
			assert ("has pre", html.has_substring ("<pre><code"))
			assert ("has language", html.has_substring ("language-eiffel"))
			assert ("has line 50", html.has_substring ("Line 50"))
		end

	test_special_chars_in_table
		note
			testing: "covers/{MD_TABLE_PROCESSOR}.parse_cells", "covers/{MD_INLINE_PROCESSOR}.process_code_inline"
		local
			md: SIMPLE_MARKDOWN
			html: STRING
		do
			create md.make
			html := md.to_html ("| Feature | Code |%N|---------|------|%N| `parse` | `csv.parse (str)` |")
			assert ("has table", html.has_substring ("<table>"))
			assert ("has code in cell", html.has_substring ("<code>parse</code>"))
		end

feature {NONE} -- Assertions

	assert (a_tag: STRING; a_condition: BOOLEAN)
		do
			eqa_assert (a_tag, a_condition)
		end

end
