# the game
class InverseTetris
    currentBoard: null
    cellSize: 25
    numberOfRows: 20
    numberOfColumns: 10
    rightBuffer: 5  # extra columns
    bottemBuffer: 4 # extra rows
    tickLength: 175
    aiTickLength: 15
    drawingContext: null
    pieces: null
    fallingBlock: null
    nextBlock: null # the next block to come
    nextBlockIdx: null
    aiController: null
    score: 0
    totalMoves: 0
    rectBounds: null
    selectedShape: -1
    uiBounds: null


    # set up the starting state
    constructor: (aiModule) ->
        w = window.innerWidth  || document.documentElement.clientWidth  || document.body.clientWidth
        h = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight
        maxCellSize = Math.min((w - 20) / (@numberOfColumns + @rightBuffer) - 1, (h - 20) / (@numberOfRows + @bottemBuffer) - 1)
        if (maxCellSize > @cellSize)
            @cellSize = Math.floor((maxCellSize + @cellSize) / 2)
        else
            @cellSize = Math.floor(maxCellSize)
        canvas = document.getElementById "gameBoard"
        canvas.width  = (@cellSize + 1) * (@numberOfColumns + @rightBuffer) + 1
        canvas.height = (@cellSize + 1) * (@numberOfRows + @bottemBuffer) + 1
        @drawingContext = canvas.getContext "2d"
        @drawingContext.fillStyle = "rgb(38,38,38)"
        @drawingContext.strokeStyle = "transparent"
        @drawingContext.fillRect 0, 0, canvas.width, canvas.height
        @initPieces()
        @initBoard()
        @nextBlockIdx = Math.floor(Math.random() * 7)
        @nextBlock = @createFallingBlock @pieces[@nextBlockIdx]
        @initUIBounds()
        @rectBounds = canvas.getBoundingClientRect()
        canvas.addEventListener "mousemove", (e) => @onEvtMouseMove(e)
        canvas.addEventListener "mouseup", (e) => @onEvtMouseClick(e)
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


    # init the starting board
    initBoard: ->
        @currentBoard = []
        for row in [0...@numberOfRows]
            @currentBoard[row] = []
            for column in [0...@numberOfColumns]
                cell = @createCell()
                @currentBoard[row][column] = cell
        return


    # init UI boundaries
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
                if Math.random() < 0.7 # let the AI choose
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
            return if @fallingBlock.row is -1 # Game Over!
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
            else
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


    # update the next queued block
    onEvtMouseClick: (evt) =>
        if @selectedShape != -1
            @nextBlock = @createFallingBlock @pieces[@selectedShape]
            @nextBlockIdx = @selectedShape
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


    # make the falling block static
    applyBlock: ->
        shape = @fallingBlock.geometry
        for row in [0...shape.length]
            for column in [0...shape[row].length]
                if shape[row][column] is 1
                    cell = @currentBoard[row + @fallingBlock.row][column + @fallingBlock.column]
                    cell.isFull = true
                    cell.fillStyle = @fallingBlock.fillStyle
        @checkLines()


    # check for filled rows
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
        @drawingContext.fillStyle = "rgb(38,38,38)"
        @drawingContext.strokeStyle = "transparent"
        @drawingContext.fillRect @numberOfColumns * (@cellSize + 1) + 1, 0, @rightBuffer * (@cellSize + 1), @numberOfRows * (@cellSize + 1)
        @drawScore()
        if @nextBlock is null
            @drawingContext.font = "#{@cellSize}px Arial"
            @drawingContext.fillStyle = "white"
            @drawingContext.fillText("???", (@numberOfColumns + 1.25) * (@cellSize + 1), 2.25 * (@cellSize + 1))
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
        @drawingContext.fillStyle = "rgb(38,38,38)"
        @drawingContext.strokeStyle = "transparent"
        @drawingContext.fillRect 0, @numberOfRows * (@cellSize + 1) + 1, (@numberOfColumns) * (@cellSize + 1), @bottemBuffer * (@cellSize + 1)
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
            @drawingContext.font = "#{@cellSize}px Arial"
            @drawingContext.fillStyle = "white"
            @drawingContext.fillText(@uiBounds[pIdx].count, @uiBounds[pIdx].x, @uiBounds[pIdx].y - 1)
        @cellSize = oldCellSize
        return


    # display the current score
    drawScore: ->
        @drawingContext.font = "#{@cellSize}px Arial"
        @drawingContext.fillStyle = "white"
        @drawingContext.fillText("Score", (@numberOfColumns + 0.5) * (@cellSize + 1), 5 * (@cellSize + 1))
        if (@totalMoves > 0)
            @drawingContext.fillText(Math.round(1000 * @score / @totalMoves), (@numberOfColumns + 0.5) * (@cellSize + 1), 6 * (@cellSize + 1))
        @drawingContext.fillText("Blocks", (@numberOfColumns + 0.5) * (@cellSize + 1), 7.4 * (@cellSize + 1))
        @drawingContext.fillText(@totalMoves, (@numberOfColumns + 0.5) * (@cellSize + 1), 8.4 * (@cellSize + 1))


    # draw a (styled) cell
    drawCell: (cell, row, column, strokeCol = "rgb(54,51,40)") ->
        x = column * (@cellSize + 1) + 1
        y = row * (@cellSize + 1) + 1
        backgroundCol = "rgb(38,38,38)"
        fillStyle = if cell.isFull then cell.fillStyle else backgroundCol
        @drawingContext.strokeStyle = strokeCol
        @drawingContext.strokeRect x, y, @cellSize, @cellSize
        @drawingContext.fillStyle = fillStyle
        @drawingContext.fillRect x, y, @cellSize, @cellSize
        if cell.isFull
            bevelRad = @cellSize / 4
            # bottem shadow
            @drawingContext.beginPath()
            @drawingContext.moveTo x, y + @cellSize
            @drawingContext.lineTo x + @cellSize, y + @cellSize
            @drawingContext.lineTo x + @cellSize - bevelRad, y + @cellSize - bevelRad
            @drawingContext.lineTo x + bevelRad, y + @cellSize - bevelRad
            @drawingContext.closePath()
            gradient = @drawingContext.createLinearGradient x, y + @cellSize - bevelRad, x, y + @cellSize
            gradient.addColorStop 0, "rgba(0,0,0,0)"
            gradient.addColorStop 1, "rgba(0,0,0,0.5)"
            @drawingContext.fillStyle = gradient
            @drawingContext.fill()
            # right shadow
            @drawingContext.beginPath()
            @drawingContext.moveTo x + @cellSize, y
            @drawingContext.lineTo x + @cellSize, y + @cellSize
            @drawingContext.lineTo x + @cellSize - bevelRad, y + @cellSize - bevelRad
            @drawingContext.lineTo x + @cellSize - bevelRad, y + bevelRad
            @drawingContext.closePath()
            gradient = @drawingContext.createLinearGradient x + @cellSize - bevelRad, y, x + @cellSize, y
            gradient.addColorStop 0, "rgba(0,0,0,0)"
            gradient.addColorStop 1, "rgba(0,0,0,0.5)"
            @drawingContext.fillStyle = gradient
            @drawingContext.fill()
            # top highlight
            @drawingContext.beginPath()
            @drawingContext.moveTo x, y
            @drawingContext.lineTo x + @cellSize, y
            @drawingContext.lineTo x + @cellSize - bevelRad, y + bevelRad
            @drawingContext.lineTo x + bevelRad, y + bevelRad
            @drawingContext.closePath()
            gradient = @drawingContext.createLinearGradient x, y + bevelRad, x, y
            gradient.addColorStop 0, "rgba(255,255,255,0)"
            gradient.addColorStop 1, "rgba(255,255,255,0.4)"
            @drawingContext.fillStyle = gradient
            @drawingContext.fill()
            # left highlight
            @drawingContext.beginPath()
            @drawingContext.moveTo x, y
            @drawingContext.lineTo x, y + @cellSize
            @drawingContext.lineTo x + bevelRad, y + @cellSize - bevelRad
            @drawingContext.lineTo x + bevelRad, y + bevelRad
            @drawingContext.closePath()
            gradient = @drawingContext.createLinearGradient x + bevelRad, y, x, y
            gradient.addColorStop 0, "rgba(255,255,255,0)"
            gradient.addColorStop 1, "rgba(255,255,255,0.4)"
            @drawingContext.fillStyle = gradient
            @drawingContext.fill()
            # rounded corners
            bevelRad = @cellSize / 6
            # corner top left
            @drawingContext.beginPath()
            @drawingContext.moveTo x + bevelRad, y
            @drawingContext.quadraticCurveTo x, y, x, y + bevelRad
            @drawingContext.lineTo x, y
            @drawingContext.closePath()
            @drawingContext.fillStyle = backgroundCol
            @drawingContext.fill()
            # corner top right
            @drawingContext.beginPath()
            @drawingContext.moveTo x + @cellSize - bevelRad, y
            @drawingContext.quadraticCurveTo x + @cellSize, y, x + @cellSize, y + bevelRad
            @drawingContext.lineTo x + @cellSize, y
            @drawingContext.closePath()
            @drawingContext.fill()
            # corner bottem left
            @drawingContext.beginPath()
            @drawingContext.moveTo x, y + @cellSize - bevelRad
            @drawingContext.quadraticCurveTo x, y + @cellSize, x + bevelRad, y + @cellSize
            @drawingContext.lineTo x, y + @cellSize
            @drawingContext.closePath()
            @drawingContext.fill()
            # corner bottem right
            @drawingContext.beginPath()
            @drawingContext.moveTo x + @cellSize, y + @cellSize - bevelRad
            @drawingContext.quadraticCurveTo x + @cellSize, y + @cellSize, x + @cellSize - bevelRad, y + @cellSize
            @drawingContext.lineTo x + @cellSize, y + @cellSize
            @drawingContext.closePath()
            @drawingContext.fill()


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
