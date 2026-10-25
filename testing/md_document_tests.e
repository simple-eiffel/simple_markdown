note
	description: "[
		LG-12: Markdown into SIMPLE_DOCUMENT and back. Blocks, inline
		spans, escapes, Unicode (pointed Hebrew, polytonic Greek), and the
		round trip: what the writer writes, the reader reads back into the
		same document.
	]"
	author: "Larry Rix"

class
	MD_DOCUMENT_TESTS

inherit
	TEST_SET_BASE

feature -- Blocks

	test_reads_blocks
		local
			d: SIMPLE_DOCUMENT
			t: DOC_BLOCK
		do
			d := reader.read ("# Title%N%NOne line%Nand the next.%N%N---%N%N#### Deep%N%N> quoted%N> on%N%N>> deeper")
			assert_integers_equal ("six blocks", 6, d.count)
			assert_integers_equal ("a heading", {DOC_BLOCK}.Kind_heading, d.block (1).kind)
			assert_strings_equal ("its text", {STRING_32} "Title", d.block (1).content.text)
			assert_strings_equal ("soft break is a space", {STRING_32} "One line and the next.", d.block (2).content.text)
			assert_integers_equal ("a rule", {DOC_BLOCK}.Kind_rule, d.block (3).kind)
			assert_integers_equal ("level 4 read as 3", 3, d.block (4).level)
			assert_strings_equal ("quote lines join", {STRING_32} "quoted on", d.block (5).content.text)
			assert_integers_equal ("depth 2", 2, d.block (6).level)
			d := reader.read ("- one%N- two%N  - inner%N    - deepest%N- three%N%N1. first%N2) second%N%Nend")
			assert_integers_equal ("items and a paragraph", 8, d.count)
			assert_integers_equal ("bullet", {DOC_BLOCK}.Kind_bullet, d.block (1).kind)
			assert_integers_equal ("inner is depth 2", 2, d.block (3).level)
			assert_integers_equal ("deepest is depth 3", 3, d.block (4).level)
			assert_integers_equal ("back to depth 1", 1, d.block (5).level)
			assert_integers_equal ("numbered", {DOC_BLOCK}.Kind_numbered, d.block (6).kind)
			assert_integers_equal ("counted", 2, d.number_of (7))
			d := reader.read ("```eiffel%Nx := 1%N%N  y := **2**%N```%N%N| Word | Gloss |%N| --- | :-: |%N| **bara** | to create |%N| a \| b | c |")
			assert_integers_equal ("code block and table", 2, d.count)
			assert_strings_equal ("code kept as typed", {STRING_32} "x := 1%N%N  y := **2**", d.block (1).content.text)
			t := d.block (2)
			assert_integers_equal ("a table", {DOC_BLOCK}.Kind_table, t.kind)
			assert_integers_equal ("three rows", 3, t.row_count)
			assert_strings_equal ("a cell", {STRING_32} "bara", t.cell (2, 1).text)
			assert_true ("bold in a cell", t.cell (2, 1).has_kind_at ({DOC_TEXT}.Kind_bold, 1))
			assert_strings_equal ("an escaped pipe in a cell", {STRING_32} "a | b", t.cell (3, 1).text)
		end

	test_hard_breaks
		local
			d: SIMPLE_DOCUMENT
		do
			d := reader.read ("first\%Nsecond  %Nthird  ")
			assert_strings_equal ("backslash and two spaces break; a trailing break goes",
				{STRING_32} "first%Nsecond%Nthird", d.block (1).content.text)
		end

feature -- Inline

	test_reads_inline
		local
			r: DOC_TEXT
		do
			r := reader.read_inline ("a **bold** _it_ ***both*** ~~gone~~ x^2^ `code *not*` end")
			assert_strings_equal ("delimiters gone", {STRING_32} "a bold it both gone x2 code *not* end", r.text)
			assert_true ("bold", r.flags_at (3) = r.Flag_bold)
			assert_true ("italic", r.flags_at (8) = r.Flag_italic)
			assert_true ("both", r.flags_at (11) = r.Flag_bold | r.Flag_italic)
			assert_true ("struck", r.flags_at (16) = r.Flag_strike)
			assert_true ("raised", r.flags_at (22) = r.Flag_superscript)
			assert_true ("code, its stars literal", r.flags_at (25) = r.Flag_code and r.text.has_substring ("*not*"))
			r := reader.read_inline ("*outer **inner** outer*")
			assert_strings_equal ("nested", {STRING_32} "outer inner outer", r.text)
			assert_true ("italic holds bold", r.flags_at (8) = r.Flag_bold | r.Flag_italic and r.flags_at (2) = r.Flag_italic)
			r := reader.read_inline ("see [John **3:16**](John 3:16) or <https://example.org>")
			assert_strings_equal ("link text", {STRING_32} "see John 3:16 or https://example.org", r.text)
			assert_true ("the link's target", r.link_at (6) > 0 and then r.span_target (r.link_at (6)).same_string ("John 3:16"))
			assert_true ("bold inside the link", r.has_kind_at (r.Kind_bold, 10))
			assert_true ("an autolink", r.link_at (20) > 0)
			r := reader.read_inline ("snake_case_name and \*not\* and 2 * 3 * 4")
			assert_strings_equal ("intraword underscores, escapes and spaced stars stay",
				{STRING_32} "snake_case_name and *not* and 2 * 3 * 4", r.text)
			assert_integers_equal ("no spans at all", 0, r.span_count)
		end

