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