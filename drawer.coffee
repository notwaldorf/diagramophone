class window.Drawer
	constructor: (@paper) ->
		@paper.clear()

		# standard rectangle sizes
		@rectangleWidth = 100
		@rectangleMaxWidth = 200
		@rectangleHeight = 50
		@rectangleTextPadding = 20

		# padding between children blocks
		@childrenVerticalPadding = 40
		@childrenHorizontalPadding = 20

		@whereTheRightMostBlockEnds = 0

		# paper sizes
		@paperWidth = 600
		@paperHeight = 400

	drawRectangle: (point, block, numChildren) ->
		if not point # so this is a rooted block we're drawing
			point = {}
			point.x = @whereTheRightMostBlockEnds + @childrenHorizontalPadding
			point.y = 10
	
		# first draw the text and the fake rectangle. we'll resize it in a bit
		# this is so that the text "sits" on top of the rectangle. otherwise it gets opaqued as well. sigh.
		fillColour = block.colour || "white"
		actualRect = @paper.rect(point.x, point.y, 10, 10)
		actualRect.attr({"fill":fillColour, "fill-opacity": "0.8", "stroke-width": 1})
		drawnText = @drawText(point.x, point.y, block.name)	

		newBlockWidth = drawnText.textWidth + @rectangleTextPadding
		newBlockHeight = drawnText.textHeight

		# based on that, resize the rectangle
		actualRect.attr(
			{"width":newBlockWidth, 
			"height":newBlockHeight
			})
		
		# now, update the starting point for the next rooted block
		# = max (where it was, where this block ends)
		whereThisBlockEndsX = point.x + newBlockWidth
		whereThisBlockEndsY = point.y + newBlockHeight
		@whereTheRightMostBlockEnds = Math.max(@whereTheRightMostBlockEnds, whereThisBlockEndsX)		

		# resize the page to fit this
		@paperWidth = Math.max(@paperWidth, @whereTheRightMostBlockEnds)
		@paperHeight = Math.max(@paperHeight, whereThisBlockEndsY + @childrenVerticalPadding)
		@paper.setSize(@paperWidth, @paperHeight)

		# and now return this beast for safe keeps
		clonedPoint = new Point point.x,point.y
		newRect = new Rectangle clonedPoint, newBlockWidth, newBlockHeight
		return {rectangle:newRect, svg:actualRect, text:drawnText.t }

	drawText: (topX, topY, content) ->
		t = @paper.text(topX, topY).attr(
			{"font-size": "13px", 
			"font-family":"'Shadows Into Light Two', sans-serif",
			"text-anchor": "middle"
			})
		t.attr("text", content)

		textWidth = Math.max(t.getBBox().width, @rectangleWidth)
		textHeight = Math.max(t.getBBox().height, @rectangleHeight)

		# if it doesn't fit in amax width box, split it into words and wrap them around
		if (textWidth > @rectangleMaxWidth)
			t.attr("text", "")
			words = content.split(" ")
			tempText = ""
			for word in words
				t.attr("text", tempText + " " + word)
				if (t.getBBox().width > @rectangleWidth) 
					tempText += "\n" + word
				else 
					tempText += " " + word

			t.attr("text", tempText.substring(1))

			# even though we split at @rectangleWidth, we could've had a massive word
			# so that one stil has to fit in the box
			textWidth = Math.max(t.getBBox().width, @rectangleWidth)
			textHeight = Math.max(t.getBBox().height, @rectangleHeight)

		# we know we're going to put this on a rectangle of that size, so let's center the text in it
		t.attr(
			{"x": topX + (textWidth+@rectangleTextPadding)/2, 
			"y": topY + textHeight/2
			})
		return {t, textWidth, textHeight}		  
		

	drawAndConnectToBlock:(previousBlock, block, previousChildEndX, direction, arrow) ->
		debugger
		previousRectangle = previousBlock.rectangle

		x = previousRectangle.top.x + previousChildEndX
		y = previousRectangle.top.y + previousRectangle.height + @childrenVerticalPadding
		topPoint = new Point x, y

		drawn = @drawRectangle topPoint, block, 0

		# arrow
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

	repositionBlock: (block, newX) ->
		block.svg.attr("x" : newX)
		block.text.attr("x" : newX)

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

