note
	description: "[
		Simple Markdown - Production-ready Markdown to HTML conversion for Eiffel.

		CommonMark compliant with GitHub Flavored Markdown (GFM) and extended syntax.

		== CommonMark Core ==
		- Headings (# through ######)
		- Bold (**text** or __text__)
		- Italic (*text* or _text_)
		- Inline code (`code`)
		- Code blocks (``` with language hints)
		- Links [text](url)
		- Images ![alt](url)
		- Unordered lists (-, *, +)
		- Ordered lists (1. 2. 3.)
		- Blockquotes (>)
		- Horizontal rules (---, ***, ___)
		- Paragraphs

		== GFM Extensions ==
		- Strikethrough (~~text~~)
		- Tables (| col | col |)
		- Task lists (- [ ] and - [x])
		- Autolinks (URLs automatically linked)

		== Extended Syntax ==
		- Footnotes ([^1] references)
		- Highlight (==text==)
		- Subscript (~text~) / Superscript (^text^)
		- Heading IDs (# Heading {#custom-id})
		- Table of contents generation

		Usage:
			create md.make
			html := md.to_html ("# Hello World")

			-- Parse file
			html := md.to_html_from_file ("README.md")

			-- Get table of contents
			toc := md.table_of_contents
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"
	EIS: "name=CommonMark Spec", "src=https://spec.commonmark.org/", "protocol=URI", "tag=specification"
	EIS: "name=GFM Spec", "src=https://github.github.com/gfm/", "protocol=URI", "tag=specification"
	EIS: "name=Extended Syntax", "src=https://www.markdownguide.org/extended-syntax/", "protocol=URI", "tag=specification"

class
	SIMPLE_MARKDOWN

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize markdown parser.
		do
			create last_html.make_empty
			create inline_processor.make
			create table_processor.make
			create headings.make (10)
		ensure
			last_html_empty: last_html.is_empty
			headings_empty: headings.is_empty
		end

feature -- Conversion

	to_html (a_markdown: STRING): STRING
			-- Convert `a_markdown' to HTML.
		require
			markdown_not_void: a_markdown /= Void
		local
			l_lines: LIST [STRING]
			l_result: STRING
			l_state: MD_PARSE_STATE
			i: INTEGER
			l_line: STRING
		do
			headings.wipe_out
			create l_result.make (a_markdown.count * 2)
			l_lines := split_lines (a_markdown)
			create l_state.make

			from i := 1
			until i > l_lines.count
			loop
				l_line := l_lines [i]
				process_line (l_line, l_result, l_state, l_lines, i)
				i := i + 1
			end

			-- Close any open blocks
			close_all_blocks (l_result, l_state)

			last_html := l_result
			Result := l_result
		ensure
			result_not_void: Result /= Void
			last_html_set: last_html.same_string (Result)
		end

	to_html_from_file (a_path: STRING): STRING
			-- Convert markdown file at `a_path' to HTML.
		require
			path_not_void: a_path /= Void
			path_not_empty: not a_path.is_empty
		local
			l_file: PLAIN_TEXT_FILE
			l_content: STRING
		do
			create l_file.make_with_name (a_path)
			if l_file.exists and then l_file.is_readable then
				l_file.open_read
				create l_content.make (l_file.count)
				l_file.read_stream (l_file.count)
				l_content.append (l_file.last_string)
				l_file.close
				Result := to_html (l_content)
			else
				create Result.make_empty
			end
		ensure
			result_not_void: Result /= Void
		end

	to_html_fragment (a_markdown: STRING): STRING
			-- Convert `a_markdown' inline elements only (no block wrapping).
		require
			markdown_not_void: a_markdown /= Void
		do
			Result := inline_processor.process (a_markdown)
		ensure
			result_not_void: Result /= Void
		end

feature -- Access

	last_html: STRING
			-- Result of last conversion.

	headings: ARRAYED_LIST [TUPLE [level: INTEGER; text: STRING; id: detachable STRING]]
			-- Headings found during last parse (for TOC generation).

	table_of_contents: STRING
			-- Generate HTML table of contents from last parse.
		local
			h: TUPLE [level: INTEGER; text: STRING; id: detachable STRING]
			l_id: STRING
			i: INTEGER
		do
			create Result.make (headings.count * 50)
			Result.append ("<nav class=%"toc%"><ul>%N")
			from i := 1
			until i > headings.count
			loop
				h := headings [i]
				if attached h.id as l_custom_id then
					l_id := l_custom_id
				else
					l_id := generate_heading_id (h.text)
				end
				Result.append ("<li class=%"toc-h")
				Result.append_integer (h.level)
				Result.append ("%"><a href=%"#")
				Result.append (l_id)
				Result.append ("%">")
				Result.append (escape_html (h.text))
				Result.append ("</a></li>%N")
				i := i + 1
			end
			Result.append ("</ul></nav>%N")
		ensure
			result_not_void: Result /= Void
		end

feature -- Query

	is_heading (a_line: STRING): BOOLEAN
			-- Is `a_line' a heading?
		require
			line_not_void: a_line /= Void
		local
			l_trimmed: STRING
			l_count: INTEGER
		do
			l_trimmed := a_line.twin
			l_trimmed.left_adjust
			if l_trimmed.count > 0 and then l_trimmed [1] = '#' then
				from l_count := 1
				until l_count > l_trimmed.count or else l_trimmed [l_count] /= '#'
				loop l_count := l_count + 1 end
				l_count := l_count - 1
				Result := l_count >= 1 and l_count <= 6 and then
					(l_count >= l_trimmed.count or else l_trimmed [l_count + 1] = ' ')
			end
		end

	is_blockquote (a_line: STRING): BOOLEAN
			-- Is `a_line' a blockquote?
		require
			line_not_void: a_line /= Void
		local
			l_trimmed: STRING
		do
			l_trimmed := a_line.twin
			l_trimmed.left_adjust
			Result := l_trimmed.count > 0 and then l_trimmed [1] = '>'
		end

	is_unordered_list_item (a_line: STRING): BOOLEAN
			-- Is `a_line' an unordered list item?
		require
			line_not_void: a_line /= Void
		local
			l_trimmed: STRING
		do
			l_trimmed := a_line.twin
			l_trimmed.left_adjust
			if l_trimmed.count >= 2 then
				Result := (l_trimmed [1] = '-' or l_trimmed [1] = '*' or l_trimmed [1] = '+') and then
					l_trimmed [2] = ' '
			end
		end

	is_task_list_item (a_line: STRING): BOOLEAN
			-- Is `a_line' a task list item (- [ ] or - [x])?
		require
			line_not_void: a_line /= Void
		local
			l_trimmed: STRING
		do
			l_trimmed := a_line.twin
			l_trimmed.left_adjust
			if l_trimmed.count >= 5 then
				Result := (l_trimmed [1] = '-' or l_trimmed [1] = '*') and then
					l_trimmed [2] = ' ' and then l_trimmed [3] = '[' and then
					(l_trimmed [4] = ' ' or l_trimmed [4] = 'x' or l_trimmed [4] = 'X') and then
					l_trimmed [5] = ']'
			end
		end

	is_ordered_list_item (a_line: STRING): BOOLEAN
			-- Is `a_line' an ordered list item?
		require
			line_not_void: a_line /= Void
		local
			l_trimmed: STRING
			i: INTEGER
			l_found_digit: BOOLEAN
		do
			l_trimmed := a_line.twin
			l_trimmed.left_adjust
			if l_trimmed.count >= 3 then
				from i := 1; l_found_digit := False
				until i > l_trimmed.count or else not l_trimmed [i].is_digit
				loop l_found_digit := True; i := i + 1 end
				if l_found_digit and i <= l_trimmed.count - 1 then
					Result := l_trimmed [i] = '.' and then l_trimmed [i + 1] = ' '
				end
			end
		end

	is_code_fence (a_line: STRING): BOOLEAN
			-- Is `a_line' a code fence?
		require
			line_not_void: a_line /= Void
		local
			l_trimmed: STRING
		do
			l_trimmed := a_line.twin
			l_trimmed.left_adjust
			Result := l_trimmed.starts_with ("```") or l_trimmed.starts_with ("~~~")
		end

	is_horizontal_rule (a_line: STRING): BOOLEAN
			-- Is `a_line' a horizontal rule?
		require
			line_not_void: a_line /= Void
		local
			l_trimmed: STRING
			c: CHARACTER
			i, l_count: INTEGER
		do
			l_trimmed := a_line.twin
			l_trimmed.left_adjust
			l_trimmed.right_adjust
			if l_trimmed.count >= 3 then
				c := l_trimmed [1]
				if c = '-' or c = '*' or c = '_' then
					from i := 1; l_count := 0
					until i > l_trimmed.count
					loop
						if l_trimmed [i] = c then l_count := l_count + 1
						elseif l_trimmed [i] /= ' ' then l_count := 0; i := l_trimmed.count
						end
						i := i + 1
					end
					Result := l_count >= 3
				end
			end
		end

	is_blank_line (a_line: STRING): BOOLEAN
			-- Is `a_line' blank?
		require
			line_not_void: a_line /= Void
		local
			l_trimmed: STRING
		do
			l_trimmed := a_line.twin
			l_trimmed.left_adjust
			l_trimmed.right_adjust
			Result := l_trimmed.is_empty
		end

	is_footnote_definition (a_line: STRING): BOOLEAN
			-- Is `a_line' a footnote definition [^id]: text?
		require
			line_not_void: a_line /= Void
		local
			l_trimmed: STRING
		do
			l_trimmed := a_line.twin
			l_trimmed.left_adjust
			Result := l_trimmed.starts_with ("[^") and l_trimmed.has_substring ("]:")
		end

feature {NONE} -- Implementation: Line Processing

	process_line (a_line: STRING; a_result: STRING; a_state: MD_PARSE_STATE;
			a_lines: LIST [STRING]; a_index: INTEGER)
			-- Process single line and append to `a_result'.
		require
			line_not_void: a_line /= Void
			result_not_void: a_result /= Void
			state_not_void: a_state /= Void
		do
			if a_state.in_code_block then
				if is_code_fence (a_line) then
					a_result.append ("</code></pre>%N")
					a_state.set_in_code_block (False)
				else
					a_result.append (escape_html (a_line))
					a_result.append_character ('%N')
				end
			elseif is_code_fence (a_line) then
				close_paragraph (a_result, a_state)
				close_list (a_result, a_state)
				close_table (a_result, a_state)
				start_code_block (a_line, a_result, a_state)
			elseif table_processor.is_table_row (a_line) then
				close_paragraph (a_result, a_state)
				close_list (a_result, a_state)
				process_table_line (a_line, a_result, a_state, a_lines, a_index)
			elseif is_horizontal_rule (a_line) then
				close_all_blocks (a_result, a_state)
				a_result.append ("<hr>%N")
			elseif is_heading (a_line) then
				close_all_blocks (a_result, a_state)
				a_result.append (convert_heading (a_line))
			elseif is_blockquote (a_line) then
				close_paragraph (a_result, a_state)
				close_list (a_result, a_state)
				close_table (a_result, a_state)
				a_result.append (convert_blockquote (a_line))
			elseif is_task_list_item (a_line) then
				close_paragraph (a_result, a_state)
				close_table (a_result, a_state)
				if not a_state.in_list or a_state.list_type /= 1 then
					close_list (a_result, a_state)
					a_result.append ("<ul class=%"task-list%">%N")
					a_state.set_in_list (True)
					a_state.set_list_type (1)
				end
				a_result.append (convert_task_list_item (a_line))
			elseif is_unordered_list_item (a_line) then
				close_paragraph (a_result, a_state)
				close_table (a_result, a_state)
				if not a_state.in_list or a_state.list_type /= 1 then
					close_list (a_result, a_state)
					a_result.append ("<ul>%N")
					a_state.set_in_list (True)
					a_state.set_list_type (1)
				end
				a_result.append (convert_list_item (a_line))
			elseif is_ordered_list_item (a_line) then
				close_paragraph (a_result, a_state)
				close_table (a_result, a_state)
				if not a_state.in_list or a_state.list_type /= 2 then
					close_list (a_result, a_state)
					a_result.append ("<ol>%N")
					a_state.set_in_list (True)
					a_state.set_list_type (2)
				end
				a_result.append (convert_list_item (a_line))
			elseif is_footnote_definition (a_line) then
				close_all_blocks (a_result, a_state)
				a_result.append (convert_footnote_definition (a_line))
			elseif is_blank_line (a_line) then
				close_paragraph (a_result, a_state)
				close_list (a_result, a_state)
				close_table (a_result, a_state)
			else
				close_list (a_result, a_state)
				close_table (a_result, a_state)
				if a_state.in_paragraph then
					a_state.paragraph.append_character (' ')
				else
					a_state.set_in_paragraph (True)
				end
				a_state.paragraph.append (a_line)
			end
		end

feature {NONE} -- Implementation: Block Conversion

	convert_heading (a_line: STRING): STRING
			-- Convert heading line to HTML.
		require
			line_not_void: a_line /= Void
			is_heading: is_heading (a_line)
		local
			l_trimmed: STRING
			l_level: INTEGER
			l_content: STRING
			l_id: detachable STRING
			l_id_start: INTEGER
		do
			l_trimmed := a_line.twin
			l_trimmed.left_adjust

			-- Count # for level
			from l_level := 1
			until l_level > l_trimmed.count or else l_trimmed [l_level] /= '#'
			loop l_level := l_level + 1 end
			l_level := l_level - 1

			-- Extract content
			if l_level + 1 <= l_trimmed.count then
				l_content := l_trimmed.substring (l_level + 2, l_trimmed.count)
			else
				l_content := ""
			end
			l_content.right_adjust

			-- Remove trailing # if present
			from until l_content.is_empty or else l_content [l_content.count] /= '#'
			loop l_content.remove_tail (1) end
			l_content.right_adjust

			-- Check for custom ID {#id}
			l_id_start := l_content.substring_index ("{#", 1)
			if l_id_start > 0 and l_content [l_content.count] = '}' then
				l_id := l_content.substring (l_id_start + 2, l_content.count - 1)
				l_content := l_content.substring (1, l_id_start - 1)
				l_content.right_adjust
			else
				l_id := generate_heading_id (l_content)
			end

			-- Store for TOC
			headings.extend ([l_level, l_content.twin, l_id])

			create Result.make (l_content.count + 30)
			Result.append ("<h")
			Result.append_integer (l_level)
			Result.append (" id=%"")
			if attached l_id as lid then
				Result.append (lid)
			end
			Result.append ("%">")
			Result.append (inline_processor.process (l_content))
			Result.append ("</h")
			Result.append_integer (l_level)
			Result.append (">%N")
		ensure
			result_not_void: Result /= Void
		end

	convert_blockquote (a_line: STRING): STRING
			-- Convert blockquote to HTML.
		require
			line_not_void: a_line /= Void
		local
			l_trimmed: STRING
			l_content: STRING
		do
			l_trimmed := a_line.twin
			l_trimmed.left_adjust
			l_content := l_trimmed.substring (2, l_trimmed.count)
			l_content.left_adjust

			create Result.make (l_content.count + 30)
			Result.append ("<blockquote><p>")
			Result.append (inline_processor.process (l_content))
			Result.append ("</p></blockquote>%N")
		ensure
			result_not_void: Result /= Void
		end

	convert_list_item (a_line: STRING): STRING
			-- Convert list item to HTML.
		require
			line_not_void: a_line /= Void
		local
			l_trimmed: STRING
			l_content: STRING
			i: INTEGER
		do
			l_trimmed := a_line.twin
			l_trimmed.left_adjust

			if is_unordered_list_item (a_line) then
				l_content := l_trimmed.substring (3, l_trimmed.count)
			else
				from i := 1
				until i > l_trimmed.count or else l_trimmed [i] = '.'
				loop i := i + 1 end
				if i + 1 <= l_trimmed.count then
					l_content := l_trimmed.substring (i + 2, l_trimmed.count)
				else
					l_content := ""
				end
			end

			create Result.make (l_content.count + 15)
			Result.append ("<li>")
			Result.append (inline_processor.process (l_content))
			Result.append ("</li>%N")
		ensure
			result_not_void: Result /= Void
		end

	convert_task_list_item (a_line: STRING): STRING
			-- Convert task list item to HTML.
		require
			line_not_void: a_line /= Void
			is_task_list: is_task_list_item (a_line)
		local
			l_trimmed: STRING
			l_content: STRING
			l_checked: BOOLEAN
		do
			l_trimmed := a_line.twin
			l_trimmed.left_adjust

			l_checked := l_trimmed [4] = 'x' or l_trimmed [4] = 'X'
			if l_trimmed.count >= 7 then
				l_content := l_trimmed.substring (7, l_trimmed.count)
			else
				l_content := ""
			end

			create Result.make (l_content.count + 60)
			Result.append ("<li class=%"task-list-item%"><input type=%"checkbox%" disabled")
			if l_checked then
				Result.append (" checked")
			end
			Result.append ("> ")
			Result.append (inline_processor.process (l_content))
			Result.append ("</li>%N")
		ensure
			result_not_void: Result /= Void
		end

	convert_footnote_definition (a_line: STRING): STRING
			-- Convert footnote definition [^id]: text to HTML.
		require
			line_not_void: a_line /= Void
		local
			l_trimmed: STRING
			l_id, l_content: STRING
			l_end: INTEGER
		do
			l_trimmed := a_line.twin
			l_trimmed.left_adjust

			l_end := l_trimmed.index_of (']', 3)
			if l_end > 3 then
				l_id := l_trimmed.substring (3, l_end - 1)
				if l_end + 2 <= l_trimmed.count then
					l_content := l_trimmed.substring (l_end + 2, l_trimmed.count)
					l_content.left_adjust
				else
					l_content := ""
				end
			else
				l_id := ""
				l_content := ""
			end

			create Result.make (l_content.count + 50)
			Result.append ("<div class=%"footnote%" id=%"fn-")
			Result.append (l_id)
			Result.append ("%"><sup>")
			Result.append (l_id)
			Result.append ("</sup> ")
			Result.append (inline_processor.process (l_content))
			Result.append ("</div>%N")
		ensure
			result_not_void: Result /= Void
		end

feature {NONE} -- Implementation: Table Processing

	process_table_line (a_line: STRING; a_result: STRING; a_state: MD_PARSE_STATE;
			a_lines: LIST [STRING]; a_index: INTEGER)
			-- Process table line.
		require
			line_not_void: a_line /= Void
			result_not_void: a_result /= Void
			state_not_void: a_state /= Void
		do
			if not a_state.in_table then
				-- Starting new table
				a_result.append (table_processor.convert_table_start)
				a_state.set_in_table (True)
				a_state.set_table_header_done (False)
			end

			if table_processor.is_separator_row (a_line) then
				-- This is separator row after header, skip but mark header done
				a_state.set_table_header_done (True)
				a_result.append (table_processor.convert_tbody_start)
			elseif not a_state.table_header_done then
				-- This is header row
				a_result.append (table_processor.convert_header_row (a_line))
			else
				-- Body row
				a_result.append (table_processor.convert_body_row (a_line))
			end
		end

feature {NONE} -- Implementation: Code Block

	start_code_block (a_line: STRING; a_result: STRING; a_state: MD_PARSE_STATE)
			-- Start code block.
		require
			line_not_void: a_line /= Void
			result_not_void: a_result /= Void
			state_not_void: a_state /= Void
		local
			l_lang: detachable STRING
			l_trimmed: STRING
		do
			l_trimmed := a_line.twin
			l_trimmed.left_adjust

			if l_trimmed.count > 3 then
				if l_trimmed.starts_with ("```") then
					l_lang := l_trimmed.substring (4, l_trimmed.count)
				elseif l_trimmed.starts_with ("~~~") then
					l_lang := l_trimmed.substring (4, l_trimmed.count)
				end
				if attached l_lang then
					l_lang.left_adjust
					l_lang.right_adjust
				end
			end

			if attached l_lang and then not l_lang.is_empty then
				a_result.append ("<pre><code class=%"language-")
				a_result.append (l_lang)
				a_result.append ("%">%N")
			else
				a_result.append ("<pre><code>%N")
			end
			a_state.set_in_code_block (True)
		end

feature {NONE} -- Implementation: Block Closing

	close_paragraph (a_result: STRING; a_state: MD_PARSE_STATE)
			-- Close paragraph if open.
		require
			result_not_void: a_result /= Void
			state_not_void: a_state /= Void
		do
			if a_state.in_paragraph and not a_state.paragraph.is_empty then
				a_result.append ("<p>")
				a_result.append (inline_processor.process (a_state.paragraph))
				a_result.append ("</p>%N")
				a_state.paragraph.wipe_out
			end
			a_state.set_in_paragraph (False)
		end

	close_list (a_result: STRING; a_state: MD_PARSE_STATE)
			-- Close list if open.
		require
			result_not_void: a_result /= Void
			state_not_void: a_state /= Void
		do
			if a_state.in_list then
				if a_state.list_type = 1 then
					a_result.append ("</ul>%N")
				elseif a_state.list_type = 2 then
					a_result.append ("</ol>%N")
				end
			end
			a_state.set_in_list (False)
			a_state.set_list_type (0)
		end

	close_table (a_result: STRING; a_state: MD_PARSE_STATE)
			-- Close table if open.
		require
			result_not_void: a_result /= Void
			state_not_void: a_state /= Void
		do
			if a_state.in_table then
				if a_state.table_header_done then
					a_result.append (table_processor.convert_tbody_end)
				end
				a_result.append (table_processor.convert_table_end)
			end
			a_state.set_in_table (False)
			a_state.set_table_header_done (False)
		end

	close_all_blocks (a_result: STRING; a_state: MD_PARSE_STATE)
			-- Close all open blocks.
		require
			result_not_void: a_result /= Void
			state_not_void: a_state /= Void
		do
			if a_state.in_code_block then
				a_result.append ("</code></pre>%N")
				a_state.set_in_code_block (False)
			end
			close_paragraph (a_result, a_state)
			close_list (a_result, a_state)
			close_table (a_result, a_state)
		end

feature {NONE} -- Implementation: Utilities

	inline_processor: MD_INLINE_PROCESSOR
			-- Inline element processor.

	table_processor: MD_TABLE_PROCESSOR
			-- Table processor.

	split_lines (a_text: STRING): ARRAYED_LIST [STRING]
			-- Split `a_text' into lines.
		require
			text_not_void: a_text /= Void
		local
			l_normalized: STRING
			l_line: STRING
			i: INTEGER
		do
			create Result.make (10)
			l_normalized := a_text.twin
			l_normalized.replace_substring_all ("%R%N", "%N")
			l_normalized.replace_substring_all ("%R", "%N")

			create l_line.make_empty
			from i := 1
			until i > l_normalized.count
			loop
				if l_normalized [i] = '%N' then
					Result.extend (l_line.twin)
					l_line.wipe_out
				else
					l_line.append_character (l_normalized [i])
				end
				i := i + 1
			end
			if not l_line.is_empty or Result.is_empty then
				Result.extend (l_line)
			end
		ensure
			result_not_void: Result /= Void
		end

	escape_html (a_text: STRING): STRING
			-- Escape HTML special characters.
		require
			text_not_void: a_text /= Void
		do
			Result := a_text.twin
			Result.replace_substring_all ("&", "&amp;")
			Result.replace_substring_all ("<", "&lt;")
			Result.replace_substring_all (">", "&gt;")
			Result.replace_substring_all ("%"", "&quot;")
		ensure
			result_not_void: Result /= Void
		end

	generate_heading_id (a_text: STRING): STRING
			-- Generate URL-safe ID from heading text.
		require
			text_not_void: a_text /= Void
		local
			i: INTEGER
			c: CHARACTER
		do
			create Result.make (a_text.count)
			from i := 1
			until i > a_text.count
			loop
				c := a_text [i].as_lower
				if c.is_alpha_numeric then
					Result.append_character (c)
				elseif c = ' ' or c = '-' or c = '_' then
					Result.append_character ('-')
				end
				i := i + 1
			end
			-- Remove duplicate dashes
			from until not Result.has_substring ("--")
			loop Result.replace_substring_all ("--", "-") end
			-- Remove leading/trailing dashes
			if not Result.is_empty and then Result [1] = '-' then
				Result.remove_head (1)
			end
			if not Result.is_empty and then Result [Result.count] = '-' then
				Result.remove_tail (1)
			end
		ensure
			result_not_void: Result /= Void
		end

invariant
	last_html_exists: last_html /= Void
	headings_exist: headings /= Void
	inline_processor_exists: inline_processor /= Void
	table_processor_exists: table_processor /= Void

note
	copyright: "Copyright (c) 2024-2025, Larry Rix"
	license: "MIT License"

end
