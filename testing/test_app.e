note
	description: "Test application for simple_markdown"
	author: "Larry Rix"

class
	TEST_APP

create
	make

feature {NONE} -- Initialization

	make
			-- Run tests.
		do
			create tests
			print ("simple_markdown test runner%N")
			print ("=============================%N%N")

			passed := 0
			failed := 0

			-- Headings
			run_test (agent tests.test_heading_h1, "test_heading_h1")
			run_test (agent tests.test_heading_h2_to_h6, "test_heading_h2_to_h6")
			run_test (agent tests.test_heading_custom_id, "test_heading_custom_id")

			-- Bold/Italic
			run_test (agent tests.test_bold_asterisks, "test_bold_asterisks")
			run_test (agent tests.test_bold_underscores, "test_bold_underscores")
			run_test (agent tests.test_italic_asterisk, "test_italic_asterisk")
			run_test (agent tests.test_italic_underscore, "test_italic_underscore")

			-- Code
			run_test (agent tests.test_inline_code, "test_inline_code")
			run_test (agent tests.test_inline_code_escapes_html, "test_inline_code_escapes_html")

			-- Strikethrough
			run_test (agent tests.test_strikethrough, "test_strikethrough")

			-- Links/Images
			run_test (agent tests.test_link, "test_link")
			run_test (agent tests.test_image, "test_image")
			run_test (agent tests.test_autolink, "test_autolink")

			-- Lists
			run_test (agent tests.test_unordered_list, "test_unordered_list")
			run_test (agent tests.test_ordered_list, "test_ordered_list")
			run_test (agent tests.test_task_list, "test_task_list")

			-- Blockquote
			run_test (agent tests.test_blockquote, "test_blockquote")

			-- Code Blocks
			run_test (agent tests.test_code_block, "test_code_block")
			run_test (agent tests.test_code_block_with_language, "test_code_block_with_language")

			-- Horizontal Rule
			run_test (agent tests.test_horizontal_rule_dashes, "test_horizontal_rule_dashes")
			run_test (agent tests.test_horizontal_rule_asterisks, "test_horizontal_rule_asterisks")

			-- Tables
			run_test (agent tests.test_simple_table, "test_simple_table")

			-- Extended Syntax
			run_test (agent tests.test_highlight, "test_highlight")
			run_test (agent tests.test_superscript, "test_superscript")
			run_test (agent tests.test_subscript, "test_subscript")

			-- Footnotes
			run_test (agent tests.test_footnote_reference, "test_footnote_reference")
			run_test (agent tests.test_footnote_definition, "test_footnote_definition")

			-- Paragraphs
			run_test (agent tests.test_paragraph, "test_paragraph")
			run_test (agent tests.test_multiple_paragraphs, "test_multiple_paragraphs")

			-- TOC
			run_test (agent tests.test_toc_generation, "test_toc_generation")

			-- Edge Cases
			run_test (agent tests.test_empty_input, "test_empty_input")
			run_test (agent tests.test_crlf_line_endings, "test_crlf_line_endings")

			-- Fixtures
			run_test (agent tests.test_comprehensive_fixture, "test_comprehensive_fixture")
			run_test (agent tests.test_real_readme_fixture, "test_real_readme_fixture")
			run_test (agent tests.test_toc_from_comprehensive, "test_toc_from_comprehensive")
			run_test (agent tests.test_multiple_tables, "test_multiple_tables")
			run_test (agent tests.test_nested_formatting_stress, "test_nested_formatting_stress")
			run_test (agent tests.test_large_code_block, "test_large_code_block")
			run_test (agent tests.test_special_chars_in_table, "test_special_chars_in_table")

			print ("%N=============================%N")
			print ("Results: " + passed.out + " passed, " + failed.out + " failed%N")

			if failed > 0 then
				print ("TESTS FAILED%N")
			else
				print ("ALL TESTS PASSED%N")
			end
		end

feature {NONE} -- Implementation

	tests: LIB_TESTS

	passed: INTEGER
	failed: INTEGER

	run_test (a_test: PROCEDURE; a_name: STRING)
			-- Run a single test and update counters.
		local
			l_retried: BOOLEAN
		do
			if not l_retried then
				a_test.call (Void)
				print ("  PASS: " + a_name + "%N")
				passed := passed + 1
			end
		rescue
			print ("  FAIL: " + a_name + "%N")
			failed := failed + 1
			l_retried := True
			retry
		end

end
