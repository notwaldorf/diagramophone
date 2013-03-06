class window.Drawer

	##############################
	#	Initialize ALL the things
	##############################

	constructor: (@paper) ->
		@paper.clear()

		# where to start drawing
		@startPoint = new Point 10, 10
		
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

		# customizable settings
		@textFontName = "Shadows Into Light Two"
		@textFontSize = "15px"


	#################################
	#	Positioning things correctly
	#################################
	drawUnpositionedBlock: (block) ->
		point = {}
		point.x = 0
		point.y = 0

		# first draw the text and the fake rectangle. we'll resize it in a bit
		# this is so that the text "sits" on top of the rectangle. otherwise it gets opaqued as well. sigh.
		fillColour = block.colour || "white"
		actualRect = @paper.rect(point.x, point.y, 10, 10)
		actualRect.attr({"fill":fillColour, "fill-opacity": "0.8", "stroke-width": 1})
		drawnText = @drawAndWrapText(point.x, point.y, block.name)	

		newBlockWidth = drawnText.textWidth + @rectangleTextPadding
		newBlockHeight = drawnText.textHeight

		# based on that, resize the rectangle
		actualRect.attr(
			{"width":newBlockWidth, 
			"height":newBlockHeight
			})
		
		# and now return this beast for safe keeps
		block.width = newBlockWidth
		block.height = newBlockHeight
		block.textHeight = drawnText.textHeight
		block.textWidth = drawnText.textWidth
		block.drawn = {rect: actualRect, text:drawnText.t}

	positionBlock: (block, where) ->
		block.drawn.rect.attr(
			{"x":where.x, 
			"y":where.y
			})
		block.top = where
		@positionText(block.drawn.text, block.textWidth, block.textHeight, where)

		# resize the page to fit this
		whereThisBlockEndsX = where.x + block.width
		whereThisBlockEndsY = where.y + block.height
		@whereTheRightMostBlockEnds = Math.max(@whereTheRightMostBlockEnds, whereThisBlockEndsX)		

		@paperWidth = Math.max(@paperWidth, @whereTheRightMostBlockEnds + @childrenHorizontalPadding)
		@paperHeight = Math.max(@paperHeight, whereThisBlockEndsY + @childrenVerticalPadding)
		@paper.setSize(@paperWidth, @paperHeight)
		
	positionText: (textObj, textWidth, textHeight, blockTopPoint) ->
		textObj.attr(
			{"x": blockTopPoint.x + (textWidth+@rectangleTextPadding)/2, 
			"y": blockTopPoint.y + textHeight/2
			})

	##############################
	#	Drawing Basic Shapes
	##############################
	drawAndWrapText: (topX, topY, content) ->
		t = @paper.text(topX, topY).attr(
			{"font-size": @textFontSize, 
			"font-family": @textFontName + ", sans-serif",
			"text-anchor": "middle"
			})
		t.attr("text", content)

		textWidth = Math.max(t.getBBox().width, @rectangleWidth)
		textHeight = Math.max(t.getBBox().height, @rectangleHeight)

		# if it doesn't fit in a max width box, split it into words and wrap them around
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

		# we know we're going to put this on a rectangle of that size (+padding), so let's center the text in it
		@positionText(t, textWidth, textHeight, new Point(topX, topY))
		return {t, textWidth, textHeight}		  

	connectExistingBlocks:(parent, child, direction, arrow) ->
		parentRectangle = new Rectangle parent.top, parent.width, parent.height
		childRectangle = new Rectangle child.top, child.width, child.height

		# if the parent is physically above the child, then parent.top.y > child.top.y
		# if this isn't the case, then we need to connect the parent top to the child bottom
		if (parent.top.y <= child.top.y)
			parentConnectorHook = parentRectangle.getConnectorForDirection direction
			childConnectorHook = childRectangle.getConnectorForDirection "up"
		else 
			parentConnectorHook = parentRectangle.getConnectorForDirection "up"
			childConnectorHook = childRectangle.getConnectorForDirection "down"

		@drawLine parentConnectorHook, childConnectorHook, arrow

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
			{"font-size": @textFontSize, 
			"font-family": @textFontName + ", sans-serif",
			"text-anchor":"start"})
			
	drawPath: (point1, point2, head, dash) ->
		@paper.path("M{0},{1}L{2},{3}", point1.x, point1.y, point2.x, point2.y)
		.attr({"stroke-dasharray": dash, "stroke-width": 2, "arrow-end":head + "-wide-long"})

##############################
#	Classes that want to help
##############################

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

	clone: (otherPoint) ->
		newPoint = new Point(otherPoint.x, otherPoint.y)

