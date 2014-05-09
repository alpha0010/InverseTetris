// Generated by CoffeeScript 1.4.0
(function() {
  var SettingsMgr,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  SettingsMgr = (function() {

    SettingsMgr.prototype.selectIdx = -1;

    SettingsMgr.prototype.dc = null;

    SettingsMgr.prototype.game = null;

    SettingsMgr.prototype.rectBounds = null;

    function SettingsMgr() {
      this.onEvtMouseMove = __bind(this.onEvtMouseMove, this);

      var canvas, doStart, drawingContext, keyPressHandler, mouseClickHandler, mouseMoveHandler,
        _this = this;
      canvas = document.getElementById("gameBoard");
      canvas.width = 200;
      canvas.height = 130;
      drawingContext = canvas.getContext("2d");
      drawingContext.font = "24px Arial";
      drawingContext.fillStyle = "white";
      drawingContext.fillText("Easy", 8, 26);
      drawingContext.fillText("Normal", 8, 58);
      drawingContext.fillText("Abnormal", 8, 90);
      drawingContext.fillText("TetrChess", 8, 122);
      this.dc = drawingContext;
      this.drawSelection();
      this.rectBounds = canvas.getBoundingClientRect();
      doStart = function(variant) {
        if (variant !== -1) {
          canvas.removeEventListener("mousemove", mouseMoveHandler);
          canvas.removeEventListener("mouseup", mouseClickHandler);
          window.removeEventListener("keypress", keyPressHandler);
          return this.game = new InverseTetris(new TetrisAI(variant));
        }
      };
      mouseMoveHandler = function(e) {
        return _this.onEvtMouseMove(e);
      };
      mouseClickHandler = function(e) {
        return doStart(_this.selectIdx);
      };
      keyPressHandler = function(e) {
        var evtKey, idx;
        evtKey = null;
        if (e.which === null) {
          evtKey = String.fromCharCode(e.keyCode);
        } else if (e.which !== 0 && e.charCode !== 0) {
          evtKey = String.fromCharCode(e.which);
        }
        if (evtKey !== null) {
          idx = "enat".search(evtKey);
          if (idx !== -1) {
            return doStart(idx);
          }
        }
      };
      canvas.addEventListener("mousemove", mouseMoveHandler);
      canvas.addEventListener("mouseup", mouseClickHandler);
      window.addEventListener("keypress", keyPressHandler);
    }

    SettingsMgr.prototype.drawSelection = function() {
      var highlight, regular;
      regular = "white";
      highlight = "red";
      this.dc.strokeStyle = this.selectIdx === 0 ? highlight : regular;
      this.dc.strokeRect(4, 4, 120, 26);
      this.dc.strokeStyle = this.selectIdx === 1 ? highlight : regular;
      this.dc.strokeRect(4, 36, 120, 26);
      this.dc.strokeStyle = this.selectIdx === 2 ? highlight : regular;
      this.dc.strokeRect(4, 68, 120, 26);
      this.dc.strokeStyle = this.selectIdx === 3 ? highlight : regular;
      return this.dc.strokeRect(4, 100, 120, 26);
    };

    SettingsMgr.prototype.onEvtMouseMove = function(evt) {
      var idx, xPos, yPos;
      xPos = evt.clientX - this.rectBounds.left;
      yPos = evt.clientY - this.rectBounds.top;
      idx = -1;
      if (xPos > 4 && xPos < 124) {
        if (yPos > 4 && yPos < 30) {
          idx = 0;
        } else if (yPos > 36 && yPos < 62) {
          idx = 1;
        } else if (yPos > 68 && yPos < 94) {
          idx = 2;
        } else if (yPos > 100 && yPos < 126) {
          idx = 3;
        }
      }
      if (this.selectIdx !== idx) {
        this.selectIdx = idx;
        this.drawSelection();
      }
    };

    return SettingsMgr;

  })();

  window.SettingsMgr = SettingsMgr;

}).call(this);