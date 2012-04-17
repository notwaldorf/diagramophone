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

test "has solid line", ->
	equal true, @monkey.hasSolidLine("a -> b : c")

test "no solid line", ->
	equal false, @monkey.hasSolidLine("a ..> b : c")

test "has dashed line", ->
	equal true, @monkey.hasDashedLine("a ..>b : c")

test "no dashed line", ->
	equal false, @monkey.hasDashedLine("a -> b : c")

module "invalid syntax",
	setup: -> 
		@monkey = new Parser()

test "standalone: a  b", ->
	parsedBit = @monkey.parseLine("a b")
	equal parsedBit.arrow, ""
	equal parsedBit.message, ""
	equal parsedBit.first.name, "a b"
	equal parsedBit.first.colour, ""
	equal parsedBit.second.name, ""
	equal parsedBit.second.colour, ""

test "standalone with colour: a  b {red}", ->
	parsedBit = @monkey.parseLine("a b {red}")
	equal parsedBit.arrow, ""
	equal parsedBit.message, ""
	equal parsedBit.first.name, "a b"
	equal parsedBit.first.colour, "red"
	equal parsedBit.second.name, ""
	equal parsedBit.second.colour, ""

module "-> syntax",
	setup: -> 
		@monkey = new Parser()

test "message missing: a -> b", ->
	parsedBit = @monkey.parseLine("a -> b")
	equal parsedBit.arrow, ""
	equal parsedBit.message, ""
	equal parsedBit.first.name, "a"
	equal parsedBit.first.colour, ""
	equal parsedBit.second.name, "b"
	equal parsedBit.second.colour, ""

test "color on first, message missing: a {red} -> b", ->
	parsedBit = @monkey.parseLine("a {red} -> b")
	equal parsedBit.arrow, ""
	equal parsedBit.message, ""
	equal parsedBit.first.name, "a"
	equal parsedBit.first.colour, "red"
	equal parsedBit.second.name, "b"
	equal parsedBit.second.colour, ""

test "color on second, message missing: a -> b {red}", ->
	parsedBit = @monkey.parseLine("a -> b {red}")
	equal parsedBit.arrow, ""
	equal parsedBit.message, ""
	equal parsedBit.first.name, "a"
	equal parsedBit.first.colour, ""
	equal parsedBit.second.name, "b"
	equal parsedBit.second.colour, "red"

test "color on both, message missing: a {blue} -> b {red}", ->
	parsedBit = @monkey.parseLine("a {blue} -> b {red}")
	equal parsedBit.arrow, ""
	equal parsedBit.message, ""
	equal parsedBit.first.name, "a"
	equal parsedBit.first.colour, "blue"
	equal parsedBit.second.name, "b"
	equal parsedBit.second.colour, "red"

test "with message: a -> b : c", ->
	parsedBit = @monkey.parseLine("a -> b : c")
	equal parsedBit.arrow, ""
	equal parsedBit.message, "c"
	equal parsedBit.first.name, "a"
	equal parsedBit.first.colour, ""
	equal parsedBit.second.name, "b"
	equal parsedBit.second.colour, ""

test "color on first, with message: a {red} -> b : c", ->
	parsedBit = @monkey.parseLine("a {red} -> b : c")
	equal parsedBit.arrow, ""
	equal parsedBit.message, "c"
	equal parsedBit.first.name, "a"
	equal parsedBit.first.colour, "red"
	equal parsedBit.second.name, "b"
	equal parsedBit.second.colour, ""

test "color on second, with message: a -> b {red} : c", ->
	parsedBit = @monkey.parseLine("a -> b {red} : c")
	equal parsedBit.arrow, ""
	equal parsedBit.message, "c"
	equal parsedBit.first.name, "a"
	equal parsedBit.first.colour, ""
	equal parsedBit.second.name, "b"
	equal parsedBit.second.colour, "red"

test "color on both, with message: a {blue} -> b {red} : c", ->
	parsedBit = @monkey.parseLine("a {blue} -> b {red} : c")
	equal parsedBit.arrow, ""
	equal parsedBit.message, "c"
	equal parsedBit.first.name, "a"
	equal parsedBit.first.colour, "blue"
	equal parsedBit.second.name, "b"
	equal parsedBit.second.colour, "red"


module "..> syntax"
	setup: -> 
		@monkey = new Parser()

test "message missing: a ..> b", ->
	parsedBit = @monkey.parseLine("a ..> b")
	equal parsedBit.arrow, "--"
	equal parsedBit.message, ""
	equal parsedBit.first.name, "a"
	equal parsedBit.first.colour, ""
	equal parsedBit.second.name, "b"
	equal parsedBit.second.colour, ""

test "color on first, message missing: a {red} ..> b", ->
	parsedBit = @monkey.parseLine("a {red} ..> b")
	equal parsedBit.arrow, "--"
	equal parsedBit.message, ""
	equal parsedBit.first.name, "a"
	equal parsedBit.first.colour, "red"
	equal parsedBit.second.name, "b"
	equal parsedBit.second.colour, ""

test "color on second, message missing: a ..> b {red}", ->
	parsedBit = @monkey.parseLine("a ..> b {red}")
	equal parsedBit.arrow, "--"
	equal parsedBit.message, ""
	equal parsedBit.first.name, "a"
	equal parsedBit.first.colour, ""
	equal parsedBit.second.name, "b"
	equal parsedBit.second.colour, "red"

test "color on both, message missing: a {blue} ..> b {red}", ->
	parsedBit = @monkey.parseLine("a {blue} ..> b {red}")
	equal parsedBit.arrow, "--"
	equal parsedBit.message, ""
	equal parsedBit.first.name, "a"
	equal parsedBit.first.colour, "blue"
	equal parsedBit.second.name, "b"
	equal parsedBit.second.colour, "red"

test "with message: a ..> b : c", ->
	parsedBit = @monkey.parseLine("a ..> b : c")
	equal parsedBit.arrow, "--"
	equal parsedBit.message, "c"
	equal parsedBit.first.name, "a"
	equal parsedBit.first.colour, ""
	equal parsedBit.second.name, "b"
	equal parsedBit.second.colour, ""

test "color on first, with message: a {red} ..> b : c", ->
	parsedBit = @monkey.parseLine("a {red} ..> b : c")
	equal parsedBit.arrow, "--"
	equal parsedBit.message, "c"
	equal parsedBit.first.name, "a"
	equal parsedBit.first.colour, "red"
	equal parsedBit.second.name, "b"
	equal parsedBit.second.colour, ""

test "color on second, with message: a ..> b {red} : c", ->
	parsedBit = @monkey.parseLine("a ..> b {red} : c")
	equal parsedBit.arrow, "--"
	equal parsedBit.message, "c"
	equal parsedBit.first.name, "a"
	equal parsedBit.first.colour, ""
	equal parsedBit.second.name, "b"
	equal parsedBit.second.colour, "red"

test "color on both, with message: a {blue} ..> b {red} : c", ->
	parsedBit = @monkey.parseLine("a {blue} ..> b {red} : c")
	equal parsedBit.arrow, "--"
	equal parsedBit.message, "c"
	equal parsedBit.first.name, "a"
	equal parsedBit.first.colour, "blue"
	equal parsedBit.second.name, "b"
	equal parsedBit.second.colour, "red"

