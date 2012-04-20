module "utils",
	setup: -> 
		@monkey = new Parser()

test "yes message", ->
	equal true, @monkey.hasMessage("a -> b : c")

test "no message", ->
	equal false, @monkey.hasMessage("a -> b")

test "has colour", ->
	equal true, @monkey.hasColour("a {red} -> b")

test "has colour", ->
	equal true, @monkey.hasColour("a -> b {red}")

test "has colour", ->
	equal true, @monkey.hasColour("a {red} -> b{red}")

test "no colour", ->
	equal false, @monkey.hasColour("a -> b : c")

module "weird syntax",
	setup: -> 
		@monkey = new Parser()

test "standalone: a  b", ->
	parsedBit = @monkey.parseLine("a b")
	equal parsedBit.arrow.type, ""
	equal parsedBit.arrow.headRight, ""
	equal parsedBit.arrow.headLeft, ""
	equal parsedBit.arrow.message, ""
	equal parsedBit.first.name, "a b"
	equal parsedBit.first.colour, ""
	equal parsedBit.second.name, ""
	equal parsedBit.second.colour, ""

test "standalone with colour: a  b {red}", ->
	parsedBit = @monkey.parseLine("a b {red}")
	equal parsedBit.arrow.type, ""
	equal parsedBit.arrow.headRight, ""
	equal parsedBit.arrow.headLeft, ""
	equal parsedBit.arrow.message, ""
	equal parsedBit.first.name, "a b"
	equal parsedBit.first.colour, "red"
	equal parsedBit.second.name, ""
	equal parsedBit.second.colour, ""

module "parse all components, assume ->",
	setup: -> 
		@monkey = new Parser()

test "message missing: a -> b", ->
	parsedBit = @monkey.parseLine("a -> b")
	equal parsedBit.arrow.type, ""
	equal parsedBit.arrow.headRight, "classic"
	equal parsedBit.arrow.headLeft, "none"
	equal parsedBit.arrow.message, ""
	equal parsedBit.first.name, "a"
	equal parsedBit.first.colour, ""
	equal parsedBit.second.name, "b"
	equal parsedBit.second.colour, ""

test "color on first, message missing: a {red} -> b", ->
	parsedBit = @monkey.parseLine("a {red} -> b")
	equal parsedBit.arrow.type, ""
	equal parsedBit.arrow.headRight, "classic"
	equal parsedBit.arrow.headLeft, "none"
	equal parsedBit.arrow.message, ""
	equal parsedBit.first.name, "a"
	equal parsedBit.first.colour, "red"
	equal parsedBit.second.name, "b"
	equal parsedBit.second.colour, ""

test "color on second, message missing: a -> b {red}", ->
	parsedBit = @monkey.parseLine("a -> b {red}")
	equal parsedBit.arrow.type, ""
	equal parsedBit.arrow.headRight, "classic"
	equal parsedBit.arrow.headLeft, "none"
	equal parsedBit.arrow.message, ""
	equal parsedBit.first.name, "a"
	equal parsedBit.first.colour, ""
	equal parsedBit.second.name, "b"
	equal parsedBit.second.colour, "red"

test "color on both, message missing: a {blue} -> b {red}", ->
	parsedBit = @monkey.parseLine("a {blue} -> b {red}")
	equal parsedBit.arrow.type, ""
	equal parsedBit.arrow.headRight, "classic"
	equal parsedBit.arrow.headLeft, "none"
	equal parsedBit.arrow.message, ""
	equal parsedBit.first.name, "a"
	equal parsedBit.first.colour, "blue"
	equal parsedBit.second.name, "b"
	equal parsedBit.second.colour, "red"

test "with message: a -> b : c", ->
	parsedBit = @monkey.parseLine("a -> b : c")
	equal parsedBit.arrow.type, ""
	equal parsedBit.arrow.headRight, "classic"
	equal parsedBit.arrow.headLeft, "none"
	equal parsedBit.arrow.message, "c"
	equal parsedBit.first.name, "a"
	equal parsedBit.first.colour, ""
	equal parsedBit.second.name, "b"
	equal parsedBit.second.colour, ""

