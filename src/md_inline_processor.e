note
	description: "Processes inline Markdown elements (bold, italic, links, etc.)"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	MD_INLINE_PROCESSOR

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize processor.
		do
		end

feature -- Processing

	process (a_text: STRING): STRING
			-- Process all inline markdown elements in `a_text'.
		require
			text_not_void: a_text /= Void
		do
			Result := a_text.twin
			-- Order matters: process more specific patterns first
			Result := process_images (Result)
			Result := process_links (Result)
			Result := process_autolinks (Result)
			Result := process_code_inline (Result)
			Result := process_footnote_refs (Result)
			Result := process_highlight (Result)
			Result := process_strikethrough (Result)
			Result := process_bold (Result)
			Result := process_italic (Result)
			Result := process_superscript (Result)
			Result := process_subscript (Result)
		end

feature -- Element Processing

	process_bold (a_text: STRING): STRING
			-- Convert **text** and __text__ to <strong>.
		require
			text_not_void: a_text /= Void
		local
			i, l_start, l_end: INTEGER
			l_content: STRING
		do
			Result := a_text.twin

			-- Process **text**
			from i := 1
			until i > Result.count - 3
			loop
				if Result [i] = '*' and then i + 1 <= Result.count and then Result [i + 1] = '*' then
					l_start := i
					from l_end := i + 2
					until l_end > Result.count - 1 or else (Result [l_end] = '*' and then Result [l_end + 1] = '*')
					loop l_end := l_end + 1 end
					if l_end <= Result.count - 1 then
						l_content := Result.substring (l_start + 2, l_end - 1)
						Result.replace_substring ("<strong>" + l_content + "</strong>", l_start, l_end + 1)
						i := l_start + 17 + l_content.count
					else
						i := i + 1
					end
				else
					i := i + 1
				end
			end

			-- Process __text__
			from i := 1
			until i > Result.count - 3
			loop
				if Result [i] = '_' and then i + 1 <= Result.count and then Result [i + 1] = '_' then
					l_start := i
					from l_end := i + 2
					until l_end > Result.count - 1 or else (Result [l_end] = '_' and then Result [l_end + 1] = '_')
					loop l_end := l_end + 1 end
					if l_end <= Result.count - 1 then
						l_content := Result.substring (l_start + 2, l_end - 1)
						Result.replace_substring ("<strong>" + l_content + "</strong>", l_start, l_end + 1)
						i := l_start + 17 + l_content.count
					else
						i := i + 1
					end
				else
					i := i + 1
				end
			end
		end

	process_italic (a_text: STRING): STRING
			-- Convert *text* and _text_ to <em>.
		require
			text_not_void: a_text /= Void
		local
			i, l_start, l_end: INTEGER
			l_content: STRING
		do
			Result := a_text.twin

			-- Process *text*
			from i := 1
			until i > Result.count - 1
			loop
				if Result [i] = '*' then
					if i + 1 <= Result.count and then Result [i + 1] /= '*' then
						if i = 1 or else Result [i - 1] /= '*' then
							l_start := i
							from l_end := i + 1
							until l_end > Result.count or else Result [l_end] = '*'
							loop l_end := l_end + 1 end
							if l_end <= Result.count and then (l_end + 1 > Result.count or else Result [l_end + 1] /= '*') then
								l_content := Result.substring (l_start + 1, l_end - 1)
								if not l_content.is_empty then
									Result.replace_substring ("<em>" + l_content + "</em>", l_start, l_end)
									i := l_start + 9 + l_content.count
								else i := i + 1 end
							else i := i + 1 end
						else i := i + 1 end
					else i := i + 1 end
				else i := i + 1 end
			end

			-- Process _text_
			from i := 1
			until i > Result.count - 1
			loop
				if Result [i] = '_' then
					if i + 1 <= Result.count and then Result [i + 1] /= '_' then
						if i = 1 or else Result [i - 1] /= '_' then
							l_start := i
							from l_end := i + 1
							until l_end > Result.count or else Result [l_end] = '_'
							loop l_end := l_end + 1 end
							if l_end <= Result.count and then (l_end + 1 > Result.count or else Result [l_end + 1] /= '_') then
								l_content := Result.substring (l_start + 1, l_end - 1)
								if not l_content.is_empty then
									Result.replace_substring ("<em>" + l_content + "</em>", l_start, l_end)
									i := l_start + 9 + l_content.count
								else i := i + 1 end
							else i := i + 1 end
						else i := i + 1 end
					else i := i + 1 end
				else i := i + 1 end
			end
		end

	process_strikethrough (a_text: STRING): STRING
			-- Convert ~~text~~ to <del> (GFM).
		require
			text_not_void: a_text /= Void
		local
			i, l_start, l_end: INTEGER
			l_content: STRING
		do
			Result := a_text.twin

			from i := 1
			until i > Result.count - 3
			loop
				if Result [i] = '~' and then i + 1 <= Result.count and then Result [i + 1] = '~' then
					l_start := i
					from l_end := i + 2
					until l_end > Result.count - 1 or else (Result [l_end] = '~' and then Result [l_end + 1] = '~')
					loop l_end := l_end + 1 end
					if l_end <= Result.count - 1 then
						l_content := Result.substring (l_start + 2, l_end - 1)
						Result.replace_substring ("<del>" + l_content + "</del>", l_start, l_end + 1)
						i := l_start + 11 + l_content.count
					else
						i := i + 1
					end
				else
					i := i + 1
				end
			end
		end

	process_code_inline (a_text: STRING): STRING
			-- Convert `code` to <code>.
		require
			text_not_void: a_text /= Void
		local
			i, l_start, l_end: INTEGER
			l_content: STRING
		do
			Result := a_text.twin

			from i := 1
			until i > Result.count
			loop
				if Result [i] = '`' then
					l_start := i
					from l_end := i + 1
					until l_end > Result.count or else Result [l_end] = '`'
					loop l_end := l_end + 1 end
					if l_end <= Result.count then
						l_content := Result.substring (l_start + 1, l_end - 1)
						Result.replace_substring ("<code>" + escape_html (l_content) + "</code>", l_start, l_end)
						i := l_start + 13 + l_content.count
					else
						i := i + 1
					end
				else
					i := i + 1
				end
			end
		end

	process_links (a_text: STRING): STRING
			-- Convert [text](url) to <a href="url">text</a>.
		require
			text_not_void: a_text /= Void
		local
			i, l_text_start, l_text_end, l_url_start, l_url_end: INTEGER
			l_text, l_url: STRING
		do
			Result := a_text.twin

			from i := 1
			until i > Result.count
			loop
				if Result [i] = '[' then
					l_text_start := i
					from l_text_end := i + 1
					until l_text_end > Result.count or else Result [l_text_end] = ']'
					loop l_text_end := l_text_end + 1 end
					if l_text_end <= Result.count and then l_text_end + 1 <= Result.count and then Result [l_text_end + 1] = '(' then
						l_url_start := l_text_end + 2
						from l_url_end := l_url_start
						until l_url_end > Result.count or else Result [l_url_end] = ')'
						loop l_url_end := l_url_end + 1 end
						if l_url_end <= Result.count then
							l_text := Result.substring (l_text_start + 1, l_text_end - 1)
							l_url := Result.substring (l_url_start, l_url_end - 1)
							Result.replace_substring ("<a href=%"" + l_url + "%">" + l_text + "</a>", l_text_start, l_url_end)
							i := l_text_start + 15 + l_text.count + l_url.count
						else i := i + 1 end
					else i := i + 1 end
				else i := i + 1 end
			end
		end

	process_images (a_text: STRING): STRING
			-- Convert ![alt](url) to <img>.
		require
			text_not_void: a_text /= Void
		local
			i, l_alt_start, l_alt_end, l_url_start, l_url_end: INTEGER
			l_alt, l_url: STRING
		do
			Result := a_text.twin

			from i := 1
			until i > Result.count - 1
			loop
				if Result [i] = '!' and then Result [i + 1] = '[' then
					l_alt_start := i + 1
					from l_alt_end := l_alt_start + 1
					until l_alt_end > Result.count or else Result [l_alt_end] = ']'
					loop l_alt_end := l_alt_end + 1 end
					if l_alt_end <= Result.count and then l_alt_end + 1 <= Result.count and then Result [l_alt_end + 1] = '(' then
						l_url_start := l_alt_end + 2
						from l_url_end := l_url_start
						until l_url_end > Result.count or else Result [l_url_end] = ')'
						loop l_url_end := l_url_end + 1 end
						if l_url_end <= Result.count then
							l_alt := Result.substring (l_alt_start + 1, l_alt_end - 1)
							l_url := Result.substring (l_url_start, l_url_end - 1)
							Result.replace_substring ("<img src=%"" + l_url + "%" alt=%"" + l_alt + "%">", i, l_url_end)
							i := i + 20 + l_alt.count + l_url.count
						else i := i + 1 end
					else i := i + 1 end
				else i := i + 1 end
			end
		end

	process_autolinks (a_text: STRING): STRING
			-- Convert bare URLs to links (GFM autolinks).
		require
			text_not_void: a_text /= Void
		local
			i, l_start, l_end: INTEGER
			l_url: STRING
		do
			Result := a_text.twin

			-- Process https:// and http://
			from i := 1
			until i > Result.count - 7
			loop
				if (Result.substring (i, i + 6).same_string ("http://") or else
					(i + 7 <= Result.count and then Result.substring (i, i + 7).same_string ("https://"))) and then
					(i = 1 or else not Result [i - 1].is_alpha_numeric) and then
					(i = 1 or else Result [i - 1] /= '"') then
					l_start := i
					-- Find end of URL (whitespace or end of string)
					from l_end := i
					until l_end > Result.count or else Result [l_end].is_space or else Result [l_end] = '<'
					loop l_end := l_end + 1 end
					l_end := l_end - 1
					-- Remove trailing punctuation
					from
					until l_end < l_start or else not is_trailing_punctuation (Result [l_end])
					loop l_end := l_end - 1 end
					if l_end >= l_start + 7 then
						l_url := Result.substring (l_start, l_end)
						Result.replace_substring ("<a href=%"" + l_url + "%">" + l_url + "</a>", l_start, l_end)
						i := l_start + 15 + l_url.count * 2
					else
						i := i + 1
					end
				else
					i := i + 1
				end
			end
		end

