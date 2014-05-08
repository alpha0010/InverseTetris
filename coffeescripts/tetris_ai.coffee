# an AI module
class TetrisAI
    pieces: null
    moveCache: null # pseudo hashmap/dictionary (depends on runtime)
    maxDepth: 0


    constructor: (depth) ->
        @maxDepth = depth


    initBlockChoices: (blocks) ->
        @pieces = blocks
        @moveCache = {}


    chooseMove: (currentBoard, block) ->
        return @calcMove(@cloneBoard(currentBoard), block)[0]


    # lower is better
    queryDesirability: (currentBoard, block) ->
        return @calcMove(@cloneBoard(currentBoard), block, @maxDepth - 1)[1]


    # AI entry point
    calcMove: (tstBrd, block, depth = 0) ->
        tstBlck = @cloneBlock block
        # move:
        #   0 - do nothing
        #   1 - move left
        #   2 - move right
        #   3 - rotate CCW
        #   4 - rotate CW
        minVal = @scoreMove tstBrd, tstBlck, depth
        bestMove = 0
        tstVal = @testMoveLeft tstBrd, tstBlck, depth
        if tstVal < minVal
            minVal = tstVal
            bestMove = 1
        tstBlck.column = block.column
        tstVal = @testMoveRight tstBrd, tstBlck, depth
        if tstVal < minVal
            minVal = tstVal
            bestMove = 2
        if block.orientations > 1
            tstVal = @testRotateCCW tstBrd, tstBlck, depth
            if tstVal < minVal
                minVal = tstVal
                bestMove = 3
            if block.orientations > 2
                tstVal = @testRotateCW tstBrd, tstBlck, depth
                if tstVal < Number.MAX_VALUE
                    oldGeom = tstBlck.geometry
                    tstBlck.geometry = @rotateArray tstBlck.geometry
                    tstVal = Math.min tstVal, @testRotateCW tstBrd, tstBlck, depth
                    tstBlck.geometry = oldGeom
                if tstVal < minVal
                    minVal = tstVal
                    bestMove = 4
        return [bestMove, minVal]


    # return the best score possible if we choose to rotate CCW
    testRotateCCW: (board, block, depth)->
        oldGeom = block.geometry
        oldCol = block.column
        minVal = Number.MAX_VALUE
        block.geometry = @rotateArray @rotateArray @rotateArray block.geometry
        if not @blockIntersects board, block, block.row, block.column
            minVal = @scoreMove board, block, depth
            minVal = Math.min minVal, @testMoveRight board, block, depth
            block.column = oldCol
            minVal = Math.min minVal, @testMoveLeft board, block, depth
        block.column = oldCol
        block.geometry = oldGeom
        return minVal


    # return the best score possible if we choose to rotate CW
    testRotateCW: (board, block, depth)->
        oldGeom = block.geometry
        oldCol = block.column
        minVal = Number.MAX_VALUE
        block.geometry = @rotateArray block.geometry
        if not @blockIntersects board, block, block.row, block.column
            minVal = @scoreMove board, block, depth
            minVal = Math.min minVal, @testMoveRight board, block, depth
            block.column = oldCol
            minVal = Math.min minVal, @testMoveLeft board, block, depth
        block.column = oldCol
        block.geometry = oldGeom
        return minVal


    # return the best score possible if we choose to move left
    testMoveLeft: (board, block, depth)->
        minVal = Number.MAX_VALUE
        while block.column > 0
            block.column -= 1
            if @blockIntersects board, block, block.row, block.column
                break
            minVal = Math.min minVal, @scoreMove board, block, depth
        return minVal


    # return the best score possible if we choose to move right
    testMoveRight: (board, block, depth)->
        minVal = Number.MAX_VALUE
        while block.column + block.geometry[0].length < board[0].length
            block.column += 1
            if @blockIntersects board, block, block.row, block.column
                break
            minVal = Math.min minVal, @scoreMove board, block, depth
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


    # deep copy the passed board
    cloneBoard: (board) ->
        out = []
        for row in [0...board.length]
            out[row] = []
            for column in [0...board[row].length]
                out[row][column] = board[row][column].isFull
        return out


    # deep copy the passed block
    cloneBlock: (block) ->
        out =
            row: Math.max 0, block.row
            column: block.column
            geometry: null
        out.geometry = []
        for row in [0...block.geometry.length]
            out.geometry[row] = []
            for column in [0...block.geometry[row].length]
                out.geometry[row][column] = block.geometry[row][column] is 1
        return out


    # give a score for the passed configuration
    scoreMove: (currentBoard, block, depth) ->
        if depth >= @maxDepth # max search depth
            return @evaluate @testDrop currentBoard, block
        nextBoard = @testDrop currentBoard, block

        boardId = ""
        if depth == 0
            for row in nextBoard
                rowProduct = 0
                for item in row
                    rowProduct *= 2
                    rowProduct += 1 if item
                if boardId.length > 0
                    boardId += "|" + rowProduct
                else if rowProduct > 0
                    boardId += rowProduct
            return @moveCache[boardId] if @moveCache.hasOwnProperty(boardId)

        score = Number.MIN_VALUE
        for piece in @pieces
            score = Math.max score, @calcMove(nextBoard, piece, depth + 1)[1]
        @moveCache[boardId] = score if depth == 0
        return score



    # return a copy of the board with the block applied where it would fall
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
        @checkLines out
        return out


    # test if the block would intersect board geometry if positioned at (row, column)
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


    # heuristic for scoring the board state, lower is better
    evaluate: (board) ->
        score = 0
        for row in [0...board.length]
            for column in [0...board[row].length]
                if board[row][column]
                    score += (board.length - row + 2) / 2 * @calcColumnMultiplier(column, board[row].length)
                    if row < board.length - 3 # not on bottom
                        score += (board.length - row + 6) / 8
                else if row > 0 and board[row - 1][column]
                    score += 18
                    for rowDepth in [row...board.length]
                        if not board[rowDepth][column]
                            score += 1
                        else
                            break
        for column in [0...board[0].length]
            pipeLen = 0
            pipeRow = -1
            for row in [0...board.length]
                if not board[row][column] and (column is 0 or board[row][column - 1]) and (column is board[0].length - 1 or board[row][column + 1])
                    pipeRow = row if pipeRow is -1
                    ++pipeLen
            if pipeLen > 1
                score += pipeLen * (board.length - pipeRow + 3) / 4
        return score


    # helper: give better scores for items keeping the middle clear
    calcColumnMultiplier: (column, len) ->
        val = ((if column > len / 2 then len - column - 1 else column) + 2) / (len + 2)
        return (val + 2) / 2.0


    # remove filled lines
    checkLines: (board) ->
        for row in [0...board.length]
            @removeRow board, row if @arrayIsFull board[row]
        return


    # helper: true if theArray is filled
    arrayIsFull: (theArray) ->
        for filled in theArray
            return false if not filled
        return true


    # remove the specified row, shifting above rows down
    removeRow: (board, row) ->
        board.splice(row, 1)
        board.splice(0, 0, [])
        for column in [0...board[1].length]
            board[0][column] = false
        return


# make this class available in global scope
window.TetrisAI = TetrisAI