test "color on first, with message: a {red} -> b : c", ->
	parsedBit = @monkey.parseLine("a {red} -> b : c")
	equal parsedBit.arrow.type, ""
	equal parsedBit.arrow.headRight, "classic"
	equal parsedBit.arrow.headLeft, "none"
	equal parsedBit.arrow.message, "c"
	equal parsedBit.first.name, "a"
	equal parsedBit.first.colour, "red"
	equal parsedBit.second.name, "b"
	equal parsedBit.second.colour, ""

test "color on second, with message: a -> b {red} : c", ->
	parsedBit = @monkey.parseLine("a -> b {red} : c")
	equal parsedBit.arrow.type, ""
	equal parsedBit.arrow.headRight, "classic"
	equal parsedBit.arrow.headLeft, "none"
	equal parsedBit.arrow.message, "c"
	equal parsedBit.first.name, "a"
	equal parsedBit.first.colour, ""
	equal parsedBit.second.name, "b"
	equal parsedBit.second.colour, "red"

test "color on both, with message: a {blue} -> b {red} : c", ->
	parsedBit = @monkey.parseLine("a {blue} -> b {red} : c")
	equal parsedBit.arrow.type, ""
	equal parsedBit.arrow.headRight, "classic"
	equal parsedBit.arrow.headLeft, "none"
	equal parsedBit.arrow.message, "c"
	equal parsedBit.first.name, "a"
	equal parsedBit.first.colour, "blue"
	equal parsedBit.second.name, "b"
	equal parsedBit.second.colour, "red"

test "color on both, with message and diamond: a {blue} -<> b {red} : c", ->
	parsedBit = @monkey.parseLine("a {blue} -<> b {red} : c")
	equal parsedBit.arrow.type, ""
	equal parsedBit.arrow.headRight, "diamond"
	equal parsedBit.arrow.headLeft, "none"
	equal parsedBit.arrow.message, "c"
	equal parsedBit.first.name, "a"
	equal parsedBit.first.colour, "blue"
	equal parsedBit.second.name, "b"
	equal parsedBit.second.colour, "red"


module "parse correct arrows and directions"
	setup: -> 
		@monkey = new Parser()

# no arrow head
test "--", ->
	parsedBit = @monkey.parseLine("a -- b")
	equal parsedBit.arrow.type, ""
	equal parsedBit.arrow.headLeft, "none"
	equal parsedBit.arrow.headRight, "none"
	equal parsedBit.arrow.direction, ""

test "-.-", ->
	parsedBit = @monkey.parseLine("a -.- b")
	equal parsedBit.arrow.type, "-"
	equal parsedBit.arrow.headLeft, "none"
	equal parsedBit.arrow.headRight, "none"
	equal parsedBit.arrow.direction, ""
	
# arrow either left or right
test "->", ->
	parsedBit = @monkey.parseLine("a -> b")
	equal parsedBit.arrow.type, ""
	equal parsedBit.arrow.headRight, "classic"
	equal parsedBit.arrow.headLeft, "none"
	equal parsedBit.arrow.direction, "right"

test "<-", ->
	debugger
	parsedBit = @monkey.parseLine("a <- b")
	equal parsedBit.arrow.type, ""
	equal parsedBit.arrow.headRight, "none"
	equal parsedBit.arrow.headLeft, "classic"
	equal parsedBit.arrow.direction, "left"
	
test "..>", ->
	parsedBit = @monkey.parseLine("a ..> b")
	equal parsedBit.arrow.type, "-"
	equal parsedBit.arrow.headRight, "classic"
	equal parsedBit.arrow.headLeft, "none"
	equal parsedBit.arrow.direction, "right"

