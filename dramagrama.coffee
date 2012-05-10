class window.Controller
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
		previousChildEndX = 0
		drawnChildren = 0
		for child in block.children
			continue unless child
			childBlock = @blocksThatIHaveDrawn[child.name]
			# has this child been drawn? if so, let's connect to it
			if childBlock
				@drawer.connectExistingBlocks(parentBlock, childBlock, "down", child.arrow )
			else
				childBlock = @drawer.drawAndConnectToBlock(parentBlock, child, previousChildEndX, "down", child.arrow)
				previousChildEndX = childBlock.rectangle.top.x + childBlock.rectangle.width
				@blocksThatIHaveDrawn[child.name] = childBlock
				@drawRootedBlock child
				drawnChildren++

		return unless drawnChildren > 1
		
		# now that we've drawn all the children, recenter the parent above them
		#newCenter = (previousChildEndX - parentBlock.rectangle.width)/2
		#if (newCenter > 0)
		#		@drawer.repositionBlock(parentBlock, newCenter)


	# get the number of non-standalone children
	getNumLinkedChildren: (lines) ->
		total = 0
		(total = total + 1) for line in lines when line
		return total


