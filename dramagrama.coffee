class Controller
	makeItGo: (inputText, paper)->
		@blocksThatIHaveDrawn = {}
		@parser = new Parser
		return unless inputText
		
		blockTree = @parser.parse inputText
		return unless blockTree

		@drawer = new Drawer(paper)
		@drawBlocks(blockTree)
	
	drawBlocks: (blockTree) ->
		@drawRootedBlock block for block in blockTree.children when block

	drawRootedBlock: (block) ->
		numActualChildren = @getNumLinkedChildren block.children

		# if i've drawn this block before, start from that rectangle
		parentBlock = @blocksThatIHaveDrawn[block.name]
		if !parentBlock
			parentBlock = @drawer.drawRectangle(null, block, numActualChildren)
			@blocksThatIHaveDrawn[block.name] = parentBlock

		# draw all the connecting children
		i = 0
		for child in block.children
			continue unless child
			childBlock = @blocksThatIHaveDrawn[child.name]
			# has this child been drawn? if so, let's connect to it
			if childBlock
				@drawer.connectExistingBlocks(parentBlock, childBlock, "down", child.arrow )
			else
				childBlock = @drawer.drawAndConnectToBlock(parentBlock, child, i, "down", child.arrow)
				@blocksThatIHaveDrawn[child.name] = childBlock
				@drawRootedBlock child
				i++

	# get the number of non-standalone children
	getNumLinkedChildren: (lines) ->
		total = 0
		(total = total + 1) for line in lines when line
		return total

class Parser
	constructor: ->

	parse: (text) ->
		allTheLines = text.split("\n")
		parsedBits = []

		# <3 coffescript
		parsedBits.push(@parseLine line) for line in allTheLines;

		return @parseTree parsedBits

	parseTree: (parsedBits) ->
		tree = {children: []}
		
		for bit in parsedBits
			continue unless bit
			aname = bit.first.name
			bname = bit.second.name

			a = @findNodeInTree aname, tree;
			b = @findNodeInTree bname, tree;

			# do we need to add the parent block to the tree?
			if !a
				a = {name: aname, colour: "", children:[]}
				tree.children.push a

			# don't panic about self loops
			continue if aname == bname

			# if b doesn't exist, it's easy. just add it and be done
			if !b and bname != ""
				b = {name: bname, colour: "", children:[]}
				a.children.push b
			else if b
				a.children.push b
				# dislodge the first level node if needed
				if @isFirstLevelNode b, tree
					# TODO: this is pretty crappy
					tree.children[tree.children.indexOf(b)] = null

			# if the colours or arrow have updated, save them
			if a
				a.colour = bit.first.colour if bit.first.colour
			if b
				b.colour = bit.second.colour if bit.second.colour
				b.arrow = bit.arrow if bit.arrow

		return tree

	findNodeInTree: (findMe, tree) ->
		return tree if tree.name is findMe
		
		# maybe it's one of the children?
		for child in tree.children
			continue if !child
			return child if child.name is findMe

			# maybe it's a grand child?
			maybeInChild = @findNodeInTree findMe, child
			return maybeInChild if maybeInChild

		return null
			
	isFirstLevelNode: (node, tree) ->
		for child in tree.children
			return true if child and child.name == node.name
		
		return false

	parseLine: (text) ->
		return unless text # hey there paranoia
		parsedBit = {}
		parsedBit.first = {name: "", colour: ""}
		parsedBit.second = {name: "", colour: ""}
		parsedBit.arrow = {message:"", type: "", headLeft:"", headRight: ""}

		# parse the message
		line = text
		if @hasMessage text
			lineAndMsg = @extractLineAndMessage text
			line = lineAndMsg.line
			parsedBit.arrow.message = lineAndMsg.message

		return unless line

		return if @hasComment line
		
		# parse the names
		namesAndArrow = @extractNamesAndArrow line
		
		# if this is null, we have a standalone block
		if !namesAndArrow
			parsedBit.first.name = line
		else		
			parsedBit.first.name = namesAndArrow.names.first
			parsedBit.second.name = namesAndArrow.names.second
			parsedBit.arrow.type = namesAndArrow.arrow.type
			parsedBit.arrow.headLeft = namesAndArrow.arrow.headLeft
			parsedBit.arrow.headRight = namesAndArrow.arrow.headRight
			parsedBit.arrow.direction = namesAndArrow.arrow.direction

		# parse the colours	
		if @hasColour parsedBit.first.name
			namesAndCol = @extractNameAndColour parsedBit.first.name
			parsedBit.first.name = namesAndCol.name
			parsedBit.first.colour = namesAndCol.colour
		if @hasColour parsedBit.second.name
			namesAndCol = @extractNameAndColour parsedBit.second.name
			parsedBit.second.name = namesAndCol.name
			parsedBit.second.colour = namesAndCol.colour

		return parsedBit

	hasMessage: (text) ->
		return text.indexOf(":") != -1

	hasColour: (text) ->
		return text.indexOf("{") != -1 && text.indexOf("}") != -1

	hasComment: (text) ->
		return text.indexOf("//") != -1

	extractLineAndMessage: (text) ->
		# first -> second : message
		lineWithMessage = ///(.*):(.*)///
		[line, message] = text.match(lineWithMessage)[1..2]
		return {line:line.trim(), message:message.trim()}

	extractNameAndColour: (text) ->
		# name {colour}
		nameAndColour = ///(.*){(.*)}///
		[name, colour] = text.match(nameAndColour)[1..2]
		return {name:name.trim(), colour:colour.trim()}

	extractNamesAndArrow: (text) ->
		doubleArrow = ///(.*)(<>-<>|<->|<-<>|<>->|<>\.\.<>|<\.\.>|<\.\.<>|<>\.\.>)(.*)///
		singleArrow = ///(.*)(--|-\.-|->|\.\.>|-<>|\.\.<>|<-|<\.\.|<>-|<>\.\.)(.*)///
		# first try to match the double arrow. if that works, then you've hit jackpot
		# if that doesn't match, then go for the single arrow
		# if i join these in one massive regexp, sanity breaks and i'm not debugging regexps.		
		try 
			[first, arrow, second] = text.match(doubleArrow)[1..3]
		catch e1
			# didn't match a double arrow. can we match a single arrow?
			try
				[first, arrow, second] = text.match(singleArrow)[1..3]
			catch e2
				return null
		
		return {names:{first:first.trim(), second:second.trim()}, arrow:@extractArrow(arrow)}
	
	# TODO: this is still gross
	extractArrow: (text) ->
		# arrow head. this is gross
		if text[0] == "<" && text[1] == ">"
			headLeft = "diamond"
		else if text[0] == "<"
			headLeft = "classic"
		else
			headLeft = "none"
		
		if text[text.length-2] == "<" && text[text.length-1] == ">"
			headRight = "diamond"
		else if text[text.length-1] == ">"
			headRight = "classic"
		else
			headRight = "none"			
	
		# dash type
		if text.indexOf("..") != -1
			type = "-"
		else if text.indexOf("-.-") != -1 
			type = "-"
		else 
			type = ""
		
		# direction: left, right, both
		# here we're assuming that botht he diamond and the arrow end in a >
		if text[0] == "<" and text[text.length-1] == ">"
			direction = "both";
		else if text[0] == "<"
			direction = "left"
		else if text[text.length-1] == ">"
			direction = "right"
		else
			direction = ""
			
		return {direction: direction, type:type, headLeft:headLeft, headRight:headRight}	