feature -- Round trip

	test_round_trip
			-- Read, write, read: the same document.
		local
			d1, d2: SIMPLE_DOCUMENT
			s: STRING_32
		do
			d1 := reader.read (sample)
			s := writer.write (d1)
			d2 := reader.read (s)
			assert_true ("the same document after a round trip", d1.is_same_as (d2))
			assert_strings_equal ("and writing again changes nothing", s, writer.write (d2))
		end

	test_round_trip_hebrew_greek
		local
			d1, d2: SIMPLE_DOCUMENT
			r: DOC_TEXT
		do
			create d1.make
			d1.add_heading (2, hebrew).do_nothing
			r := d1.add_paragraph (greek + {STRING_32} " is John 1:1, and " + hebrew + {STRING_32} " opens Genesis.")
			r.add_bold (1, 2)
			r.add_link (greek.count + 5, 8, "John 1:1")
			d1.add_bullet (1, hebrew).do_nothing
			d2 := reader.read (writer.write (d1))
			assert_true ("Hebrew and Greek survive the round trip", d1.is_same_as (d2))
		end

	test_writer_escapes
			-- Text that looks like syntax is written so it reads back as
			-- text.
		local
			d1, d2: SIMPLE_DOCUMENT
		do
			create d1.make
			d1.add_paragraph ("1. not a list, *not* bold, [not] a link, a|b").do_nothing
			d1.add_paragraph ("# not a heading").do_nothing
			d1.add_paragraph ("- not an item").do_nothing
			d2 := reader.read (writer.write (d1))
			assert_true ("read back as the same plain text", d1.is_same_as (d2))
			assert_integers_equal ("still three paragraphs", 3, d2.count)
		end

	test_block_source
			-- One block's source reads back as that block: what the live
			-- preview shows and takes back.
		local
			d1, d2: SIMPLE_DOCUMENT
			i: INTEGER
		do
			d1 := reader.read (sample)
			from
				i := 1
			until
				i > d1.count
			loop
				d2 := reader.read (writer.write_block (d1, i))
				assert_integers_equal ("one block from block " + i.out, 1, d2.count)
				assert_true ("block " + i.out + " the same", d1.block (i).is_same_as (d2.block (1)))
				i := i + 1
			end
		end

feature {NONE} -- Fixtures

	reader: MD_DOCUMENT_READER
		once
			create Result.make
		end

	writer: MD_DOCUMENT_WRITER
		once
			create Result.make
		end

	sample: STRING_32
			-- Every block kind and inline span.
		once
			Result := {STRING_32} "# Notes on Genesis 1%N%N"
				+ {STRING_32} "In the **beginning** God _created_; see [John 1:1](John 1:1).\%NA second line with ~~strike~~ and x^2^ and `code`.%N%N"
				+ {STRING_32} "## Senses%N%N"
				+ {STRING_32} "- to create%N  - of God alone%N- to shape%N%N"
				+ {STRING_32} "1. first%N2. second%N%N"
				+ {STRING_32} "> The verb is used only of divine activity.%N%N"
				+ {STRING_32} "---%N%N"
				+ {STRING_32} "```%Nx := 1%N```%N%N"
				+ {STRING_32} "| Word | Gloss |%N| --- | --- |%N| **bara** | to create |"
		end

	hebrew: STRING_32
			-- B'reshit, pointed.
		once
			create Result.make (12)
			across <<0x05D1, 0x05BC, 0x05B0, 0x05E8, 0x05B5, 0x05D0, 0x05E9, 0x05B4, 0x05C1, 0x05D9, 0x05EA>> as c loop
				Result.append_code (c.to_natural_32)
			end
		end

	greek: STRING_32
			-- En arche, polytonic.
		once
			create Result.make (8)
			across <<0x1F18, 0x03BD, 0x0020, 0x1F00, 0x03C1, 0x03C7, 0x1FC7>> as c loop
				Result.append_code (c.to_natural_32)
			end
		end

end
