# the game
class InverseTetris
    currentBoard:  null # state of current game board
    cellSize:        25 # pixel width of a cell
    numberOfRows:    20
    numberOfColumns: 10
    rightBuffer:      5 # extra columns
    bottemBuffer:     4 # extra rows
    tickLength:     175 # milliseconds per game 'tick'
    aiTickLength:    15 # millisecond delay to ask AI module for move update
    dc:            null # canvas to draw on
    pieces:        null # list of possible blocks
    fallingBlock:  null # current falling block
    nextBlock:     null # the next block to come
    nextBlockIdx:  null # index of the next block
    aiController:  null # the AI module
    score:      0
    totalMoves: 0
    rectBounds:    null # location on screen of the canvas
    selectedShape: -1   # UI shape the mouse is hovered over
    uiBounds:      null # coordinates of UI shapes and their remaining counts


    # set up the starting states and events
    constructor: (aiModule) ->
        w = window.innerWidth  || document.documentElement.clientWidth  || document.body.clientWidth
        h = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight
        maxCellSize = Math.min((w - 20) / (@numberOfColumns + @rightBuffer) - 1, (h - 20) / (@numberOfRows + @bottemBuffer) - 1)
        if (maxCellSize > @cellSize)
            @cellSize = Math.floor((7 * maxCellSize + @cellSize) / 8)
        else
            @cellSize = Math.floor(maxCellSize)
        canvas = document.getElementById "gameBoard"
        canvas.width  = (@cellSize + 1) * (@numberOfColumns + @rightBuffer) + 1
        canvas.height = (@cellSize + 1) * (@numberOfRows + @bottemBuffer) + 1
        @dc = canvas.getContext "2d"
        @dc.fillStyle = "rgb(38,38,38)"
        @dc.strokeStyle = "transparent"
        @dc.fillRect 0, 0, canvas.width, canvas.height
        @initPieces()
        @initBoard()
        @nextBlockIdx = Math.floor(Math.random() * 7)
        @nextBlock = @createFallingBlock @pieces[@nextBlockIdx]
        @initUIBounds()
        @rectBounds = canvas.getBoundingClientRect()
        canvas.addEventListener "mousemove", (e) => @onEvtMouseMove e
        canvas.addEventListener "mouseup",   (e) =>
            @onEvtMouseMove e
            @onEvtMouseClick e
        window.addEventListener "keypress",  (e) => @onEvtKeyPress e
        aiChoices = []
        for piece in @pieces
            aiChoices.push @createFallingBlock piece
        aiModule.initBlockChoices aiChoices
        @aiController = aiModule
        @tick()


    # pieces have an rgb header, then orientation count, then a bitfield for blocks
    initPieces: ->
        @pieces = [
            # I
            [ [0, 255, 255], 2,
              [1, 1, 1, 1] ],
            # J
            [ [0, 0, 255], 4,
              [1, 1, 1],
              [0, 0, 1] ],
            # L
            [ [255, 165, 0], 4,
              [1, 1, 1],
              [1, 0, 0] ],
            # O
            [ [255, 255, 0], 1,
              [1, 1],
              [1, 1] ],
            # S
            [ [128, 255, 0], 2,
              [0, 1, 1],
              [1, 1, 0] ],
            # T
            [ [128, 0, 128], 4,
              [1, 1, 1],
              [0, 1, 0] ],
            # Z
            [ [255, 0, 255], 2,
              [1, 1, 0],
              [0, 1, 1] ]
        ]
        @pieces.ids = "ijlostz"


    # init the starting board
    initBoard: ->
        @currentBoard = []
        for row in [0...@numberOfRows]
            @currentBoard[row] = []
            for column in [0...@numberOfColumns]
                cell = @createCell()
                @currentBoard[row][column] = cell
        return


    # init UI boundaries (block button placements and counts)
    initUIBounds: ->
        @uiBounds = []
        halfSz = @cellSize / 2
        for pIdx in [0...@pieces.length]
            @uiBounds.push { x: (1 + 5 * (pIdx % 4)) * (halfSz + 1) + 1, y: (2 * @numberOfRows + (if pIdx > 3 then 3 else 0)) * (halfSz + 1) + 1, count: 4 }
        return


    # create a default cell structure
    createCell: ->
        isFull: false
        fillStyle: null


    # clockwise 90 degrees
    rotateArray: (theArray) ->
        outArray = []
        for row in [0...theArray.length]
            for column in [0...theArray[row].length]
                if row is 0
                    outArray[column] = []
                outArray[column][row] = theArray[theArray.length - row - 1][column]
        return outArray


    # increment the game one 'tick' into the future
    tick: =>
        if @fallingBlock is null
            if @nextBlock is null # user was too slow
                if Math.random() < 0.7 # let the AI choose (sometimes; if it was always, the AI can feel "too" strong)
                    minVal = Number.MAX_VALUE
                    for idx in [0...@uiBounds.length]
                        if @uiBounds[idx].count > 0
                            testVal = @aiController.queryDesirability @currentBoard, @createFallingBlock @pieces[idx]
                            if testVal < minVal
                                minVal = testVal
                                @nextBlockIdx = idx
                else # choose randomly
                    @nextBlockIdx = Math.floor(Math.random() * 7)
                    while @uiBounds[@nextBlockIdx].count == 0
                        @nextBlockIdx = (@nextBlockIdx + 1) % 7
                @nextBlock = @createFallingBlock @pieces[@nextBlockIdx]
            @fallingBlock = @nextBlock
            @uiBounds[@nextBlockIdx].count -= 1
            allLessThanTwo = true
            allEqual = true
            for bound in @uiBounds
                allLessThanTwo = false if bound.count > 1
                allEqual = false if bound.count != @uiBounds[@nextBlockIdx].count
            if allEqual
                bound.count = 4 for bound in @uiBounds
            else if allLessThanTwo
                bound.count += 2 for bound in @uiBounds
            @selectedShape = -1 if @selectedShape != -1 and @uiBounds[@selectedShape].count <= 0
            @nextBlockIdx = -1
            @nextBlock = null
            @drawNextBlock()
            @drawUI()
            @tickLength = 175 # reset
        if @blockIntersects @fallingBlock.row + 1, @fallingBlock.column
            return if @fallingBlock.row is -1 # Game Over! (all timers stopped)
            @applyBlock()
            @fallingBlock = null
            numFilledCells = 0
            for row in @currentBoard
                for cell in row
                    numFilledCells += 1 if cell.isFull
            @totalMoves += 1
            @score += Math.floor(Math.pow(numFilledCells, 0.6) * 4) / 4 # award partial points
        else
            @fallingBlock.row += 1
        @drawGrid()
        setTimeout @tick, @tickLength
        setTimeout @aiTick, @aiTickLength


    # ask if the AI module wants to do another move
    aiTick: =>
        if @fallingBlock is null
            return
        move = @aiController.chooseMove @currentBoard, @fallingBlock
        switch move
            when 1
                @moveLeft()
            when 2
                @moveRight()
            when 3
                @rotateCCW()
            when 4
                @rotateCW()
            else  # no further moves requested, drop the block faster (will increase as game progresses)
                @tickLength = Math.max 64, 175 - @totalMoves
                return
        @tickLength = 175 # reset: should not happen, but this AI sometimes changes its mind
                          # on second thought, this behaviour makes the AI a more interesting opponent
        setTimeout @aiTick, @aiTickLength


    # update the selection highlight
    onEvtMouseMove: (evt) =>
        xPos = evt.clientX - @rectBounds.left
        yPos = evt.clientY - @rectBounds.top
        for cIdx in [0...@uiBounds.length]
            corner = @uiBounds[cIdx]
            if xPos > corner.x and xPos < corner.x + 2 * @cellSize and yPos > corner.y and yPos < corner.y + @cellSize
                cIdx = -1 if @uiBounds[cIdx].count <= 0
                if @selectedShape != cIdx
                    @selectedShape = cIdx
                    @drawUI()
                return
        if @selectedShape != -1
            @selectedShape = -1
            @drawUI()
        return


    # update the next queued block based on the mouse hover
    onEvtMouseClick: (evt) =>
        if @selectedShape != -1
            @nextBlock = @createFallingBlock @pieces[@selectedShape]
            @nextBlockIdx = @selectedShape
            @drawNextBlock()
        return


    # update the next queued block based on keyboard accelerators
    onEvtKeyPress: (evt) =>
        evtKey = null
        if evt.which == null
            evtKey = String.fromCharCode evt.keyCode
        else if evt.which != 0 and evt.charCode != 0
            evtKey = String.fromCharCode evt.which
        if evtKey != null
            shapeIdx = @pieces.ids.search evtKey
            if shapeIdx != -1 and @uiBounds[shapeIdx].count > 0 and shapeIdx != @nextBlockIdx
                @nextBlock = @createFallingBlock @pieces[shapeIdx]
                @nextBlockIdx = shapeIdx
                @drawNextBlock()
        return


    # test if the current falling block would intersect part of the board
    blockIntersects: (row, column) ->
        for shapeRow in [0...@fallingBlock.geometry.length]
            return true if row + shapeRow < 0 or row + shapeRow >= @numberOfRows
            for shapeColumn in [0...@fallingBlock.geometry[shapeRow].length]
                if column + shapeColumn < 0 or column + shapeColumn >= @numberOfColumns
                    return true
                if @fallingBlock.geometry[shapeRow][shapeColumn] is 1 and @currentBoard[row + shapeRow][column + shapeColumn].isFull
                    return true
        return false


    # init a block object off its raw geometry
    createFallingBlock: (shape) ->
        row: -1
        column: Math.floor((@numberOfColumns - shape[2].length) / 2)
        fillStyle: "rgb(#{shape[0][0]},#{shape[0][1]},#{shape[0][2]})"
        orientations: shape[1]
        geometry: shape[2..]


    # make the falling block static on the current board
    applyBlock: ->
        shape = @fallingBlock.geometry
        for row in [0...shape.length]
            for column in [0...shape[row].length]
                if shape[row][column] is 1
                    cell = @currentBoard[row + @fallingBlock.row][column + @fallingBlock.column]
                    cell.isFull = true
                    cell.fillStyle = @fallingBlock.fillStyle
        @checkLines()


    # check for filled rows (and remove)
    checkLines: ->
        for row in [0...@numberOfRows]
            @removeRow row if @arrayIsFull @currentBoard[row]
        return


    # helper: true if theArray isFull
    arrayIsFull: (theArray) ->
        for cell in theArray
            return false if not cell.isFull
        return true


    # remove the row from the board, and shift everything down
    removeRow: (row) ->
        @currentBoard.splice(row, 1)
        @currentBoard.splice(0, 0, [])
        for column in [0...@numberOfColumns]
            @currentBoard[0][column] = @createCell()
        return


    # draw the board
    drawGrid: ->
        for row in [0...@numberOfRows]
            for column in [0...@numberOfColumns]
                @drawCell @currentBoard[row][column], row, column
        if @fallingBlock isnt null
            cell = @createCell()
            cell.isFull = true
            cell.fillStyle = @fallingBlock.fillStyle
            shape = @fallingBlock.geometry
            for shapeRow in [0...shape.length]
                for shapeColumn in [0...shape[shapeRow].length]
                    if shape[shapeRow][shapeColumn] is 1
                        @drawCell cell, @fallingBlock.row + shapeRow, @fallingBlock.column + shapeColumn
        return


    # draw the queued block
    drawNextBlock: ->
        @dc.fillStyle = "rgb(38,38,38)"
        @dc.strokeStyle = "transparent"
        @dc.fillRect @numberOfColumns * (@cellSize + 1) + 1, 0, @rightBuffer * (@cellSize + 1), @numberOfRows * (@cellSize + 1)
        @drawScore()
        if @nextBlock is null
            @dc.font = "#{@cellSize}px Arial"
            @dc.fillStyle = "white"
            @dc.fillText("???", (@numberOfColumns + 1.25) * (@cellSize + 1), 2.25 * (@cellSize + 1))
            return
        cell = @createCell()
        cell.isFull = true
        cell.fillStyle = @nextBlock.fillStyle
        shape = @nextBlock.geometry
        for shapeRow in [0...shape.length]
            for shapeColumn in [0...shape[shapeRow].length]
                if shape[shapeRow][shapeColumn] is 1
                    @drawCell cell, 1 + shapeRow, @numberOfColumns + 1 + shapeColumn
        return


    # draw the UI bar at the bottom
    drawUI: ->
        @dc.fillStyle = "rgb(38,38,38)"
        @dc.strokeStyle = "transparent"
        @dc.fillRect 0, @numberOfRows * (@cellSize + 1) + 1, (@numberOfColumns) * (@cellSize + 1), @bottemBuffer * (@cellSize + 1)
        oldCellSize = @cellSize
        @cellSize /= 2
        for pIdx in [0...@pieces.length]
            block = @pieces[pIdx]
            cell = @createCell()
            cell.isFull = true
            if @uiBounds[pIdx].count > 0
                cell.fillStyle = "rgb(#{block[0][0]},#{block[0][1]},#{block[0][2]})"
            else # block used up...
                cell.fillStyle = "gray"
            strokeCol = "transparent"
            if pIdx == @selectedShape
                strokeCol = "red"
            shape = block[2..]
            for shapeRow in [0...shape.length]
                for shapeColumn in [0...shape[shapeRow].length]
                    if shape[shapeRow][shapeColumn] is 1
                        @drawCell cell, 2 * @numberOfRows + shapeRow + (if pIdx > 3 then 3 else 0), 1 + shapeColumn + 5 * (pIdx % 4), strokeCol
            @dc.font = "#{@cellSize}px Arial"
            @dc.fillStyle = "white"
            @dc.fillText(@uiBounds[pIdx].count, @uiBounds[pIdx].x, @uiBounds[pIdx].y - 1)
            @dc.font = "#{@cellSize*0.9}px Arial"
            @dc.fillStyle = "grey"
            @dc.fillText("(#{@pieces.ids[pIdx].toUpperCase()})", @uiBounds[pIdx].x + @cellSize, @uiBounds[pIdx].y - @cellSize / 5)
        @cellSize = oldCellSize


    # display the current score
    drawScore: ->
        @dc.font = "#{@cellSize}px Arial"
        @dc.fillStyle = "white"
        @dc.fillText("Score", (@numberOfColumns + 0.5) * (@cellSize + 1), 5 * (@cellSize + 1))
        if (@totalMoves > 0)
            @dc.fillText(Math.round(1000 * @score / @totalMoves), (@numberOfColumns + 0.5) * (@cellSize + 1), 6 * (@cellSize + 1))
        @dc.fillText("Blocks", (@numberOfColumns + 0.5) * (@cellSize + 1), 7.4 * (@cellSize + 1))
        @dc.fillText(@totalMoves, (@numberOfColumns + 0.5) * (@cellSize + 1), 8.4 * (@cellSize + 1))


    # draw a (styled) cell; row and column are translated by @cellSize
    drawCell: (cell, row, column, strokeCol = "rgb(54,51,40)") ->
        x = column * (@cellSize + 1) + 1
        y = row * (@cellSize + 1) + 1
        backgroundCol = "rgb(38,38,38)"
        fillStyle = if cell.isFull then cell.fillStyle else backgroundCol
        @dc.strokeStyle = strokeCol
        @dc.strokeRect x, y, @cellSize, @cellSize
        @dc.fillStyle = fillStyle
        @dc.fillRect x, y, @cellSize, @cellSize
        if cell.isFull
            bevelRad = @cellSize / 4
            # bottem shadow
            @dc.beginPath()
            @dc.moveTo x, y + @cellSize
            @dc.lineTo x + @cellSize, y + @cellSize
            @dc.lineTo x + @cellSize - bevelRad, y + @cellSize - bevelRad
            @dc.lineTo x + bevelRad, y + @cellSize - bevelRad
            @dc.closePath()
            gradient = @dc.createLinearGradient x, y + @cellSize - bevelRad, x, y + @cellSize
            gradient.addColorStop 0, "rgba(0,0,0,0)"
            gradient.addColorStop 1, "rgba(0,0,0,0.5)"
            @dc.fillStyle = gradient
            @dc.fill()
            # right shadow
            @dc.beginPath()
            @dc.moveTo x + @cellSize, y
            @dc.lineTo x + @cellSize, y + @cellSize
            @dc.lineTo x + @cellSize - bevelRad, y + @cellSize - bevelRad
            @dc.lineTo x + @cellSize - bevelRad, y + bevelRad
            @dc.closePath()
            gradient = @dc.createLinearGradient x + @cellSize - bevelRad, y, x + @cellSize, y
            gradient.addColorStop 0, "rgba(0,0,0,0)"
            gradient.addColorStop 1, "rgba(0,0,0,0.5)"
            @dc.fillStyle = gradient
            @dc.fill()
            # top highlight
            @dc.beginPath()
            @dc.moveTo x, y
            @dc.lineTo x + @cellSize, y
            @dc.lineTo x + @cellSize - bevelRad, y + bevelRad
            @dc.lineTo x + bevelRad, y + bevelRad
            @dc.closePath()
            gradient = @dc.createLinearGradient x, y + bevelRad, x, y
            gradient.addColorStop 0, "rgba(255,255,255,0)"
            gradient.addColorStop 1, "rgba(255,255,255,0.4)"
            @dc.fillStyle = gradient
            @dc.fill()
            # left highlight
            @dc.beginPath()
            @dc.moveTo x, y
            @dc.lineTo x, y + @cellSize
            @dc.lineTo x + bevelRad, y + @cellSize - bevelRad
            @dc.lineTo x + bevelRad, y + bevelRad
            @dc.closePath()
            gradient = @dc.createLinearGradient x + bevelRad, y, x, y
            gradient.addColorStop 0, "rgba(255,255,255,0)"
            gradient.addColorStop 1, "rgba(255,255,255,0.4)"
            @dc.fillStyle = gradient
            @dc.fill()
            # rounded corners
            bevelRad = @cellSize / 6
            # corner top left
            @dc.beginPath()
            @dc.moveTo x + bevelRad, y
            @dc.quadraticCurveTo x, y, x, y + bevelRad
            @dc.lineTo x, y
            @dc.closePath()
            @dc.fillStyle = backgroundCol
            @dc.fill()
            # corner top right
            @dc.beginPath()
            @dc.moveTo x + @cellSize - bevelRad, y
            @dc.quadraticCurveTo x + @cellSize, y, x + @cellSize, y + bevelRad
            @dc.lineTo x + @cellSize, y
            @dc.closePath()
            @dc.fill()
            # corner bottem left
            @dc.beginPath()
            @dc.moveTo x, y + @cellSize - bevelRad
            @dc.quadraticCurveTo x, y + @cellSize, x + bevelRad, y + @cellSize
            @dc.lineTo x, y + @cellSize
            @dc.closePath()
            @dc.fill()
            # corner bottem right
            @dc.beginPath()
            @dc.moveTo x + @cellSize, y + @cellSize - bevelRad
            @dc.quadraticCurveTo x + @cellSize, y + @cellSize, x + @cellSize - bevelRad, y + @cellSize
            @dc.lineTo x + @cellSize, y + @cellSize
            @dc.closePath()
            @dc.fill()


    # move the falling block left (if allowed)
    moveLeft: ->
        if @fallingBlock is null or @blockIntersects @fallingBlock.row, @fallingBlock.column - 1
            return
        @fallingBlock.column -= 1
        @drawGrid()


    # move the falling block right (if allowed)
    moveRight: ->
        if @fallingBlock is null or @blockIntersects @fallingBlock.row, @fallingBlock.column + 1
            return
        @fallingBlock.column += 1
        @drawGrid()


    # rotate the falling block CCW (if allowed)
    rotateCCW: ->
        if @fallingBlock is null
            return
        oldGeom = @fallingBlock.geometry
        @fallingBlock.geometry = @rotateArray @rotateArray @rotateArray @fallingBlock.geometry
        if @blockIntersects @fallingBlock.row, @fallingBlock.column
            @fallingBlock.geometry = oldGeom
        else
            @drawGrid()


    # rotate the falling block CW (if allowed)
    rotateCW: ->
        if @fallingBlock is null
            return
        oldGeom = @fallingBlock.geometry
        @fallingBlock.geometry = @rotateArray @fallingBlock.geometry
        if @blockIntersects @fallingBlock.row, @fallingBlock.column
            @fallingBlock.geometry = oldGeom
        else
            @drawGrid()


# make this class available to the global scope
window.InverseTetris = InverseTetris