feature {NONE} -- Implementation

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
		end

	is_trailing_punctuation (c: CHARACTER): BOOLEAN
			-- Is `c' punctuation that shouldn't be part of URL?
		do
			Result := c = '.' or c = ',' or c = ';' or c = ':' or c = '!' or c = '?' or c = ')' or c = ']'
		end

feature -- Extended Syntax Processing

	process_highlight (a_text: STRING): STRING
			-- Convert ==text== to <mark> (highlighted text).
		require
			text_not_void: a_text /= Void
		local
			i, l_start, l_end: INTEGER
			l_content: STRING
		do
			Result := a_text.twin

			from i := 1
			until i > Result.count - 3
			loop
				if Result [i] = '=' and then i + 1 <= Result.count and then Result [i + 1] = '=' then
					l_start := i
					from l_end := i + 2
					until l_end > Result.count - 1 or else (Result [l_end] = '=' and then Result [l_end + 1] = '=')
					loop l_end := l_end + 1 end
					if l_end <= Result.count - 1 then
						l_content := Result.substring (l_start + 2, l_end - 1)
						Result.replace_substring ("<mark>" + l_content + "</mark>", l_start, l_end + 1)
						i := l_start + 13 + l_content.count
					else
						i := i + 1
					end
				else
					i := i + 1
				end
			end
		end

	process_superscript (a_text: STRING): STRING
			-- Convert ^text^ to <sup> (superscript).
		require
			text_not_void: a_text /= Void
		local
			i, l_start, l_end: INTEGER
			l_content: STRING
		do
			Result := a_text.twin

			from i := 1
			until i > Result.count - 1
			loop
				if Result [i] = '^' then
					l_start := i
					from l_end := i + 1
					until l_end > Result.count or else Result [l_end] = '^' or else Result [l_end].is_space
					loop l_end := l_end + 1 end
					if l_end <= Result.count and then Result [l_end] = '^' then
						l_content := Result.substring (l_start + 1, l_end - 1)
						if not l_content.is_empty then
							Result.replace_substring ("<sup>" + l_content + "</sup>", l_start, l_end)
							i := l_start + 11 + l_content.count
						else
							i := i + 1
						end
					else
						i := i + 1
					end
				else
					i := i + 1
				end
			end
		end

	process_subscript (a_text: STRING): STRING
			-- Convert ~text~ to <sub> (subscript).
			-- Note: Must be careful not to conflict with ~~strikethrough~~.
		require
			text_not_void: a_text /= Void
		local
			i, l_start, l_end: INTEGER
			l_content: STRING
		do
			Result := a_text.twin

			from i := 1
			until i > Result.count - 1
			loop
				if Result [i] = '~' then
					-- Make sure it's not ~~ (strikethrough)
					if i + 1 <= Result.count and then Result [i + 1] /= '~' then
						if i = 1 or else Result [i - 1] /= '~' then
							l_start := i
							from l_end := i + 1
							until l_end > Result.count or else Result [l_end] = '~' or else Result [l_end].is_space
							loop l_end := l_end + 1 end
							if l_end <= Result.count and then Result [l_end] = '~' and then
								(l_end + 1 > Result.count or else Result [l_end + 1] /= '~') then
								l_content := Result.substring (l_start + 1, l_end - 1)
								if not l_content.is_empty then
									Result.replace_substring ("<sub>" + l_content + "</sub>", l_start, l_end)
									i := l_start + 11 + l_content.count
								else
									i := i + 1
								end
							else
								i := i + 1
							end
						else
							i := i + 1
						end
					else
						i := i + 1
					end
				else
					i := i + 1
				end
			end
		end

	process_footnote_refs (a_text: STRING): STRING
			-- Convert [^id] to footnote reference link.
		require
			text_not_void: a_text /= Void
		local
			i, l_start, l_end: INTEGER
			l_id: STRING
		do
			Result := a_text.twin

			from i := 1
			until i > Result.count - 3
			loop
				if Result [i] = '[' and then i + 1 <= Result.count and then Result [i + 1] = '^' then
					l_start := i
					from l_end := i + 2
					until l_end > Result.count or else Result [l_end] = ']'
					loop l_end := l_end + 1 end
					if l_end <= Result.count then
						-- Make sure it's not a definition (no : after ])
						if l_end + 1 > Result.count or else Result [l_end + 1] /= ':' then
							l_id := Result.substring (l_start + 2, l_end - 1)
							Result.replace_substring ("<sup><a href=%"#fn-" + l_id + "%">[" + l_id + "]</a></sup>", l_start, l_end)
							i := l_start + 30 + l_id.count * 2
						else
							i := i + 1
						end
					else
						i := i + 1
					end
				else
					i := i + 1
				end
			end
		end

note
	copyright: "Copyright (c) 2024-2025, Larry Rix"
	license: "MIT License"

end
