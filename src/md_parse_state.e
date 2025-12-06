note
	description: "Mutable state tracking during markdown parsing"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	MD_PARSE_STATE

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize parse state.
		do
			create paragraph.make_empty
			in_code_block := False
			in_list := False
			list_type := 0
			in_paragraph := False
			in_table := False
			table_header_done := False
		ensure
			paragraph_empty: paragraph.is_empty
			not_in_code: not in_code_block
			not_in_list: not in_list
			not_in_paragraph: not in_paragraph
			not_in_table: not in_table
		end

feature -- Access

	paragraph: STRING
			-- Current paragraph content being accumulated.

	in_code_block: BOOLEAN
			-- Currently inside a fenced code block?

	in_list: BOOLEAN
			-- Currently inside a list?

	list_type: INTEGER
			-- List type: 0 = none, 1 = unordered, 2 = ordered.

	in_paragraph: BOOLEAN
			-- Currently accumulating paragraph text?

	in_table: BOOLEAN
			-- Currently inside a table?

	table_header_done: BOOLEAN
			-- Has table header row been processed?

feature -- Element change

	set_in_code_block (a_value: BOOLEAN)
			-- Set `in_code_block' to `a_value'.
		do
			in_code_block := a_value
		ensure
			in_code_block_set: in_code_block = a_value
		end

	set_in_list (a_value: BOOLEAN)
			-- Set `in_list' to `a_value'.
		do
			in_list := a_value
		ensure
			in_list_set: in_list = a_value
		end

	set_list_type (a_value: INTEGER)
			-- Set `list_type' to `a_value'.
		require
			valid_type: a_value >= 0 and a_value <= 2
		do
			list_type := a_value
		ensure
			list_type_set: list_type = a_value
		end

	set_in_paragraph (a_value: BOOLEAN)
			-- Set `in_paragraph' to `a_value'.
		do
			in_paragraph := a_value
		ensure
			in_paragraph_set: in_paragraph = a_value
		end

	set_in_table (a_value: BOOLEAN)
			-- Set `in_table' to `a_value'.
		do
			in_table := a_value
		ensure
			in_table_set: in_table = a_value
		end

	set_table_header_done (a_value: BOOLEAN)
			-- Set `table_header_done' to `a_value'.
		do
			table_header_done := a_value
		ensure
			table_header_done_set: table_header_done = a_value
		end

invariant
	paragraph_exists: paragraph /= Void
	valid_list_type: list_type >= 0 and list_type <= 2

note
	copyright: "Copyright (c) 2024-2025, Larry Rix"
	license: "MIT License"

end
