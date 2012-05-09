class window.Drawer
	constructor: (@paper) ->
		@paper.clear()
		@rectangleWidth = 100
		@rectangleMaxWidth = 100
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

	drawText: (x, y, content) ->
		maxWidth = @rectangleWidth
		t = @paper.text(x, y).attr(
			{"font-size": "13px", 
			"font-family":"'Shadows Into Light Two', sans-serif",
			"text-anchor": "center"
			})

		# thanks stack overflow
		words = content.split(" ")
		tempText = ""
		for word in words
			t.attr("text", tempText + " " + word)
			if (t.getBBox().width > maxWidth) 
				tempText += "\n" + word
			else 
				tempText += " " + word

		t.attr("text", tempText.substring(1))
		  
		

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

class window.Rectangle
	constructor: (@top, @width, @height) ->

	getConnectorForDirection: (direction) ->
		switch direction
			when "up" 		then return new Point @top.x+(@width/2), @top.y
			when "down"		then return new Point @top.x+(@width/2), @top.y+@height
			when "left" 	then return new Point @top.x, 			@top.y+(@height/2)
			when "right" 	then return new Point @top.x+@width, 	@top.y+(@height/2)

class window.Point
	constructor: (@x, @y) ->

		