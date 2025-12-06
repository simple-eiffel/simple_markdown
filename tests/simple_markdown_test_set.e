note
	description: "Tests for SIMPLE_MARKDOWN"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"
	testing: "type/manual"

class
	SIMPLE_MARKDOWN_TEST_SET

inherit
	EQA_TEST_SET
		rename
			assert as eqa_assert
		end

feature -- Test: Headings

	test_heading_h1
			-- Test H1 heading.
		local
			md: SIMPLE_MARKDOWN
		do
			create md.make
			assert ("h1", md.to_html ("# Hello").has_substring ("<h1"))
			assert ("has id", md.to_html ("# Hello").has_substring ("id=%"hello%""))
		end

	test_heading_h2_to_h6
			-- Test all heading levels.
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
			-- Test heading with custom ID.
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
			-- Test bold with **.
		local
			md: SIMPLE_MARKDOWN
		do
			create md.make
			assert ("bold", md.to_html_fragment ("**bold**").has_substring ("<strong>bold</strong>"))
		end

	test_bold_underscores
			-- Test bold with __.
		local
			md: SIMPLE_MARKDOWN
		do
			create md.make
			assert ("bold", md.to_html_fragment ("__bold__").has_substring ("<strong>bold</strong>"))
		end

	test_italic_asterisk
			-- Test italic with *.
		local
			md: SIMPLE_MARKDOWN
		do
			create md.make
			assert ("italic", md.to_html_fragment ("*italic*").has_substring ("<em>italic</em>"))
		end

	test_italic_underscore
			-- Test italic with _.
		local
			md: SIMPLE_MARKDOWN
		do
			create md.make
			assert ("italic", md.to_html_fragment ("_italic_").has_substring ("<em>italic</em>"))
		end

	test_inline_code
			-- Test inline code.
		local
			md: SIMPLE_MARKDOWN
		do
			create md.make
			assert ("code", md.to_html_fragment ("`code`").has_substring ("<code>code</code>"))
		end

	test_inline_code_escapes_html
			-- Test inline code escapes HTML.
		local
			md: SIMPLE_MARKDOWN
		do
			create md.make
			assert ("escaped", md.to_html_fragment ("`<script>`").has_substring ("&lt;script&gt;"))
		end

feature -- Test: GFM Strikethrough

	test_strikethrough
			-- Test strikethrough with ~~.
		local
			md: SIMPLE_MARKDOWN
		do
			create md.make
			assert ("del", md.to_html_fragment ("~~deleted~~").has_substring ("<del>deleted</del>"))
		end

feature -- Test: Links and Images

	test_link
			-- Test link syntax.
		local
			md: SIMPLE_MARKDOWN
		do
			create md.make
			assert ("link", md.to_html_fragment ("[text](http://example.com)").has_substring ("<a href=%"http://example.com%">text</a>"))
		end

	test_image
			-- Test image syntax.
		local
			md: SIMPLE_MARKDOWN
		do
			create md.make
			assert ("image", md.to_html_fragment ("![alt](image.png)").has_substring ("<img src=%"image.png%" alt=%"alt%">"))
		end

	test_autolink
			-- Test automatic URL linking.
		local
			md: SIMPLE_MARKDOWN
		do
			create md.make
			assert ("autolink", md.to_html_fragment ("Visit https://example.com today").has_substring ("<a href=%"https://example.com%">"))
		end

feature -- Test: Lists

	test_unordered_list
			-- Test unordered list.
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
			-- Test ordered list.
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
			-- Test GFM task list.
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
			-- Test blockquote.
		local
			md: SIMPLE_MARKDOWN
		do
			create md.make
			assert ("blockquote", md.to_html ("> Quote").has_substring ("<blockquote><p>Quote</p></blockquote>"))
		end

feature -- Test: Code Blocks

	test_code_block
			-- Test fenced code block.
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
			-- Test fenced code block with language.
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
			-- Test horizontal rule with dashes.
		local
			md: SIMPLE_MARKDOWN
		do
			create md.make
			assert ("hr", md.to_html ("---").has_substring ("<hr>"))
		end

	test_horizontal_rule_asterisks
			-- Test horizontal rule with asterisks.
		local
			md: SIMPLE_MARKDOWN
		do
			create md.make
			assert ("hr", md.to_html ("***").has_substring ("<hr>"))
		end

feature -- Test: GFM Tables

	test_simple_table
			-- Test GFM table.
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
			-- Test highlight syntax.
		local
			md: SIMPLE_MARKDOWN
		do
			create md.make
			assert ("mark", md.to_html_fragment ("==highlighted==").has_substring ("<mark>highlighted</mark>"))
		end

	test_superscript
			-- Test superscript.
		local
			md: SIMPLE_MARKDOWN
		do
			create md.make
			assert ("sup", md.to_html_fragment ("x^2^").has_substring ("<sup>2</sup>"))
		end

	test_subscript
			-- Test subscript.
		local
			md: SIMPLE_MARKDOWN
		do
			create md.make
			assert ("sub", md.to_html_fragment ("H~2~O").has_substring ("<sub>2</sub>"))
		end

	test_footnote_reference
			-- Test footnote reference.
		local
			md: SIMPLE_MARKDOWN
		do
			create md.make
			assert ("footnote ref", md.to_html_fragment ("Text[^1] here").has_substring ("<sup><a href=%"#fn-1%">"))
		end

	test_footnote_definition
			-- Test footnote definition.
		local
			md: SIMPLE_MARKDOWN
		do
			create md.make
			assert ("footnote def", md.to_html ("[^1]: This is a footnote").has_substring ("id=%"fn-1%""))
		end

feature -- Test: Paragraphs

	test_paragraph
			-- Test paragraph wrapping.
		local
			md: SIMPLE_MARKDOWN
		do
			create md.make
			assert ("paragraph", md.to_html ("Hello world").has_substring ("<p>Hello world</p>"))
		end

	test_multiple_paragraphs
			-- Test multiple paragraphs.
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
			-- Test table of contents generation.
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
			-- Test empty input.
		local
			md: SIMPLE_MARKDOWN
		do
			create md.make
			assert ("empty", md.to_html ("").is_empty)
		end

	test_crlf_line_endings
			-- Test Windows line endings.
		local
			md: SIMPLE_MARKDOWN
			html: STRING
		do
			create md.make
			html := md.to_html ("# Heading%R%NText")
			assert ("handles crlf", html.has_substring ("<h1"))
		end

feature {NONE} -- Assertions

	assert (a_tag: STRING; a_condition: BOOLEAN)
		do
			eqa_assert (a_tag, a_condition)
		end

end
