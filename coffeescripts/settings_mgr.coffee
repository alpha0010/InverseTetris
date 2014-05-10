# display welcome options and init game
class SettingsMgr
    selectIdx:  -1
    dc:         null
    game:       null
    rectBounds: null
    scale:      1


    # set up canvas
    constructor: ->
        w = window.innerWidth  || document.documentElement.clientWidth  || document.body.clientWidth
        h = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight
        @scale = Math.floor(Math.min(h, w) / 300)
        canvas = document.getElementById "gameBoard"
        canvas.width  = 130 * @scale
        canvas.height = 130 * @scale
        drawingContext = canvas.getContext "2d"
        drawingContext.font = "#{24*@scale}px Arial"
        drawingContext.fillStyle = "white"
        drawingContext.fillText "Easy",      8 * @scale,  26 * @scale
        drawingContext.fillText "Normal",    8 * @scale,  58 * @scale
        drawingContext.fillText "Abnormal",  8 * @scale,  90 * @scale
        drawingContext.fillText "TetrChess", 8 * @scale, 122 * @scale
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
        mouseClickHandler = (e) =>
            @onEvtMouseMove e
            doStart @selectIdx
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
        @dc.strokeRect 4 * @scale,   4 * @scale, 120 * @scale, 26 * @scale
        @dc.strokeStyle = if @selectIdx == 1 then highlight else regular
        @dc.strokeRect 4 * @scale,  36 * @scale, 120 * @scale, 26 * @scale
        @dc.strokeStyle = if @selectIdx == 2 then highlight else regular
        @dc.strokeRect 4 * @scale,  68 * @scale, 120 * @scale, 26 * @scale
        @dc.strokeStyle = if @selectIdx == 3 then highlight else regular
        @dc.strokeRect 4 * @scale, 100 * @scale, 120 * @scale, 26 * @scale


    # update the selection
    onEvtMouseMove: (evt) =>
        xPos = evt.clientX - @rectBounds.left
        yPos = evt.clientY - @rectBounds.top
        idx = -1
        if xPos > 4 * @scale and xPos < 124 * @scale
            if yPos > 4 * @scale and yPos < 30 * @scale
                idx = 0
            else if yPos > 36 * @scale and yPos < 62 * @scale
                idx = 1
            else if yPos > 68 * @scale and yPos < 94 * @scale
                idx = 2
            else if yPos > 100 * @scale and yPos < 126 * @scale
                idx = 3
        if @selectIdx != idx
            @selectIdx = idx
            @drawSelection()
        return


# make this class available in global scope
window.SettingsMgr = SettingsMgr
