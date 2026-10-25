note
	description: "[
		Markdown into a SIMPLE_DOCUMENT (simple_document), in Unicode
		(LG-12, for simple_bible's notes and simple_widgets' live-preview
		editor). The HTML path (SIMPLE_MARKDOWN.to_html) is untouched.

		BLOCKS, one line at a time:
		    # .. ######        a heading (levels 4 to 6 are read as 3)
		    --- *** ___        a rule
		    ``` or ~~~         a fenced code block, kept as typed
		    | a | b | + |---|  a table (header, separator, rows)
		    > text             a quote (each > one depth, at most 3)
		    - * + text         a bulleted item; 1. or 1) a numbered one;
		                       deeper indent, deeper item (at most 3)
		    anything else      a paragraph
		Lines of one paragraph, quote or item join with a space; a line
		ending in a backslash or two spaces breaks the line instead.

		INLINE: \x escapes, `code`, [text](target), <scheme:address>,
		**bold** __bold__, *italic* _italic_ (an underscore inside a word
		is a letter), ***both***, ~~strikethrough~~, ^superscript^.
		Spans nest: a closer must match its opener's character and run
		length, so *a **b** c* is italic holding bold.
	]"
	author: "Larry Rix"

class
	MD_DOCUMENT_READER

create
	make

feature {NONE} -- Initialization

	make
		do
			create list_indents.make (4)
		end

feature -- Reading

	read (a_markdown: READABLE_STRING_GENERAL): SIMPLE_DOCUMENT
			-- `a_markdown' as a document.
		local
			l_lines: ARRAYED_LIST [STRING_32]
			i: INTEGER
		do
			create Result.make
			l_lines := lines_of (a_markdown.to_string_32)
			list_indents.wipe_out
			from
				i := 1
			until
				i > l_lines.count
			loop
				i := read_block (l_lines, i, Result)
			end
		end

	read_inline (a_text: READABLE_STRING_GENERAL): DOC_TEXT
			-- `a_text' (one block's inline Markdown) as rich text.
		local
			l_out: STRING_32
			l_spans: ARRAYED_LIST [TUPLE [kind, start, length: INTEGER; target: STRING_32]]
			s: STRING_32
		do
			s := a_text.to_string_32
			create l_out.make (s.count)
			create l_spans.make (4)
			parse_range (s, 1, s.count, l_out, l_spans)
			create Result.make (l_out)
			across l_spans as sp loop
				if sp.kind = {DOC_TEXT}.Kind_link then
					Result.add_link (sp.start, sp.length, sp.target)
				else
					Result.add_span (sp.kind, sp.start, sp.length)
				end
			end
		end

feature {NONE} -- Blocks

	list_indents: ARRAYED_LIST [INTEGER]
			-- The indents of the open list's levels, shallowest first.

	read_block (a_lines: ARRAYED_LIST [STRING_32]; a_i: INTEGER; a_doc: SIMPLE_DOCUMENT): INTEGER
			-- Read the block starting at line `a_i' into `a_doc'; the line
			-- after it.
		require
			in_range: a_i >= 1 and a_i <= a_lines.count
		local
			l: STRING_32
			l_level: INTEGER
		do
			l := a_lines.i_th (a_i)
			if is_blank (l) then
				Result := a_i + 1
			elseif fence_of (l) /= Void then
				list_indents.wipe_out
				Result := read_fence (a_lines, a_i, a_doc)
			elseif heading_level (l) > 0 then
				list_indents.wipe_out
				l_level := heading_level (l)
				a_doc.add_block (text_block ({DOC_BLOCK}.Kind_heading, l_level.min ({DOC_BLOCK}.Max_level),
					heading_text (l)))
				Result := a_i + 1
			elseif is_rule (l) then
				list_indents.wipe_out
				a_doc.add_rule
				Result := a_i + 1
			elseif a_i < a_lines.count and then l.has ('|') and then is_table_separator (a_lines.i_th (a_i + 1)) then
				list_indents.wipe_out
				Result := read_table (a_lines, a_i, a_doc)
			elseif quote_depth (l) > 0 then
				list_indents.wipe_out
				Result := read_quote (a_lines, a_i, a_doc)
			elseif marker_end (l) > 0 then
				Result := read_item (a_lines, a_i, a_doc)
			else
				list_indents.wipe_out
				Result := read_paragraph (a_lines, a_i, a_doc)
			end
		ensure
			advances: Result > a_i
		end

	read_paragraph (a_lines: ARRAYED_LIST [STRING_32]; a_i: INTEGER; a_doc: SIMPLE_DOCUMENT): INTEGER
		local
			l_text: STRING_32
		do
			create l_text.make (80)
			from
				Result := a_i
				join_line (l_text, a_lines.i_th (Result))
				Result := Result + 1
			until
				Result > a_lines.count or else starts_block (a_lines, Result)
			loop
				join_line (l_text, a_lines.i_th (Result))
				Result := Result + 1
			end
			a_doc.add_block (text_block ({DOC_BLOCK}.Kind_paragraph, 1, l_text))
		end

	read_quote (a_lines: ARRAYED_LIST [STRING_32]; a_i: INTEGER; a_doc: SIMPLE_DOCUMENT): INTEGER
			-- Consecutive lines of one depth make one quote.
		local
			l_depth: INTEGER
			l_text: STRING_32
		do
			l_depth := quote_depth (a_lines.i_th (a_i))
			create l_text.make (80)
			from
				Result := a_i
			until
				Result > a_lines.count or else is_blank (a_lines.i_th (Result))
				or else quote_depth (a_lines.i_th (Result)) /= l_depth
			loop
				join_line (l_text, quote_text (a_lines.i_th (Result)))
				Result := Result + 1
			end
			a_doc.add_block (text_block ({DOC_BLOCK}.Kind_quote, l_depth.min ({DOC_BLOCK}.Max_level), l_text))
		end

	read_item (a_lines: ARRAYED_LIST [STRING_32]; a_i: INTEGER; a_doc: SIMPLE_DOCUMENT): INTEGER
			-- A list item and its indented continuation lines.
		local
			l: STRING_32
			l_indent, l_depth, l_kind, k: INTEGER
			l_text: STRING_32
		do
			l := a_lines.i_th (a_i)
			l_indent := indent_of (l)
			from
			until
				list_indents.is_empty or else list_indents.last <= l_indent
			loop
				list_indents.finish
				list_indents.remove
			end
			if list_indents.is_empty then
					-- A list that starts indented (one block read alone: the
					-- live preview's item) takes its depth from the indent,
					-- two spaces a level, as MD_DOCUMENT_WRITER writes it.
				from
					k := 0
				until
					k + 2 > l_indent
				loop
					list_indents.extend (k)
					k := k + 2
				end
			end
			if list_indents.is_empty or else list_indents.last < l_indent then
				list_indents.extend (l_indent)
			end
			l_depth := list_indents.count.min ({DOC_BLOCK}.Max_level)
			if l.item (l_indent + 1).is_digit then
				l_kind := {DOC_BLOCK}.Kind_numbered
			else
				l_kind := {DOC_BLOCK}.Kind_bullet
			end
			create l_text.make (80)
			join_line (l_text, l.substring (marker_end (l) + 1, l.count))
			from
				Result := a_i + 1
			until
				Result > a_lines.count or else is_blank (a_lines.i_th (Result))
				or else indent_of (a_lines.i_th (Result)) = 0
				or else starts_block (a_lines, Result)
			loop
				join_line (l_text, a_lines.i_th (Result))
				Result := Result + 1
			end
			a_doc.add_block (text_block (l_kind, l_depth, l_text))
		end

	read_fence (a_lines: ARRAYED_LIST [STRING_32]; a_i: INTEGER; a_doc: SIMPLE_DOCUMENT): INTEGER
			-- A fenced code block, kept as typed, up to its closing fence
			-- (the same character, at least as long, nothing after it).
		require
			fenced: fence_of (a_lines.i_th (a_i)) /= Void
		local
			l_open: STRING_32
			l_body: ARRAYED_LIST [STRING_32]
			l_text: STRING_32
			l_done: BOOLEAN
		do
			if attached fence_of (a_lines.i_th (a_i)) as al_open then
				l_open := al_open
			else
				create l_open.make_filled ('`', 3)
			end
			create l_body.make (8)
			from
				Result := a_i + 1
			until
				Result > a_lines.count or l_done
			loop
				if closes_fence (a_lines.i_th (Result), l_open) then
					l_done := True
				else
					l_body.extend (a_lines.i_th (Result))
				end
				Result := Result + 1
			end
			create l_text.make (80)
			across l_body as b loop
				if @ b.cursor_index > 1 then
					l_text.append_character ('%N')
				end
				l_text.append (b)
			end
			a_doc.add_code_block (l_text).do_nothing
		end

	closes_fence (a_line: READABLE_STRING_32; a_open: STRING_32): BOOLEAN
			-- Does `a_line' close the fence `a_open'?
		do
			if attached fence_of (a_line) as al_close then
				Result := al_close.item (1) = a_open.item (1) and then al_close.count >= a_open.count
					and then is_blank (a_line.substring (indent_of (a_line) + al_close.count + 1, a_line.count))
			end
		end

	read_table (a_lines: ARRAYED_LIST [STRING_32]; a_i: INTEGER; a_doc: SIMPLE_DOCUMENT): INTEGER
			-- Header, separator, then every row line.
		local
			l_header, l_row: ARRAYED_LIST [STRING_32]
			l_names: ARRAY [READABLE_STRING_GENERAL]
			l_blanks: ARRAY [READABLE_STRING_GENERAL]
			t: DOC_BLOCK
		do
			l_header := cells_of (a_lines.i_th (a_i))
			create l_names.make_filled ({STRING_32} "", 1, l_header.count)
			create l_blanks.make_filled ({STRING_32} "", 1, l_header.count)
			t := a_doc.add_table (l_names)
			fill_row (t, 1, l_header)
			from
				Result := a_i + 2
			until
				Result > a_lines.count or else is_blank (a_lines.i_th (Result))
				or else not a_lines.i_th (Result).has ('|')
			loop
				l_row := cells_of (a_lines.i_th (Result))
				t.add_row (l_blanks)
				fill_row (t, t.row_count, l_row)
				Result := Result + 1
			end
		end

	fill_row (a_table: DOC_BLOCK; a_row: INTEGER; a_cells: ARRAYED_LIST [STRING_32])
			-- Row `a_row''s cells from `a_cells' (inline Markdown); missing
			-- cells stay empty, extra ones are dropped.
		local
			c: INTEGER
		do
			from
				c := 1
			until
				c > a_table.column_count or c > a_cells.count
			loop
				a_table.cell (a_row, c).take (read_inline (a_cells.i_th (c)))
				c := c + 1
			end
		end

	text_block (a_kind, a_level: INTEGER; a_text: STRING_32): DOC_BLOCK
			-- A block of `a_kind' holding `a_text' read as inline Markdown.
		require
			text_kind: a_kind /= {DOC_BLOCK}.Kind_rule and a_kind /= {DOC_BLOCK}.Kind_table
			level_valid: a_level >= 1 and a_level <= {DOC_BLOCK}.Max_level
		local
			l_text: STRING_32
		do
			l_text := a_text.twin
			if not l_text.is_empty and then l_text.item (l_text.count) = '%U' then
					-- A break after the last line breaks nothing.
				l_text.remove_tail (1)
			end
			create Result.make (a_kind, a_level, {STRING_32} "")
			Result.content.take (read_inline (l_text))
		end

feature {NONE} -- Line classes

	lines_of (a_text: STRING_32): ARRAYED_LIST [STRING_32]
			-- `a_text' cut at line ends (LF, CRLF, CR), tabs as four spaces.
		local
			i: INTEGER
			l_line: STRING_32
		do
			create Result.make (32)
			create l_line.make (80)
			from
				i := 1
			until
				i > a_text.count
			loop
				inspect a_text.item (i)
				when '%R' then
					Result.extend (l_line)
					create l_line.make (80)
					if i < a_text.count and then a_text.item (i + 1) = '%N' then
						i := i + 1
					end
				when '%N' then
					Result.extend (l_line)
					create l_line.make (80)
				when '%T' then
					l_line.append ({STRING_32} "    ")
				else
					l_line.extend (a_text.item (i))
				end
				i := i + 1
			end
			if not l_line.is_empty then
				Result.extend (l_line)
			end
		end

	is_blank (a_line: READABLE_STRING_32): BOOLEAN
		do
			Result := across a_line as c all c.is_space end
		end

	indent_of (a_line: READABLE_STRING_32): INTEGER
			-- Leading spaces.
		do
			from
			until
				Result >= a_line.count or else a_line.item (Result + 1) /= ' '
			loop
				Result := Result + 1
			end
		ensure
			in_line: Result >= 0 and Result <= a_line.count
		end

	starts_block (a_lines: ARRAYED_LIST [STRING_32]; a_i: INTEGER): BOOLEAN
			-- Does line `a_i' end the block before it: blank, or the start
			-- of a heading, rule, fence, quote, list item or table?
		local
			l: STRING_32
		do
			l := a_lines.i_th (a_i)
			Result := is_blank (l) or else heading_level (l) > 0 or else is_rule (l)
				or else fence_of (l) /= Void or else quote_depth (l) > 0 or else marker_end (l) > 0
				or else (a_i < a_lines.count and then l.has ('|') and then is_table_separator (a_lines.i_th (a_i + 1)))
		end

	heading_level (a_line: READABLE_STRING_32): INTEGER
			-- 1 .. 6 for an ATX heading line; 0 otherwise.
		local
			i, n: INTEGER
		do
			i := indent_of (a_line)
			if i <= 3 then
				from
					n := 0
				until
					i + n >= a_line.count or else a_line.item (i + n + 1) /= '#'
				loop
					n := n + 1
				end
				if n >= 1 and n <= 6 and then (i + n = a_line.count or else a_line.item (i + n + 1) = ' ') then
					Result := n
				end
			end
		ensure
			range: Result >= 0 and Result <= 6
		end

	heading_text (a_line: READABLE_STRING_32): STRING_32
			-- A heading's text: after the #s, closing #s dropped.
		require
			heading: heading_level (a_line) > 0
		local
			i: INTEGER
		do
			i := indent_of (a_line) + heading_level (a_line)
			Result := a_line.substring (i + 1, a_line.count).to_string_32
			Result.adjust
			from
				i := Result.count
			until
				i < 1 or else Result.item (i) /= '#'
			loop
				i := i - 1
			end
			if i < Result.count and then (i = 0 or else Result.item (i) = ' ') then
				Result.keep_head (i)
				Result.right_adjust
			end
		end

	is_rule (a_line: READABLE_STRING_32): BOOLEAN
			-- Three or more of one of - * _, nothing else but spaces.
		local
			c: CHARACTER_32
			n: INTEGER
		do
			if indent_of (a_line) <= 3 and then indent_of (a_line) < a_line.count then
				c := a_line.item (indent_of (a_line) + 1)
				if c = '-' or c = '*' or c = '_' then
					Result := True
					across a_line as ch loop
						if ch = c then
							n := n + 1
						elseif ch /= ' ' then
							Result := False
						end
					end
					Result := Result and n >= 3
				end
			end
		end

	fence_of (a_line: READABLE_STRING_32): detachable STRING_32
			-- The fence (``` or ~~~, three or more) a line opens with.
		local
			i, n: INTEGER
			c: CHARACTER_32
		do
			i := indent_of (a_line)
			if i <= 3 and then i < a_line.count then
				c := a_line.item (i + 1)
				if c = '`' or c = '~' then
					from
						n := 0
					until
						i + n >= a_line.count or else a_line.item (i + n + 1) /= c
					loop
						n := n + 1
					end
					if n >= 3 then
						create Result.make_filled (c, n)
					end
				end
			end
		end

	quote_depth (a_line: READABLE_STRING_32): INTEGER
			-- How many > open the line (a space may stand between two).
		local
			i: INTEGER
			l_done: BOOLEAN
		do
			from
				i := indent_of (a_line) + 1
			until
				i > a_line.count or l_done
			loop
				if a_line.item (i) = '>' then
					Result := Result + 1
					i := i + 1
				elseif a_line.item (i) = ' ' and then Result > 0 and then i < a_line.count
					and then a_line.item (i + 1) = '>'
				then
					i := i + 1
				else
					l_done := True
				end
			end
		end

	quote_text (a_line: READABLE_STRING_32): STRING_32
			-- The line after its >s and one space.
		local
			i, n: INTEGER
		do
			from
				i := indent_of (a_line) + 1
				n := quote_depth (a_line)
			until
				n = 0 or i > a_line.count
			loop
				if a_line.item (i) = '>' then
					n := n - 1
				end
				i := i + 1
			end
			if i <= a_line.count and then a_line.item (i) = ' ' then
				i := i + 1
			end
			Result := a_line.substring (i, a_line.count).to_string_32
		end

	marker_end (a_line: READABLE_STRING_32): INTEGER
			-- For a list item line, the position of the space after its
			-- marker (or the line's end for an empty item); 0 otherwise.
		local
			i, n: INTEGER
			c: CHARACTER_32
		do
			i := indent_of (a_line)
			if i < a_line.count then
				c := a_line.item (i + 1)
				if c = '-' or c = '*' or c = '+' then
					if i + 1 = a_line.count then
						Result := i + 1
					elseif a_line.item (i + 2) = ' ' then
						Result := i + 2
					end
				elseif c.is_digit then
					from
						n := 0
					until
						i + n >= a_line.count or else not a_line.item (i + n + 1).is_digit
					loop
						n := n + 1
					end
					if n <= 9 and then i + n < a_line.count
						and then (a_line.item (i + n + 1) = '.' or a_line.item (i + n + 1) = ')')
					then
						if i + n + 1 = a_line.count then
							Result := i + n + 1
						elseif a_line.item (i + n + 2) = ' ' then
							Result := i + n + 2
						end
					end
				end
			end
		ensure
			in_line: Result >= 0 and Result <= a_line.count
		end

	is_table_separator (a_line: READABLE_STRING_32): BOOLEAN
			-- | --- | :-: | and the like: only pipes, dashes, colons and
			-- spaces, with at least one dash and one pipe.
		do
			Result := a_line.has ('|') and then a_line.has ('-')
				and then across a_line as c all c = '|' or c = '-' or c = ':' or c = ' ' end
		end

	cells_of (a_line: READABLE_STRING_32): ARRAYED_LIST [STRING_32]
			-- A table row's cells, trimmed; \| is a pipe inside a cell.
		local
			i: INTEGER
			l_cell, l_line: STRING_32
		do
			create Result.make (4)
			l_line := a_line.to_string_32
			l_line.adjust
			if not l_line.is_empty and then l_line.item (1) = '|' then
				l_line.remove_head (1)
			end
			if not l_line.is_empty and then l_line.item (l_line.count) = '|'
				and then (l_line.count = 1 or else l_line.item (l_line.count - 1) /= '\')
			then
				l_line.remove_tail (1)
			end
			create l_cell.make (16)
			from
				i := 1
			until
				i > l_line.count
			loop
				if l_line.item (i) = '\' and then i < l_line.count and then l_line.item (i + 1) = '|' then
					l_cell.append ({STRING_32} "\|")
					i := i + 1
				elseif l_line.item (i) = '|' then
					l_cell.adjust
					Result.extend (l_cell)
					create l_cell.make (16)
				else
					l_cell.extend (l_line.item (i))
				end
				i := i + 1
			end
			l_cell.adjust
			Result.extend (l_cell)
		end

	join_line (a_text: STRING_32; a_line: READABLE_STRING_32)
			-- Append `a_line', trimmed, to `a_text': with a space, or right
			-- after a hard break mark (NUL) the line before left. A line
			-- ending in two spaces or a lone backslash leaves that mark;
			-- `parse_range' turns it into a line feed and `text_block' drops
			-- one left at the very end.
		local
			l_line: STRING_32
			l_hard: BOOLEAN
		do
			l_line := a_line.to_string_32
			if l_line.count >= 2 and then l_line.ends_with ({STRING_32} "  ") then
				l_hard := True
			elseif not l_line.is_empty and then l_line.item (l_line.count) = '\'
				and then (l_line.count = 1 or else l_line.item (l_line.count - 1) /= '\')
			then
				l_line.remove_tail (1)
				l_hard := True
			end
			l_line.adjust
			if not a_text.is_empty and then a_text.item (a_text.count) /= '%U' then
				a_text.append_character (' ')
			end
			a_text.append (l_line)
			if l_hard then
				a_text.append_character ('%U')
			end
		end

feature {NONE} -- Inline

	parse_range (s: STRING_32; a_lo, a_hi: INTEGER; a_out: STRING_32;
			a_spans: ARRAYED_LIST [TUPLE [kind, start, length: INTEGER; target: STRING_32]])
			-- Characters `a_lo' .. `a_hi' of `s' into `a_out', their spans
			-- into `a_spans' (positions in `a_out').
		local
			i, j, n, k, l_start, l_close, l_paren_end: INTEGER
			c: CHARACTER_32
			l_target: STRING_32
		do
			from
				i := a_lo
			until
				i > a_hi
			loop
				c := s.item (i)
				if c = '%U' then
						-- A hard line break the block reader marked.
					a_out.append_character ('%N')
					i := i + 1
				elseif c = '\' and then i < a_hi and then Escapable.has (s.item (i + 1)) then
					a_out.extend (s.item (i + 1))
					i := i + 2
				elseif c = '`' then
					n := run_length (s, i, a_hi)
					j := closing_run (s, i + n, a_hi, '`', n, False)
					if j > 0 then
						l_start := a_out.count + 1
						a_out.append (code_content (s.substring (i + n, j - 1)))
						if a_out.count >= l_start then
							a_spans.extend ([{DOC_TEXT}.Kind_code, l_start, a_out.count - l_start + 1, {STRING_32} ""])
						end
						i := j + n
					else
						a_out.append (s.substring (i, i + n - 1))
						i := i + n
					end
				elseif c = '[' and then link_parts (s, i, a_hi) /= Void then
					if attached link_parts (s, i, a_hi) as al_parts then
						l_close := al_parts.close
						l_paren_end := al_parts.paren_end
						l_target := s.substring (l_close + 2, l_paren_end - 1)
						l_target.adjust
						l_start := a_out.count + 1
						parse_range (s, i + 1, l_close - 1, a_out, a_spans)
						if a_out.count >= l_start and then not l_target.is_empty then
							a_spans.extend ([{DOC_TEXT}.Kind_link, l_start, a_out.count - l_start + 1, l_target])
						end
						i := l_paren_end + 1
					end
				elseif c = '<' and then autolink_end (s, i, a_hi) > 0 then
					j := autolink_end (s, i, a_hi)
					l_start := a_out.count + 1
					a_out.append (s.substring (i + 1, j - 1))
					a_spans.extend ([{DOC_TEXT}.Kind_link, l_start, j - i - 1, s.substring (i + 1, j - 1)])
					i := j + 1
				elseif c = '*' or c = '_' or c = '~' or c = '^' then
					n := run_length (s, i, a_hi)
					k := delimiter_kind (c, n)
					j := 0
					if k > 0 and then opens_at (s, i, n, a_hi) then
						j := closing_run (s, i + n, a_hi, c, n, True)
					end
					if j > 0 then
						l_start := a_out.count + 1
						parse_range (s, i + n, j - 1, a_out, a_spans)
						if a_out.count >= l_start then
							if c = '*' or c = '_' then
								if n >= 2 then
									a_spans.extend ([{DOC_TEXT}.Kind_bold, l_start, a_out.count - l_start + 1, {STRING_32} ""])
								end
								if n /= 2 then
									a_spans.extend ([{DOC_TEXT}.Kind_italic, l_start, a_out.count - l_start + 1, {STRING_32} ""])
								end
							else
								a_spans.extend ([k, l_start, a_out.count - l_start + 1, {STRING_32} ""])
							end
						end
						i := j + n
					else
						a_out.append (s.substring (i, i + n - 1))
						i := i + n
					end
				else
					a_out.extend (c)
					i := i + 1
				end
			end
		end

	Escapable: STRING_32
			-- What a backslash makes literal.
		once
			Result := {STRING_32} "\`*_{}[]()<>#+-.!|~^"
		end

	run_length (s: STRING_32; a_i, a_hi: INTEGER): INTEGER
			-- How many of `s [a_i]' stand in a row from `a_i'.
		do
			from
				Result := 1
			until
				a_i + Result > a_hi or else s.item (a_i + Result) /= s.item (a_i)
			loop
				Result := Result + 1
			end
		ensure
			positive: Result >= 1
		end

	delimiter_kind (c: CHARACTER_32; n: INTEGER): INTEGER
			-- The span kind a run of `n' `c's opens; 0 for none (bold and
			-- italic both answer bold here; the caller splits them).
		do
			if (c = '*' or c = '_') and n <= 3 then
				Result := {DOC_TEXT}.Kind_bold
			elseif c = '~' and n = 2 then
				Result := {DOC_TEXT}.Kind_strike
			elseif c = '^' and n = 1 then
				Result := {DOC_TEXT}.Kind_superscript
			end
		end

	opens_at (s: STRING_32; a_i, n, a_hi: INTEGER): BOOLEAN
			-- Can the run of `n' at `a_i' open a span: something not a space
			-- follows, and an underscore does not stand inside a word?
		do
			Result := a_i + n <= a_hi and then not s.item (a_i + n).is_space
			if Result and s.item (a_i) = '_' and then a_i > 1 then
				Result := not is_word_character (s.item (a_i - 1))
			end
		end

	closing_run (s: STRING_32; a_from, a_hi: INTEGER; c: CHARACTER_32; n: INTEGER; a_flanked: BOOLEAN): INTEGER
			-- The first run of exactly `n' `c's from `a_from' that can
			-- close (not after a space, when `a_flanked'; an underscore not
			-- before a word character); code spans and escapes are skipped.
			-- 0 for none.
		local
			i, m, j: INTEGER
		do
			from
				i := a_from
			until
				i > a_hi or Result > 0
			loop
				if s.item (i) = '\' and then c /= '`' then
					i := i + 2
				elseif s.item (i) = '`' and then c /= '`' then
					m := run_length (s, i, a_hi)
					j := closing_run (s, i + m, a_hi, '`', m, False)
					if j > 0 then
						i := j + m
					else
						i := i + m
					end
				elseif s.item (i) = c then
					m := run_length (s, i, a_hi)
					if m = n and then i > a_from
						and then (not a_flanked or else not s.item (i - 1).is_space)
						and then (c /= '_' or else i + m > a_hi or else not is_word_character (s.item (i + m)))
					then
						Result := i
					elseif m = n and then i = a_from and then not a_flanked then
						Result := i
					end
					i := i + m
				else
					i := i + 1
				end
			end
		ensure
			none_or_after: Result = 0 or else Result >= a_from
		end

	code_content (a_raw: STRING_32): STRING_32
			-- A code span's text: one leading and one trailing space go
			-- when both are there and the text is not all spaces.
		do
			Result := a_raw.twin
			if Result.count >= 2 and then Result.item (1) = ' ' and then Result.item (Result.count) = ' '
				and then not across Result as ch all ch = ' ' end
			then
				Result := Result.substring (2, Result.count - 1)
			end
		end

	link_parts (s: STRING_32; a_i, a_hi: INTEGER): detachable TUPLE [close, paren_end: INTEGER]
			-- For [text](target) at `a_i': where `]' and the closing `)'
			-- stand; Void when it is not a link.
		local
			i, l_depth, l_close: INTEGER
		do
			from
				i := a_i + 1
				l_depth := 1
			until
				i > a_hi or l_close > 0
			loop
				if s.item (i) = '\' then
					i := i + 1
				elseif s.item (i) = '[' then
					l_depth := l_depth + 1
				elseif s.item (i) = ']' then
					l_depth := l_depth - 1
					if l_depth = 0 then
						l_close := i
					end
				end
				i := i + 1
			end
			if l_close > 0 and then l_close < a_hi and then s.item (l_close + 1) = '(' then
				from
					i := l_close + 2
					l_depth := 1
				until
					i > a_hi or l_depth = 0
				loop
					if s.item (i) = '\' then
						i := i + 1
					elseif s.item (i) = '(' then
						l_depth := l_depth + 1
					elseif s.item (i) = ')' then
						l_depth := l_depth - 1
					end
					i := i + 1
				end
				if l_depth = 0 then
					Result := [l_close, i - 1]
				end
			end
		end

	autolink_end (s: STRING_32; a_i, a_hi: INTEGER): INTEGER
			-- For <scheme:address> at `a_i' (no spaces, a colon after a
			-- letter): where `>' stands; 0 otherwise.
		local
			i: INTEGER
			l_colon: BOOLEAN
		do
			from
				i := a_i + 1
			until
				i > a_hi or Result > 0 or else s.item (i).is_space or else s.item (i) = '<'
			loop
				if s.item (i) = ':' and then i > a_i + 1 then
					l_colon := True
				elseif s.item (i) = '>' then
					if l_colon and then i > a_i + 1 then
						Result := i
					else
						i := a_hi
					end
				end
				i := i + 1
			end
		end

	is_word_character (c: CHARACTER_32): BOOLEAN
			-- A letter or a digit (an underscore beside one is a letter).
		do
			Result := c.is_alpha_numeric or else c.code > 127 and then not c.is_space
		end

end
