# display welcome options and init game
class SettingsMgr
    selectIdx:  -1
    dc:         null
    game:       null
    rectBounds: null


    # set up canvas
    constructor: ->
        canvas = document.getElementById "gameBoard"
        canvas.width  = 200
        canvas.height = 130
        drawingContext = canvas.getContext "2d"
        drawingContext.font = "24px Arial"
        drawingContext.fillStyle = "white"
        drawingContext.fillText "Easy",      8,  26
        drawingContext.fillText "Normal",    8,  58
        drawingContext.fillText "Abnormal",  8,  90
        drawingContext.fillText "TetrChess", 8, 122
        @dc = drawingContext
        @drawSelection()
        @rectBounds = canvas.getBoundingClientRect()
        doStart = (variant) ->
            if variant != -1
                canvas.removeEventListener "mousemove", mouseMoveHandler
                canvas.removeEventListener "mouseup",   mouseClickHandler
                window.removeEventListener "keypress",  keyPressHandler
                @game = new InverseTetris new TetrisAI variant
        mouseMoveHandler  = (e) => @onEvtMouseMove e
        mouseClickHandler = (e) => doStart @selectIdx
        keyPressHandler   = (e) =>
            evtKey = null
            if e.which == null
                evtKey = String.fromCharCode e.keyCode
            else if e.which != 0 and e.charCode != 0
                evtKey = String.fromCharCode e.which
            if evtKey != null
                idx = "enat".search evtKey
                if idx != -1
                    doStart idx
        canvas.addEventListener "mousemove", mouseMoveHandler
        canvas.addEventListener "mouseup",   mouseClickHandler
        window.addEventListener "keypress",  keyPressHandler


    # update box outlines
    drawSelection: ->
        regular   = "white"
        highlight = "red"
        @dc.strokeStyle = if @selectIdx == 0 then highlight else regular
        @dc.strokeRect 4,   4, 120, 26
        @dc.strokeStyle = if @selectIdx == 1 then highlight else regular
        @dc.strokeRect 4,  36, 120, 26
        @dc.strokeStyle = if @selectIdx == 2 then highlight else regular
        @dc.strokeRect 4,  68, 120, 26
        @dc.strokeStyle = if @selectIdx == 3 then highlight else regular
        @dc.strokeRect 4, 100, 120, 26


    # update the selection
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
            else if yPos > 100 and yPos < 126
                idx = 3
        if @selectIdx != idx
            @selectIdx = idx
            @drawSelection()
        return


# make this class available in global scope
window.SettingsMgr = SettingsMgr
