class TetrisAI
    lastTime: -1
    moveCache: null

    constructor: ->
        x = 1


    chooseMove: (currentBoard, block, timeCode) ->
        tstBrd = @cloneBoard currentBoard
        tstBlck = @cloneBlock block
        # move:
        #   0 - do nothing
        #   1 - move left
        #   2 - move right
        #   3 - rotate CCW
        #   4 - rotate CW
        minVal = @scoreMove tstBrd, tstBlck
        bestMove = 0
        tstVal = @testMoveLeft tstBrd, tstBlck
        if tstVal < minVal
            minVal = tstVal
            bestMove = 1
        tstBlck.column = block.column
        tstVal = @testMoveRight tstBrd, tstBlck
        if tstVal < minVal
            minVal = tstVal
            bestMove = 2
        if block.orientations > 1
            tstVal = @testRotateCCW tstBrd, tstBlck
            if tstVal < minVal
                minVal = tstVal
                bestMove = 3
            if block.orientations > 2
                tstVal = @testRotateCW tstBrd, tstBlck
                if tstVal < Number.MAX_VALUE
                    oldGeom = tstBlck.geometry
                    tstBlck.geometry = @rotateArray tstBlck.geometry
                    tstVal = Math.min tstVal, @testRotateCW tstBrd, tstBlck
                    tstBlck.geometry = oldGeom
                if tstVal < minVal
                    minVal = tstVal
                    bestMove = 4
        return bestMove
        # unused
        if timeCode is @lastTime
            if @moveCache.length > 0
                return @moveCache.shift()
            else
                return -1
        return -1


    testRotateCCW: (board, block)->
        oldGeom = block.geometry
        oldCol = block.column
        minVal = Number.MAX_VALUE
        block.geometry = @rotateArray @rotateArray @rotateArray block.geometry
        if not @blockIntersects board, block, block.row, block.column
            minVal = @scoreMove board, block
            minVal = Math.min minVal, @testMoveRight board, block
            block.column = oldCol
            minVal = Math.min minVal, @testMoveLeft board, block
        block.column = oldCol
        block.geometry = oldGeom
        return minVal


    testRotateCW: (board, block)->
        oldGeom = block.geometry
        oldCol = block.column
        minVal = Number.MAX_VALUE
        block.geometry = @rotateArray block.geometry
        if not @blockIntersects board, block, block.row, block.column
            minVal = @scoreMove board, block
            minVal = Math.min minVal, @testMoveRight board, block
            block.column = oldCol
            minVal = Math.min minVal, @testMoveLeft board, block
        block.column = oldCol
        block.geometry = oldGeom
        return minVal


    testMoveLeft: (board, block)->
        minVal = Number.MAX_VALUE
        while block.column > 0
            block.column -= 1
            if @blockIntersects board, block, block.row, block.column
                break
            minVal = Math.min minVal, @scoreMove board, block
        return minVal


    testMoveRight: (board, block)->
        minVal = Number.MAX_VALUE
        while block.column + block.geometry[0].length < board[0].length
            block.column += 1
            if @blockIntersects board, block, block.row, block.column
                break
            minVal = Math.min minVal, @scoreMove board, block
        return minVal


    # clockwise 90 degrees
    rotateArray: (theArray) ->
        outArray = []
        for row in [0...theArray.length]
            for column in [0...theArray[row].length]
                if row is 0
                    outArray[column] = []
                outArray[column][row] = theArray[theArray.length - row - 1][column]
        return outArray


    cloneBoard: (board) ->
        out = []
        for row in [0...board.length]
            out[row] = []
            for column in [0...board[row].length]
                out[row][column] = board[row][column].isFull
        return out


    cloneBlock: (block) ->
        out =
            row: block.row
            column: block.column
            geometry: null
        out.geometry = []
        for row in [0...block.geometry.length]
            out.geometry[row] = []
            for column in [0...block.geometry[row].length]
                out.geometry[row][column] = block.geometry[row][column] is 1
        return out


    scoreMove: (currentBoard, block) ->
        return @evaluate @testDrop currentBoard, block


    testDrop: (currentBoard, block) ->
        delta = 0
        while not @blockIntersects currentBoard, block, block.row + delta + 1, block.column
            ++delta
        out = []
        for row in [0...currentBoard.length]
            out[row] = []
            for column in [0...currentBoard[row].length]
                out[row][column] = currentBoard[row][column]
        for shapeRow in [0...block.geometry.length]
            for shapeColumn in [0...block.geometry[shapeRow].length]
                out[shapeRow + block.row + delta][shapeColumn + block.column] or= block.geometry[shapeRow][shapeColumn]
        return out


    blockIntersects: (board, block, row, column) ->
        for shapeRow in [0...block.geometry.length]
            if row + shapeRow < 0 or row + shapeRow >= board.length
                return true
            for shapeColumn in [0...block.geometry[shapeRow].length]
                if column + shapeColumn < 0 or column + shapeColumn >= board[0].length
                    return true
                if block.geometry[shapeRow][shapeColumn] and board[row + shapeRow][column + shapeColumn]
                    return true
        return false


    # lower is better
    evaluate: (board) ->
        score = 0
        @checkLines board
        for row in [0...board.length]
            for column in [0...board[row].length]
                if board[row][column]
                    score += (board.length - row + 2) / 2 * @calcColumnMultiplier(column, board[row].length)
                else if row > 0 and board[row - 1][column]
                    score += 10   # 12
        for column in [0...board[0].length]
            pipeLen = 0
            pipeRow = -1
            for row in [0...board.length]
                if not board[row][column] and (column is 0 or board[row][column - 1]) and (column is board[0].length - 1 or board[row][column + 1])
                    pipeRow = row if pipeRow is -1
                    ++pipeLen
            if pipeLen > 1
                score += pipeLen * (board.length - pipeRow + 2) / 4
        return score


    calcColumnMultiplier: (column, len) ->
        val = (if column > len / 2 then len - column - 1 else column) / len
        return (val + 2) / 2.0


    checkLines: (board) ->
        for row in [0...board.length]
            @removeRow board, row if @arrayIsFull board[row]
        return


    arrayIsFull: (theArray) ->
        for filled in theArray
            return false if not filled
        return true


    removeRow: (board, row) ->
        board.splice(row, 1)
        board.splice(0, 0, [])
        for column in [0...board[1].length]
            board[0][column] = false
        return


# make this class available
window.TetrisAI = TetrisAI