test "<..", ->
	parsedBit = @monkey.parseLine("a <.. b")
	equal parsedBit.arrow.type, "-"
	equal parsedBit.arrow.headRight, "none"
	equal parsedBit.arrow.headLeft, "classic"
	equal parsedBit.arrow.direction, "left"	
	
# diamonds either left or right
test "-<>", ->
	parsedBit = @monkey.parseLine("a -<> b")
	equal parsedBit.arrow.type, ""
	equal parsedBit.arrow.headRight, "diamond"
	equal parsedBit.arrow.headLeft, "none"
	equal parsedBit.arrow.direction, "right"

test "<>-", ->
	parsedBit = @monkey.parseLine("a <>- b")
	equal parsedBit.arrow.type, ""
	equal parsedBit.arrow.headRight, "none"
	equal parsedBit.arrow.headLeft, "diamond"
	equal parsedBit.arrow.direction, "left"
		
test "..<>", ->
	debugger
	parsedBit = @monkey.parseLine("a ..<> b")
	equal parsedBit.arrow.type, "-"
	equal parsedBit.arrow.headRight, "diamond"
	equal parsedBit.arrow.headLeft, "none"
	equal parsedBit.arrow.direction, "right"

test "<>..", ->
	parsedBit = @monkey.parseLine("a <>.. b")
	equal parsedBit.arrow.type, "-"
	equal parsedBit.arrow.headRight, "none"
	equal parsedBit.arrow.headLeft, "diamond"
	equal parsedBit.arrow.direction, "left"

# double arrows of all sorts
test "<>-<>", ->
	parsedBit = @monkey.parseLine("a <>-<> b")
	equal parsedBit.arrow.type, ""
	equal parsedBit.arrow.headRight, "diamond"
	equal parsedBit.arrow.headLeft, "diamond"
	equal parsedBit.arrow.direction, "both"
test "<->", ->
	parsedBit = @monkey.parseLine("a <-> b")
	equal parsedBit.arrow.type, ""
	equal parsedBit.arrow.headRight, "classic"
	equal parsedBit.arrow.headLeft, "classic"
	equal parsedBit.arrow.direction, "both"
test "<-<>", ->
	parsedBit = @monkey.parseLine("a <-<> b")
	equal parsedBit.arrow.type, ""
	equal parsedBit.arrow.headRight, "diamond"
	equal parsedBit.arrow.headLeft, "classic"
	equal parsedBit.arrow.direction, "both"
test "<>->", ->
	parsedBit = @monkey.parseLine("a <>-> b")
	equal parsedBit.arrow.type, ""
	equal parsedBit.arrow.headRight, "classic"
	equal parsedBit.arrow.headLeft, "diamond"
	equal parsedBit.arrow.direction, "both"
	
test "<>..<>", ->
	parsedBit = @monkey.parseLine("a <>..<> b")
	equal parsedBit.arrow.type, "-"
	equal parsedBit.arrow.headRight, "diamond"
	equal parsedBit.arrow.headLeft, "diamond"
	equal parsedBit.arrow.direction, "both"
test "<..>", ->
	parsedBit = @monkey.parseLine("a <..> b")
	equal parsedBit.arrow.type, "-"
	equal parsedBit.arrow.headRight, "classic"
	equal parsedBit.arrow.headLeft, "classic"
	equal parsedBit.arrow.direction, "both"
test "<..<>", ->
	parsedBit = @monkey.parseLine("a <..<> b")
	equal parsedBit.arrow.type, "-"
	equal parsedBit.arrow.headRight, "diamond"
	equal parsedBit.arrow.headLeft, "classic"
	equal parsedBit.arrow.direction, "both"
test "<>..>", ->
	parsedBit = @monkey.parseLine("a <>..> b")
	equal parsedBit.arrow.type, "-"
	equal parsedBit.arrow.headRight, "classic"
	equal parsedBit.arrow.headLeft, "diamond"
	equal parsedBit.arrow.direction, "both"