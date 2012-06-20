class window.Controller
	makeItGo: (inputText, paper, hasSillyFont)->
		@parser = new Parser
		@drawer = new Drawer(paper)
		return unless inputText
		
		blockTree = @parser.parse inputText
		return unless blockTree

		@applySomePropertiesOfSorts(hasSillyFont)
		
		###
		Hey! This might look insane, but isn't. here is why:
		1. draw all the blocks on the canvas, without positioning them
		    - unless you do this, you can't tell exactly what the height of each block is
		    (because the text inside it can be arbitrarily long)
		2. now that you have the heights of all the of the blocks, you can position them around
		3. now that you've positioned them around, you can draw the arrows that connect them
		###

		@blocksThatIHaveDrawn = {}	# don't want to double draw blocks
		blockTree = @drawUnpositionedBlock(blockTree)

		@blocksThatIHaveDrawn = {}	# don't want to move around already drawn children shared by parents
		@repositionBlock(blockTree, @drawer.startPoint)

		@drawConnectors(blockTree)
	
	##############################
	#	Things about drawing
	##############################
	drawUnpositionedBlock: (block) ->
		return unless block

		# don't double draw
		if block.name and @blocksThatIHaveDrawn[block.name]
			return

		#first, if you're a node, draw yourself
		drawnBlock = @drawer.drawUnpositionedBlock block if block.name
		@blocksThatIHaveDrawn[block.name] = drawnBlock

		# recursively draw all your children
		@drawUnpositionedBlock(child) for child in block.children
		
		return block

	repositionBlock: (block, point) ->
		return 0 unless block

		childY = point.y
		childX = point.x
		childY += block.height + @drawer.childrenVerticalPadding if block.height

		totalChildLength = 0

		# first draw all the children
		for child in block.children
			nextChildStart = new Point childX, childY

			childWidth = @repositionBlock(child, nextChildStart)
			totalChildLength += childWidth + @drawer.childrenHorizontalPadding
			childX = childX + childWidth + @drawer.childrenHorizontalPadding

		# need to remove the padding for the last child, if they were any
		totalChildLength -= @drawer.childrenHorizontalPadding if block.children?[0]?

		# now draw the parent, in the middle if it hasn't been drawn before
		if (block.name and !@blocksThatIHaveDrawn[block.name])
			@blocksThatIHaveDrawn[block.name] = block
			parentX = Math.max(point.x, point.x + totalChildLength/2 - block.width/2)
			@drawer.positionBlock(block, new Point(parentX, point.y))

		# if we didn't have any children, return our width, 
		# otherwise it's either the width of our children
		# or the width of us, if we're wider
		if not block.children?[0]?
			return block.width  
		else return Math.max(block.width, totalChildLength)
			
	drawConnectors: (block) ->
		return unless block

		parentBlock = @blocksThatIHaveDrawn[block.name]
		for child in block.children
			if block.name
				childBlock = @blocksThatIHaveDrawn[child.name]
				@drawer.connectExistingBlocks(parentBlock, childBlock, "down", child.arrow )
			@drawConnectors(child)

	##############################
	#	Things not about drawing
	##############################

	applySomePropertiesOfSorts: (wereBeingSilly) ->
		@drawer.textFontName = if wereBeingSilly then "Shadows Into Light Two" else "Helvetica"
		@drawer.textFontSize = if wereBeingSilly then "14px" else "12px"

	saveAllTheThings: (raphaelCanvas) ->
		# strips off all spaces between tags
		svgImage = raphaelCanvas.innerHTML.replace(/>\s+/g, ">").replace(/\s+</g, "<")

		# create a temp canvas and load the svg in it
		# TODO: this loses arrows somewhere
		canvas = document.createElement("canvas")
		canvg(canvas, svgImage, {ignoreMouse: true, ignoreAnimation: true})
		img = canvas.toDataURL("image/png")
		window.open(img, "_blank")


