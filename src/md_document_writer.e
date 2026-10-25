note
	description: "[
		A SIMPLE_DOCUMENT out as Markdown, in Unicode (LG-12): what
		MD_DOCUMENT_READER reads back into the same document. The note
		store's export and the live-preview editor's block source.

		    heading      # .. ###
		    paragraph    its text; a line break as a backslash and a
		                 line end
		    items        - text, 1. text, two spaces of indent a depth
		    quote        > text, one > a depth
		    rule         ---
		    code block   fenced with ``` (with ~~~~ when the text holds
		                 a ```)
		    table        | a | b |, then | --- | --- |, then the rows

		Blocks are a blank line apart, except list items, which follow
		one another line by line. Inline: **bold**, _italic_, ~~struck~~,
		^raised^, `code`, [text](target). Italic is written with
		underscores so it can never fuse with a bold run into ***.
		Characters Markdown would read as syntax are escaped. Small
		capitals have no Markdown form and are written plain.
	]"
	author: "Larry Rix"

class
	MD_DOCUMENT_WRITER

create
	make

feature {NONE} -- Initialization

	make
		do
		end

feature -- Writing

	write (a_document: SIMPLE_DOCUMENT): STRING_32
			-- `a_document' as Markdown.
		local
			i: INTEGER
		do
			create Result.make (1024)
			from
				i := 1
			until
				i > a_document.count
			loop
				if i > 1 then
					if a_document.block (i - 1).is_list_item and a_document.block (i).is_list_item then
						Result.append_character ('%N')
					else
						Result.append ({STRING_32} "%N%N")
					end
				end
				Result.append (write_block (a_document, i))
				i := i + 1
			end
		end

	write_block (a_document: SIMPLE_DOCUMENT; a_i: INTEGER): STRING_32
			-- Block `a_i' as Markdown: what the live-preview editor shows
			-- while the caret is in it.
		require
			in_range: a_i >= 1 and a_i <= a_document.count
		local
			b: DOC_BLOCK
			r, c: INTEGER
		do
			b := a_document.block (a_i)
			create Result.make (b.content.count + 16)
			inspect b.kind
			when {DOC_BLOCK}.Kind_heading then
				Result.append (create {STRING_32}.make_filled ('#', b.level))
				Result.append_character (' ')
				Result.append (line_text (b.content, {STRING_32} ""))
			when {DOC_BLOCK}.Kind_bullet then
				Result.append (indent (b.level))
				Result.append ({STRING_32} "- ")
				Result.append (line_text (b.content, indent (b.level) + {STRING_32} "  "))
			when {DOC_BLOCK}.Kind_numbered then
				Result.append (indent (b.level))
				Result.append_integer (a_document.number_of (a_i))
				Result.append ({STRING_32} ". ")
				Result.append (line_text (b.content, indent (b.level) + {STRING_32} "   "))
			when {DOC_BLOCK}.Kind_quote then
				Result.append (quote_prefix (b.level))
				Result.append (line_text (b.content, quote_prefix (b.level)))
			when {DOC_BLOCK}.Kind_rule then
				Result.append ({STRING_32} "---")
			when {DOC_BLOCK}.Kind_code_block then
				Result.append (fence_for (b.content.text))
				Result.append_character ('%N')
				Result.append (b.content.text)
				Result.append_character ('%N')
				Result.append (fence_for (b.content.text))
			when {DOC_BLOCK}.Kind_table then
				from
					r := 1
				until
					r > b.row_count
				loop
					if r > 1 then
						Result.append_character ('%N')
					end
					Result.append_character ('|')
					from
						c := 1
					until
						c > b.column_count
					loop
						Result.append_character (' ')
						Result.append (cell_text (b.cell (r, c)))
						Result.append ({STRING_32} " |")
						c := c + 1
					end
					if r = 1 then
						Result.append ({STRING_32} "%N|")
						from
							c := 1
						until
							c > b.column_count
						loop
							Result.append ({STRING_32} " --- |")
							c := c + 1
						end
					end
					r := r + 1
				end
			else
				Result.append (line_text (b.content, {STRING_32} ""))
			end
		end

	write_inline (a_text: DOC_TEXT): STRING_32
			-- `a_text' as inline Markdown, links outermost.
		local
			i, e, k: INTEGER
		do
			create Result.make (a_text.count + 8)
			from
				i := 1
			until
				i > a_text.count
			loop
				k := a_text.link_at (i)
				if k > 0 then
					e := (a_text.span_start (k) + a_text.span_length (k) - 1).min (a_text.count)
					from
					until
						e >= a_text.count or else a_text.link_at (e + 1) /= k
					loop
						e := e + 1
					end
					Result.append_character ('[')
					append_emphasis (a_text, i, e, Result)
					Result.append ({STRING_32} "](")
					Result.append (escaped_target (a_text.span_target (k)))
					Result.append_character (')')
				else
					from
						e := i
					until
						e >= a_text.count or else a_text.link_at (e + 1) > 0
					loop
						e := e + 1
					end
					append_emphasis (a_text, i, e, Result)
				end
				i := e + 1
			end
		end

feature {NONE} -- Implementation

	line_text (a_text: DOC_TEXT; a_continuation: STRING_32): STRING_32
			-- `a_text' inline, with a leading block marker escaped and each
			-- line break written as a backslash, a line end and
			-- `a_continuation' (the prefix the next line needs).
		local
			l_inline: STRING_32
			i: INTEGER
		do
			l_inline := write_inline (a_text)
			create Result.make (l_inline.count + 8)
			from
				i := 1
			until
				i > l_inline.count
			loop
				if l_inline.item (i) = '%N' then
					Result.append ({STRING_32} "\%N")
					Result.append (a_continuation)
				else
					Result.extend (l_inline.item (i))
				end
				i := i + 1
			end
			Result := escaped_start (Result)
		end

	escaped_start (a_line: STRING_32): STRING_32
			-- `a_line' with a start that would read as a block (#, -, +, >,
			-- a number and a dot or parenthesis) escaped.
		local
			n: INTEGER
		do
			Result := a_line
			if not a_line.is_empty then
				inspect a_line.item (1)
				when '#', '-', '+', '>' then
					Result := {STRING_32} "\" + a_line
				when '0' .. '9' then
					from
						n := 1
					until
						n >= a_line.count or else not a_line.item (n + 1).is_digit
					loop
						n := n + 1
					end
					if n < a_line.count and then (a_line.item (n + 1) = '.' or a_line.item (n + 1) = ')') then
						Result := a_line.substring (1, n) + {STRING_32} "\" + a_line.substring (n + 1, a_line.count)
					end
				else
				end
			end
		end

	append_emphasis (a_text: DOC_TEXT; a_lo, a_hi: INTEGER; a_out: STRING_32)
			-- Characters `a_lo' .. `a_hi' of `a_text' with their bold,
			-- italic, strikethrough, superscript and code delimiters,
			-- opened and closed so they nest. A delimiter never opens before
			-- a space nor closes after one: those spaces move outside it.
		local
			i, e, f, k: INTEGER
			l_open: ARRAYED_LIST [INTEGER]
			l_segment: STRING_32
		do
			create l_open.make (4)
			from
				i := a_lo
			until
				i > a_hi
			loop
				f := a_text.flags_at (i) & Emphasis_mask
				e := a_text.stretch_end (i).min (a_hi)
					-- Close from the top down to the first open flag that ends.
				from
					k := 1
				until
					k > l_open.count or else f & l_open.i_th (k) = 0
				loop
					k := k + 1
				end
				if k <= l_open.count then
					close_down_to (k, l_open, a_out)
				end
				l_segment := a_text.text.substring (i, e)
				if f & {DOC_TEXT}.Flag_code = 0 then
					l_segment := escaped (l_segment)
				end
					-- Leading spaces stand before any delimiter this opens.
				if has_new_flags (f, l_open) then
					from
					until
						l_segment.is_empty or else l_segment.item (1) /= ' '
					loop
						a_out.append_character (' ')
						l_segment.remove_head (1)
					end
				end
				across Flag_order as fl loop
					if f & fl /= 0 and then not l_open.has (fl) then
						a_out.append (delimiter (fl, a_text.text.substring (i, e)))
						l_open.extend (fl)
					end
				end
				a_out.append (l_segment)
				i := e + 1
			end
			close_down_to (1, l_open, a_out)
		end

	close_down_to (a_k: INTEGER; a_open: ARRAYED_LIST [INTEGER]; a_out: STRING_32)
			-- Close the open delimiters from the last down to number `a_k',
			-- before any trailing spaces of `a_out'.
		local
			l_spaces: INTEGER
		do
			if a_k <= a_open.count then
				from
				until
					a_out.count - l_spaces < 1 or else a_out.item (a_out.count - l_spaces) /= ' '
				loop
					l_spaces := l_spaces + 1
				end
				a_out.remove_tail (l_spaces)
				from
				until
					a_open.count < a_k
				loop
					a_out.append (delimiter (a_open.last, {STRING_32} ""))
					a_open.finish
					a_open.remove
				end
				a_out.append (create {STRING_32}.make_filled (' ', l_spaces))
			end
		ensure
			closed: a_open.count = (a_k - 1).min (old a_open.count)
		end

	has_new_flags (a_flags: INTEGER; a_open: ARRAYED_LIST [INTEGER]): BOOLEAN
			-- Does `a_flags' hold a flag not open yet?
		do
			Result := across Flag_order as fl some a_flags & fl /= 0 and then not a_open.has (fl) end
		end

	Emphasis_mask: INTEGER
			-- The flags written as delimiters (links and small capitals are
			-- not).
		once
			Result := {DOC_TEXT}.Flag_code | {DOC_TEXT}.Flag_bold | {DOC_TEXT}.Flag_italic
				| {DOC_TEXT}.Flag_strike | {DOC_TEXT}.Flag_superscript
		end

	Flag_order: ARRAY [INTEGER]
			-- The order delimiters open in, outermost first.
		once
			Result := <<{DOC_TEXT}.Flag_bold, {DOC_TEXT}.Flag_italic, {DOC_TEXT}.Flag_strike,
				{DOC_TEXT}.Flag_superscript, {DOC_TEXT}.Flag_code>>
		end

	delimiter (a_flag: INTEGER; a_content: READABLE_STRING_32): STRING_32
			-- The delimiter for `a_flag'.
		do
			if a_flag = {DOC_TEXT}.Flag_bold then
				Result := {STRING_32} "**"
			elseif a_flag = {DOC_TEXT}.Flag_italic then
				Result := {STRING_32} "_"
			elseif a_flag = {DOC_TEXT}.Flag_strike then
				Result := {STRING_32} "~~"
			elseif a_flag = {DOC_TEXT}.Flag_superscript then
				Result := {STRING_32} "^"
			else
				Result := {STRING_32} "`"
			end
		end

	escaped (a_text: READABLE_STRING_32): STRING_32
			-- `a_text' with every character Markdown reads as inline syntax
			-- behind a backslash.
		do
			create Result.make (a_text.count + 4)
			across a_text as c loop
				if Inline_syntax.has (c) then
					Result.append_character ('\')
				end
				Result.extend (c)
			end
		end

	Inline_syntax: STRING_32
		once
			Result := {STRING_32} "\`*_[]<~^|"
		end

	escaped_target (a_target: READABLE_STRING_32): STRING_32
			-- A link target with its parentheses balanced by escaping.
		do
			create Result.make (a_target.count)
			across a_target as c loop
				if c = '(' or c = ')' or c = '\' then
					Result.append_character ('\')
				end
				Result.extend (c)
			end
		end

	cell_text (a_cell: DOC_TEXT): STRING_32
			-- A cell's inline Markdown on one line.
		do
			Result := write_inline (a_cell)
			Result.replace_substring_all ({STRING_32} "%N", {STRING_32} " ")
		end

	indent (a_level: INTEGER): STRING_32
			-- Two spaces a depth below the first.
		do
			create Result.make_filled (' ', 2 * (a_level - 1))
		end

	quote_prefix (a_level: INTEGER): STRING_32
		do
			create Result.make_filled ('>', a_level)
			Result.append_character (' ')
		end

	fence_for (a_code: READABLE_STRING_32): STRING_32
			-- ``` unless the code holds one; then ~~~~.
		do
			if a_code.has_substring ({STRING_32} "```") then
				Result := {STRING_32} "~~~~"
			else
				Result := {STRING_32} "```"
			end
		end

end
