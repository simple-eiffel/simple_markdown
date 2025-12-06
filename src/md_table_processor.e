note
	description: "Processes GFM tables (| col1 | col2 |)"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	MD_TABLE_PROCESSOR

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize processor.
		do
			create inline_processor.make
		ensure
			inline_processor_created: inline_processor /= Void
		end

feature -- Query

	is_table_row (a_line: STRING): BOOLEAN
			-- Is `a_line' a table row (contains |)?
		require
			line_not_void: a_line /= Void
		local
			l_trimmed: STRING
		do
			l_trimmed := a_line.twin
			l_trimmed.left_adjust
			l_trimmed.right_adjust
			Result := l_trimmed.count >= 3 and then
				l_trimmed [1] = '|' and then
				l_trimmed [l_trimmed.count] = '|'
		end

	is_separator_row (a_line: STRING): BOOLEAN
			-- Is `a_line' a table separator row (|---|---|)?
		require
			line_not_void: a_line /= Void
		local
			l_trimmed: STRING
			i: INTEGER
			l_valid: BOOLEAN
		do
			l_trimmed := a_line.twin
			l_trimmed.left_adjust
			l_trimmed.right_adjust
			if is_table_row (a_line) then
				-- Check content is only |, -, :, and spaces
				l_valid := True
				from i := 1
				until i > l_trimmed.count or not l_valid
				loop
					l_valid := l_trimmed [i] = '|' or l_trimmed [i] = '-' or
						l_trimmed [i] = ':' or l_trimmed [i] = ' '
					i := i + 1
				end
				-- Must have at least one -
				Result := l_valid and then l_trimmed.has ('-')
			end
		end

feature -- Processing

	convert_table_start: STRING
			-- Opening table tag.
		do
			Result := "<table>%N"
		end

	convert_table_end: STRING
			-- Closing table tag.
		do
			Result := "</table>%N"
		end

	convert_header_row (a_line: STRING): STRING
			-- Convert header row to <thead><tr><th>...</th></tr></thead>.
		require
			line_not_void: a_line /= Void
			is_table_row: is_table_row (a_line)
		local
			l_cells: ARRAYED_LIST [STRING]
			i: INTEGER
		do
			l_cells := parse_cells (a_line)
			create Result.make (a_line.count * 2)
			Result.append ("<thead><tr>")
			from i := 1
			until i > l_cells.count
			loop
				Result.append ("<th>")
				Result.append (inline_processor.process (l_cells [i]))
				Result.append ("</th>")
				i := i + 1
			end
			Result.append ("</tr></thead>%N")
		end

	convert_body_row (a_line: STRING): STRING
			-- Convert body row to <tr><td>...</td></tr>.
		require
			line_not_void: a_line /= Void
			is_table_row: is_table_row (a_line)
		local
			l_cells: ARRAYED_LIST [STRING]
			i: INTEGER
		do
			l_cells := parse_cells (a_line)
			create Result.make (a_line.count * 2)
			Result.append ("<tr>")
			from i := 1
			until i > l_cells.count
			loop
				Result.append ("<td>")
				Result.append (inline_processor.process (l_cells [i]))
				Result.append ("</td>")
				i := i + 1
			end
			Result.append ("</tr>%N")
		end

	convert_tbody_start: STRING
			-- Opening tbody tag.
		do
			Result := "<tbody>%N"
		end

	convert_tbody_end: STRING
			-- Closing tbody tag.
		do
			Result := "</tbody>%N"
		end

feature {NONE} -- Implementation

	inline_processor: MD_INLINE_PROCESSOR
			-- Processor for inline elements in cells.

	parse_cells (a_line: STRING): ARRAYED_LIST [STRING]
			-- Parse table row into cells.
		require
			line_not_void: a_line /= Void
		local
			l_trimmed: STRING
			l_cell: STRING
			i: INTEGER
		do
			create Result.make (5)
			l_trimmed := a_line.twin
			l_trimmed.left_adjust
			l_trimmed.right_adjust

			-- Remove leading and trailing |
			if l_trimmed.count >= 2 and then l_trimmed [1] = '|' then
				l_trimmed.remove_head (1)
			end
			if l_trimmed.count >= 1 and then l_trimmed [l_trimmed.count] = '|' then
				l_trimmed.remove_tail (1)
			end

			-- Split by |
			create l_cell.make_empty
			from i := 1
			until i > l_trimmed.count
			loop
				if l_trimmed [i] = '|' then
					l_cell.left_adjust
					l_cell.right_adjust
					Result.extend (l_cell.twin)
					l_cell.wipe_out
				else
					l_cell.append_character (l_trimmed [i])
				end
				i := i + 1
			end
			-- Add last cell
			l_cell.left_adjust
			l_cell.right_adjust
			Result.extend (l_cell)
		end

note
	copyright: "Copyright (c) 2024-2025, Larry Rix"
	license: "MIT License"

end
