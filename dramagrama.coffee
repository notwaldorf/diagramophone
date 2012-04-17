class Controller
	makeItGo: (inputText, paper)->
		@parser = new Parser
		return unless inputText

		parsedBits = @parser.parse inputText
		return unless parsedBits

		@drawer = new Drawer(paper)

		@drawBlocks(parsedBits)

	# create a map that holds all the children of each block
	# we need this so that we can properly space them
	getAllBlockPairs: (parsedBits) ->
		allTheBlockPairs = {}

		for bit in parsedBits
			if bit
				if allTheBlockPairs[bit.first.name]
					allTheBlockPairs[bit.first.name].push bit
				else
					allTheBlockPairs[bit.first.name] = [bit]

		return allTheBlockPairs


	drawBlocks: (parsedBits) ->
		blockLinesByParent = @getAllBlockPairs parsedBits
	
		# keep track of all the blocks that we've drawn
		# so that we can link blocks even if they haven't
		# been typed in order
		blocksThatIHaveDrawn = {}

		for parentName, lines of blockLinesByParent
			# if i've drawn this block before, start from that rectangle
			parentBlock = @getOrDrawParentBlock parentName, lines[0].first, blocksThatIHaveDrawn, lines.length

			# draw all the connecting children
			i = 0
			for line in lines
				# the parent may be a standalone block and not have any children	
				if line.second.name != ""
					childBlock = @drawer.connectToRectangle(parentBlock, line.second, i, "down", line.arrow, line.message)
					blocksThatIHaveDrawn[line.second.name] = childBlock
					i++
		return null

	getOrDrawParentBlock: (parentName, lineBlock, blocksThatIHaveDrawn, numChildren) ->
		block = blocksThatIHaveDrawn[parentName]

		if block
			# we may have to update the colour
			if (lineBlock.colour)
				block.svg.attr("fill":lineBlock.colour)
			return block
		else
			newBlock = @drawer.drawRectangle(null, lineBlock, numChildren)
			blocksThatIHaveDrawn[parentName] = newBlock;
			return newBlock


class Parser
	constructor: ->

	parse: (text) ->
		allTheLines = text.split("\n")
		parsedBits = []

		# <3 coffescript
		parsedBits.push(@parseLine line) for line in allTheLines;

		return parsedBits

	parseLine: (text) ->
		return unless text # hey there paranoia
		parsedBit = {}
		parsedBit.message = ""
		parsedBit.first = {name: "", colour: ""}
		parsedBit.second = {name: "", colour: ""}
		parsedBit.arrow = ""

		# parse the message
		line = text
		if @hasMessage text
			lineAndMsg = @extractLineAndMessage text
			line = lineAndMsg.line
			parsedBit.message = lineAndMsg.message

		return unless line

		return if @hasComment line
		# parse the names
		names = null
		if @hasSolidLine line
			parsedBit.arrow = ""
			names = @extractNamesFromSolidLine line
		else if @hasDashedLine line
			parsedBit.arrow = "--"	
			names = @extractNamesFromDashedLine line
		else
			names = {first:line, second:""}

		return unless names

		parsedBit.first.name = names.first
		parsedBit.second.name = names.second

		# first
		if @hasColour names.first
			namesAndCol = @extractNameAndColour names.first
			parsedBit.first.name = namesAndCol.name
			parsedBit.first.colour = namesAndCol.colour

		# second
		if @hasColour names.second
			namesAndCol = @extractNameAndColour names.second
			parsedBit.second.name = namesAndCol.name
			parsedBit.second.colour = namesAndCol.colour

		return parsedBit

	hasMessage: (text) ->
		return text.indexOf(":") != -1

	hasColour: (text) ->
		return text.indexOf("{") != -1 && text.indexOf("}") != -1

	hasSolidLine: (text) ->
		return text.indexOf("->") != -1

	hasDashedLine: (text) ->
		return text.indexOf("..>") != -1

	hasComment: (text) ->
		return text.indexOf("//") != -1

	extractLineAndMessage: (text) ->
		# first -> second : message
		@lineWithMessage = ///(.*):(.*)///
		[line, message] = text.match(@lineWithMessage)[1..2]
		return {line:line.trim(), message:message.trim()}

	extractNameAndColour: (text) ->
		# name {colour}
		@nameAndColour = ///(.*){(.*)}///
		[name, colour] = text.match(@nameAndColour)[1..2]
		return {name:name.trim(), colour:colour.trim()}

	extractNamesFromSolidLine: (text) ->
		# a -> b
		@namesLineName = ///(.*)->(.*)///
		[first, second] = text.match(@namesLineName)[1..2]
		return {first:first.trim(), second:second.trim()}

	extractNamesFromDashedLine: (text) ->
		# a --> b
		@namesLineName = ///(.*)..>(.*)///
		[first, second] = text.match(@namesLineName)[1..2]
		return {first:first.trim(), second:second.trim()}

	