class Drawer
	constructor: (@paper) ->
		@paper.clear()
		@rectangleWidth = 100
		@rectangleHeight = 50
		@childrenVerticalPadding = 40
		@childrenHorizontalPadding = 20
		@paperWidth = 600
		@paperHeight = 400
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

		
		# if the next point is out of the page, resize the page
		nextRectangleEndX = point.x + @rectangleWidth + @childrenHorizontalPadding
		nextRectangleEndY = point.y + @rectangleHeight + @childrenVerticalPadding

		# resize to be the optimal width and height
		@paperWidth = Math.max(@paperWidth, nextRectangleEndX)
		@paperHeight = Math.max(@paperHeight,nextRectangleEndY)
		@paper.setSize(@paperWidth, @paperHeight)


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

	drawAndConnectToBlock:(previousBlock, block, childIndex, direction, arrow) ->
		previousRectangle = previousBlock.rectangle # block also contains the svg, just in case
		x = childIndex * (@rectangleWidth + @childrenHorizontalPadding) + previousRectangle.top.x
		y = previousRectangle.top.y + @rectangleHeight + @childrenVerticalPadding
		topPoint = new Point x, y

		drawn = @drawRectangle topPoint, block, 0

		connector = previousRectangle.getConnectorForDirection direction
		myConnector = drawn.rectangle.getConnectorForDirection "up"

		@drawLine connector, myConnector, arrow
		return drawn
		
	connectExistingBlocks:(block1, block2, direction, arrow) ->
		connector1 = block1.rectangle.getConnectorForDirection direction
		connector2 = block2.rectangle.getConnectorForDirection "up"

		@drawLine connector1, connector2, arrow

	drawLine: (point1, point2, arrow) ->
		# arrow.direction gives left/right/both. if both, you need to draw both paths
		if (arrow.direction == "" )
			@drawPath(point1, point2, arrow.headRight, arrow.type)
		if (arrow.direction == "right" || arrow.direction == "both")
			@drawPath(point1, point2, arrow.headRight, arrow.type)
		if (arrow.direction == "left" || arrow.direction == "both")
			@drawPath(point2, point1, arrow.headLeft, arrow.type)
			
		return unless arrow.message

		y_mid = point1.y + 20 #point1.y + (point2.y - point1.y)/2
		x_mid = point1.x + 5 #(point2.x - point1.x)/2 + 5
		@paper.text(x_mid, y_mid, arrow.message).attr(
			{"font-size": "12px", 
			"font-family":"'Shadows Into Light Two', sans-serif",
			"text-anchor":"start"})
			
	drawPath: (point1, point2, head, dash) ->
		@paper.path("M{0},{1}L{2},{3}", point1.x, point1.y, point2.x, point2.y)
		.attr({"stroke-dasharray": dash, "stroke-width": 2, "arrow-end":head + "-wide-long"})

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