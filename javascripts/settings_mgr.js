// Generated by CoffeeScript 1.4.0
(function() {
  var SettingsMgr,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  SettingsMgr = (function() {

    SettingsMgr.prototype.selectIdx = -1;

    SettingsMgr.prototype.dc = null;

    SettingsMgr.prototype.game = null;

    SettingsMgr.prototype.rectBounds = null;

    SettingsMgr.prototype.scale = 1;

    function SettingsMgr() {
      this.onEvtMouseMove = __bind(this.onEvtMouseMove, this);

      var canvas, context, doStart, h, keyPressHandler, mouseClickHandler, mouseMoveHandler, w,
        _this = this;
      w = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
      h = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;
      this.scale = Math.max(1, Math.min(h, w) / 300);
      canvas = document.getElementById("gameBoard");
      canvas.width = 130 * this.scale;
      canvas.height = 130 * this.scale;
      context = canvas.getContext("2d");
      context.font = "" + (24 * this.scale) + "px Arial";
      context.fillStyle = "white";
      context.fillText("Easy", 8 * this.scale, 26 * this.scale);
      context.fillText("Normal", 8 * this.scale, 58 * this.scale);
      context.fillText("Abnormal", 8 * this.scale, 90 * this.scale);
      context.fillText("TetrChess", 8 * this.scale, 122 * this.scale);
      this.dc = context;
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
        _this.onEvtMouseMove(e);
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
      this.dc.strokeRect(4 * this.scale, 4 * this.scale, 120 * this.scale, 26 * this.scale);
      this.dc.strokeStyle = this.selectIdx === 1 ? highlight : regular;
      this.dc.strokeRect(4 * this.scale, 36 * this.scale, 120 * this.scale, 26 * this.scale);
      this.dc.strokeStyle = this.selectIdx === 2 ? highlight : regular;
      this.dc.strokeRect(4 * this.scale, 68 * this.scale, 120 * this.scale, 26 * this.scale);
      this.dc.strokeStyle = this.selectIdx === 3 ? highlight : regular;
      return this.dc.strokeRect(4 * this.scale, 100 * this.scale, 120 * this.scale, 26 * this.scale);
    };

    SettingsMgr.prototype.onEvtMouseMove = function(evt) {
      var idx, xPos, yPos;
      xPos = evt.clientX - this.rectBounds.left;
      yPos = evt.clientY - this.rectBounds.top;
      idx = -1;
      if (xPos > 4 * this.scale && xPos < 124 * this.scale) {
        if (yPos > 4 * this.scale && yPos < 30 * this.scale) {
          idx = 0;
        } else if (yPos > 36 * this.scale && yPos < 62 * this.scale) {
          idx = 1;
        } else if (yPos > 68 * this.scale && yPos < 94 * this.scale) {
          idx = 2;
        } else if (yPos > 100 * this.scale && yPos < 126 * this.scale) {
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