class Drawer
	constructor: (@paper) ->
		@paper.clear()
		@rectangleWidth = 100
		@rectangleHeight = 50
		@rectanglePadding = 40
		@childrenHorizontalPadding = 20
		@startPoint = new Point 10, 10;

	drawRectangle: (point, block, numChildren) ->
		if not point
			# whatever the original point, we need to center the square above the children
			# which hold a width of n * (@rectangleWidth + @childrenHorizontalPadding)
			# the center will be half way, and our start point will be @rectangleWidth/2 before that
			childrenWidth = numChildren * @rectangleWidth + (numChildren-1) * @childrenHorizontalPadding
			cornerStart = childrenWidth / 2 - @rectangleWidth/2
			point = {}
			point.x = @startPoint.x #+ cornerStart
			point.y = @startPoint.y
			# we start the next row either the padding away from the children, or the padding away from this block
			@startPoint.x += Math.max(@rectangleWidth, childrenWidth) + @childrenHorizontalPadding

		fillColour = block.colour || "white"
		actualRect = @paper.rect(point.x, point.y, @rectangleWidth, @rectangleHeight).attr({"fill":fillColour, "fill-opacity": "0.8"})
		@drawText(point.x + @rectangleWidth/2, point.y + @rectangleHeight/2, block.name)	
		clonedPoint = new Point point.x,point.y

		newRect = new Rectangle clonedPoint, @rectangleWidth, @rectangleHeight

		return {rectangle:newRect, svg:actualRect}

	drawText: (x, y, text) ->
		@paper.text(x, y, text).attr(
			{"font-size": "13px", 
			"font-family":"'Shadows Into Light Two', sans-serif"
			})

	connectToRectangle:(previousBlock, block, childIndex, direction, arrowStyle, arrowMsg) ->
		previousRectangle = previousBlock.rectangle # block also contains the svg, just in case
		x = childIndex * (@rectangleWidth + @childrenHorizontalPadding) + previousRectangle.top.x
		y = previousRectangle.top.y + @rectangleHeight + @rectanglePadding
		topPoint = new Point x, y

		drawn = @drawRectangle topPoint, block, 0

		connector = previousRectangle.getConnectorForDirection direction
		myConnector = drawn.rectangle.getConnectorForDirection "up"

		@drawLine connector, myConnector, arrowMsg, arrowStyle
		return drawn

	drawLine: (point1, point2, arrowMessage, arrowStyle) ->
		@paper.path("M{0},{1}L{2},{3}", point1.x, point1.y, point2.x, point2.y)
		.attr({"stroke-dasharray": arrowStyle})

		return unless arrowMessage
		midpoint = point1.y + (point2.y - point1.y)/2
		@paper.text(point1.x + 5, midpoint, arrowMessage).attr(
			{"font-size": "12px", 
			"font-family":"'Shadows Into Light Two', sans-serif",
			"text-anchor":"start"})

		# stroke: "red"

class Rectangle
	constructor: (@top, @width, @height) ->

	getConnectorForDirection: (direction) ->
		switch direction
			when "up" 		then return new Point @top.x+(@width/2), @top.y
			when "down"		then return new Point @top.x+(@width/2), @top.y+@height
			when "left" 	then return new Point @top.x, 			@top.y+(@height/2)
			when "right" 	then return new Point @top.x+@width, 	@top.y+(@height/2)

class Point
	constructor: (@x, @y) ->


# export ALL the things
window.Controller = Controller
window.Parser = Parser
window.Drawer = Drawer
window.Rectangle = Rectangle
window.Point = Point