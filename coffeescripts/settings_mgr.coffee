class SettingsMgr
    selectIdx: -1
    dc: null
    game: null
    rectBounds: null


    constructor: ->
        canvas = document.getElementById "gameBoard"
        canvas.width  = 200
        canvas.height = 100
        drawingContext = canvas.getContext "2d"
        drawingContext.font = "24px Arial"
        drawingContext.fillStyle = "white"
        drawingContext.fillText "Normal",    8, 26
        drawingContext.fillText "Abnormal",  8, 58
        drawingContext.fillText "TetrChess", 8, 90
        @dc = drawingContext
        @drawSelection()
        @rectBounds = canvas.getBoundingClientRect()
        mouseMoveHandler  = (e) => @onEvtMouseMove(e)
        mouseClickHandler = (e) =>
            @onEvtMouseClick(e)
            if @selectIdx != -1
                canvas.removeEventListener "mousemove", mouseMoveHandler
                canvas.removeEventListener "mouseup",   mouseClickHandler
        canvas.addEventListener "mousemove", mouseMoveHandler
        canvas.addEventListener "mouseup",   mouseClickHandler


    drawSelection: ->
        regular   = "white"
        highlight = "red"
        @dc.strokeStyle = if @selectIdx == 0 then highlight else regular
        @dc.strokeRect 4,  4, 120, 26
        @dc.strokeStyle = if @selectIdx == 1 then highlight else regular
        @dc.strokeRect 4, 36, 120, 26
        @dc.strokeStyle = if @selectIdx == 2 then highlight else regular
        @dc.strokeRect 4, 68, 120, 26


    onEvtMouseMove: (evt) =>
        xPos = evt.clientX - @rectBounds.left
        yPos = evt.clientY - @rectBounds.top
        idx = -1
        if xPos > 4 and xPos < 124
            if yPos > 4 and yPos < 30
                idx = 0
            else if yPos > 36 and yPos < 62
                idx = 1
            else if yPos > 68 and yPos < 94
                idx = 2
        if @selectIdx != idx
            @selectIdx = idx
            @drawSelection()
        return


    onEvtMouseClick: (evt) =>
        if @selectIdx != -1
            @game = new InverseTetris new TetrisAI @selectIdx
        return


window.SettingsMgr = SettingsMgr
