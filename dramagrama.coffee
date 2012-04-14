class Controller
	makeItGo: (inputText, paper)->
		@parser = new Parser
		return unless inputText

		parsedText = @parser.parse inputText
		return unless parsedText
		
		@drawer = new Drawer
		startPoint = new Point 100, 10;

		block1 = @drawer.drawRectangle(paper, startPoint, parsedText.first)
		block2 = @drawer.connectToRectangle(paper, block1, "down", parsedText.second, parsedText.message)
		
class Parser
	parse: (text) ->
		# first -> second : message
		basicBlock = ///
		  (.*)->(.*):(.*)
		/// 
		try 
			[first, second, message] = text.match(basicBlock)[1..3]
			return {first: first.trim(), second:second.trim(), message:message.trim()}	
		catch e
			return null
		

class Drawer
	constructor: ->
		@rectangleWidth = 100
		@rectangleHeight = 50
		@rectanglePadding = 40

	drawRectangle: (paper, point, text) ->
		paper.rect(point.x, point.y, @rectangleWidth, @rectangleHeight).attr({"fill":"white"})
		@drawText(paper, point.x + @rectangleWidth/2, point.y + @rectangleHeight/2, text)	
		return new Rectangle point, @rectangleWidth, @rectangleHeight

	drawText: (paper, x, y, text) ->
		paper.text(x, y, text).attr(
			{"font-size": "13px", 
			"font-family":"'Shadows Into Light Two', sans-serif"}
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