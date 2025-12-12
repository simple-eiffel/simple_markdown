note
	description: "Test application for simple_markdown"
	author: "Larry Rix"

class
	MARKDOWN_TEST_APP

create
	make

feature {NONE} -- Initialization

	make
			-- Run tests.
		do
			print ("simple_markdown test runner%N")
			print ("Run tests via EiffelStudio AutoTest%N")
		end

end
