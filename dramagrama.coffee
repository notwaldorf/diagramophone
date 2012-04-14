class Controller
	makeItGo: (inputText, paper)->
		@parser = new Parser
		return unless inputText

		parsedLines = @parser.parse inputText
		return unless parsedLines

		# create a map that holds all the children of each block
		# we need this so that we can properly space them
		allTheBlockPairs = {}

		for blockPair in parsedLines
			if allTheBlockPairs[blockPair.first]
				allTheBlockPairs[blockPair.first].push blockPair
			else
				allTheBlockPairs[blockPair.first] = [blockPair]

		@drawer = new Drawer
		startPoint = new Point 50, 10;

		# keep track of all the blocks that we've drawn
		# so that we can link blocks even if they haven't
		# been typed in order
		blocksThatIHaveDrawn = {}
		console.log(allTheBlockPairs)
	
		for parent, children of allTheBlockPairs
			# if i've drawn this block before, start from that rectangle
			if blocksThatIHaveDrawn[parent]
				parentBlock = blocksThatIHaveDrawn[parent]
			else
				parentBlock = @drawer.drawRectangle(paper, startPoint, parent)
				startPoint.x += @drawer.rectangleWidth + 20
				blocksThatIHaveDrawn[parent] = parentBlock

			for child in children	# note, this is in parsed input first/last/message format
				childBlock = @drawer.connectToRectangle(paper, parentBlock, "down", child.second, child.message)
				blocksThatIHaveDrawn[child.second] = childBlock
		return null
class Parser
	constructor: ->
		# first -> second : message
		@basicExpression = ///
		  (.*)->(.*):(.*)
		///

	parse: (text) ->
		allTheLines = text.split("\n")
		parsedLines = []

		# TODO: try to use things = (x for x in list) instead
		for line in allTheLines	
			try 
				[first, second, message] = line.match(@basicExpression)[1..3]
				parsedLines.push {first: first.trim(), second:second.trim(), message:message.trim()}	
			catch e

		return parsedLines

		
class Drawer
	constructor: ->
		@rectangleWidth = 100
		@rectangleHeight = 50
		@rectanglePadding = 40

	drawRectangle: (paper, point, text) ->
		paper.rect(point.x, point.y, @rectangleWidth, @rectangleHeight).attr({"fill":"white"})
		@drawText(paper, point.x + @rectangleWidth/2, point.y + @rectangleHeight/2, text)	
		clonedPoint = new Point point.x,point.y
		return new Rectangle clonedPoint, @rectangleWidth, @rectangleHeight

	drawText: (paper, x, y, text) ->
		paper.text(x, y, text).attr(
			{"font-size": "13px", 
			"font-family":"'Shadows Into Light Two', sans-serif"
			}
			)

	connectToRectangle:(paper, previousRectangle, direction, text, arrowMessage) ->
		x = previousRectangle.top.x
		y = previousRectangle.top.y + @rectangleHeight + @rectanglePadding
		topPoint = new Point x, y
		thisRectangle = @drawRectangle paper, topPoint, text

		connector = previousRectangle.getConnectorForDirection direction
		myConnector = thisRectangle.getConnectorForDirection "up"

		@drawLine paper, connector, myConnector
		return thisRectangle

	drawLine: (paper, point1, point2) ->
		paper.path("M{0},{1}L{2},{3}", point1.x, point1.y, point2.x, point2.y)

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