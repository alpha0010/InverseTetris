// Generated by CoffeeScript 1.4.0
(function() {
  var TetrisAI;

  TetrisAI = (function() {

    TetrisAI.prototype.lastTime = -1;

    TetrisAI.prototype.moveCache = null;

    function TetrisAI() {
      var x;
      x = 1;
    }

    TetrisAI.prototype.chooseMove = function(currentBoard, block, timeCode) {
      var bestMove, minVal, oldGeom, tstBlck, tstBrd, tstVal;
      tstBrd = this.cloneBoard(currentBoard);
      tstBlck = this.cloneBlock(block);
      minVal = this.scoreMove(tstBrd, tstBlck);
      bestMove = 0;
      tstVal = this.testMoveLeft(tstBrd, tstBlck);
      if (tstVal < minVal) {
        minVal = tstVal;
        bestMove = 1;
      }
      tstBlck.column = block.column;
      tstVal = this.testMoveRight(tstBrd, tstBlck);
      if (tstVal < minVal) {
        minVal = tstVal;
        bestMove = 2;
      }
      if (block.orientations > 1) {
        tstVal = this.testRotateCCW(tstBrd, tstBlck);
        if (tstVal < minVal) {
          minVal = tstVal;
          bestMove = 3;
        }
        if (block.orientations > 2) {
          tstVal = this.testRotateCW(tstBrd, tstBlck);
          if (tstVal < Number.MAX_VALUE) {
            oldGeom = tstBlck.geometry;
            tstBlck.geometry = this.rotateArray(tstBlck.geometry);
            tstVal = Math.min(tstVal, this.testRotateCW(tstBrd, tstBlck));
            tstBlck.geometry = oldGeom;
          }
          if (tstVal < minVal) {
            minVal = tstVal;
            bestMove = 4;
          }
        }
      }
      return bestMove;
      if (timeCode === this.lastTime) {
        if (this.moveCache.length > 0) {
          return this.moveCache.shift();
        } else {
          return -1;
        }
      }
      return -1;
    };

    TetrisAI.prototype.testRotateCCW = function(board, block) {
      var minVal, oldCol, oldGeom;
      oldGeom = block.geometry;
      oldCol = block.column;
      minVal = Number.MAX_VALUE;
      block.geometry = this.rotateArray(this.rotateArray(this.rotateArray(block.geometry)));
      if (!this.blockIntersects(board, block, block.row, block.column)) {
        minVal = this.scoreMove(board, block);
        minVal = Math.min(minVal, this.testMoveRight(board, block));
        block.column = oldCol;
        minVal = Math.min(minVal, this.testMoveLeft(board, block));
      }
      block.column = oldCol;
      block.geometry = oldGeom;
      return minVal;
    };

    TetrisAI.prototype.testRotateCW = function(board, block) {
      var minVal, oldCol, oldGeom;
      oldGeom = block.geometry;
      oldCol = block.column;
      minVal = Number.MAX_VALUE;
      block.geometry = this.rotateArray(block.geometry);
      if (!this.blockIntersects(board, block, block.row, block.column)) {
        minVal = this.scoreMove(board, block);
        minVal = Math.min(minVal, this.testMoveRight(board, block));
        block.column = oldCol;
        minVal = Math.min(minVal, this.testMoveLeft(board, block));
      }
      block.column = oldCol;
      block.geometry = oldGeom;
      return minVal;
    };

    TetrisAI.prototype.testMoveLeft = function(board, block) {
      var minVal;
      minVal = Number.MAX_VALUE;
      while (block.column > 0) {
        block.column -= 1;
        if (this.blockIntersects(board, block, block.row, block.column)) {
          break;
        }
        minVal = Math.min(minVal, this.scoreMove(board, block));
      }
      return minVal;
    };

    TetrisAI.prototype.testMoveRight = function(board, block) {
      var minVal;
      minVal = Number.MAX_VALUE;
      while (block.column + block.geometry[0].length < board[0].length) {
        block.column += 1;
        if (this.blockIntersects(board, block, block.row, block.column)) {
          break;
        }
        minVal = Math.min(minVal, this.scoreMove(board, block));
      }
      return minVal;
    };

    TetrisAI.prototype.rotateArray = function(theArray) {
      var column, outArray, row, _i, _j, _ref, _ref1;
      outArray = [];
      for (row = _i = 0, _ref = theArray.length; 0 <= _ref ? _i < _ref : _i > _ref; row = 0 <= _ref ? ++_i : --_i) {
        for (column = _j = 0, _ref1 = theArray[row].length; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; column = 0 <= _ref1 ? ++_j : --_j) {
          if (row === 0) {
            outArray[column] = [];
          }
          outArray[column][row] = theArray[theArray.length - row - 1][column];
        }
      }
      return outArray;
    };

    TetrisAI.prototype.cloneBoard = function(board) {
      var column, out, row, _i, _j, _ref, _ref1;
      out = [];
      for (row = _i = 0, _ref = board.length; 0 <= _ref ? _i < _ref : _i > _ref; row = 0 <= _ref ? ++_i : --_i) {
        out[row] = [];
        for (column = _j = 0, _ref1 = board[row].length; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; column = 0 <= _ref1 ? ++_j : --_j) {
          out[row][column] = board[row][column].isFull;
        }
      }
      return out;
    };

    TetrisAI.prototype.cloneBlock = function(block) {
      var column, out, row, _i, _j, _ref, _ref1;
      out = {
        row: block.row,
        column: block.column,
        geometry: null
      };
      out.geometry = [];
      for (row = _i = 0, _ref = block.geometry.length; 0 <= _ref ? _i < _ref : _i > _ref; row = 0 <= _ref ? ++_i : --_i) {
        out.geometry[row] = [];
        for (column = _j = 0, _ref1 = block.geometry[row].length; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; column = 0 <= _ref1 ? ++_j : --_j) {
          out.geometry[row][column] = block.geometry[row][column] === 1;
        }
      }
      return out;
    };

    TetrisAI.prototype.scoreMove = function(currentBoard, block) {
      return this.evaluate(this.testDrop(currentBoard, block));
    };

    TetrisAI.prototype.testDrop = function(currentBoard, block) {
      var column, delta, out, row, shapeColumn, shapeRow, _base, _i, _j, _k, _l, _name, _ref, _ref1, _ref2, _ref3;
      delta = 0;
      while (!this.blockIntersects(currentBoard, block, block.row + delta + 1, block.column)) {
        ++delta;
      }
      out = [];
      for (row = _i = 0, _ref = currentBoard.length; 0 <= _ref ? _i < _ref : _i > _ref; row = 0 <= _ref ? ++_i : --_i) {
        out[row] = [];
        for (column = _j = 0, _ref1 = currentBoard[row].length; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; column = 0 <= _ref1 ? ++_j : --_j) {
          out[row][column] = currentBoard[row][column];
        }
      }
      for (shapeRow = _k = 0, _ref2 = block.geometry.length; 0 <= _ref2 ? _k < _ref2 : _k > _ref2; shapeRow = 0 <= _ref2 ? ++_k : --_k) {
        for (shapeColumn = _l = 0, _ref3 = block.geometry[shapeRow].length; 0 <= _ref3 ? _l < _ref3 : _l > _ref3; shapeColumn = 0 <= _ref3 ? ++_l : --_l) {
          (_base = out[shapeRow + block.row + delta])[_name = shapeColumn + block.column] || (_base[_name] = block.geometry[shapeRow][shapeColumn]);
        }
      }
      return out;
    };

    TetrisAI.prototype.blockIntersects = function(board, block, row, column) {
      var shapeColumn, shapeRow, _i, _j, _ref, _ref1;
      for (shapeRow = _i = 0, _ref = block.geometry.length; 0 <= _ref ? _i < _ref : _i > _ref; shapeRow = 0 <= _ref ? ++_i : --_i) {
        if (row + shapeRow < 0 || row + shapeRow >= board.length) {
          return true;
        }
        for (shapeColumn = _j = 0, _ref1 = block.geometry[shapeRow].length; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; shapeColumn = 0 <= _ref1 ? ++_j : --_j) {
          if (column + shapeColumn < 0 || column + shapeColumn >= board[0].length) {
            return true;
          }
          if (block.geometry[shapeRow][shapeColumn] && board[row + shapeRow][column + shapeColumn]) {
            return true;
          }
        }
      }
      return false;
    };

    TetrisAI.prototype.evaluate = function(board) {
      var column, pipeLen, pipeRow, row, score, _i, _j, _k, _l, _ref, _ref1, _ref2, _ref3;
      score = 0;
      this.checkLines(board);
      for (row = _i = 0, _ref = board.length; 0 <= _ref ? _i < _ref : _i > _ref; row = 0 <= _ref ? ++_i : --_i) {
        for (column = _j = 0, _ref1 = board[row].length; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; column = 0 <= _ref1 ? ++_j : --_j) {
          if (board[row][column]) {
            score += (board.length - row + 2) / 2 * this.calcColumnMultiplier(column, board[row].length);
          } else if (row > 0 && board[row - 1][column]) {
            score += 10;
          }
        }
      }
      for (column = _k = 0, _ref2 = board[0].length; 0 <= _ref2 ? _k < _ref2 : _k > _ref2; column = 0 <= _ref2 ? ++_k : --_k) {
        pipeLen = 0;
        pipeRow = -1;
        for (row = _l = 0, _ref3 = board.length; 0 <= _ref3 ? _l < _ref3 : _l > _ref3; row = 0 <= _ref3 ? ++_l : --_l) {
          if (!board[row][column] && (column === 0 || board[row][column - 1]) && (column === board[0].length - 1 || board[row][column + 1])) {
            if (pipeRow === -1) {
              pipeRow = row;
            }
            ++pipeLen;
          }
        }
        if (pipeLen > 1) {
          score += pipeLen * (board.length - pipeRow + 2) / 4;
        }
      }
      return score;
    };

    TetrisAI.prototype.calcColumnMultiplier = function(column, len) {
      var val;
      val = (column > len / 2 ? len - column - 1 : column) / len;
      return (val + 2) / 2.0;
    };

    TetrisAI.prototype.checkLines = function(board) {
      var row, _i, _ref;
      for (row = _i = 0, _ref = board.length; 0 <= _ref ? _i < _ref : _i > _ref; row = 0 <= _ref ? ++_i : --_i) {
        if (this.arrayIsFull(board[row])) {
          this.removeRow(board, row);
        }
      }
    };

    TetrisAI.prototype.arrayIsFull = function(theArray) {
      var filled, _i, _len;
      for (_i = 0, _len = theArray.length; _i < _len; _i++) {
        filled = theArray[_i];
        if (!filled) {
          return false;
        }
      }
      return true;
    };

    TetrisAI.prototype.removeRow = function(board, row) {
      var column, _i, _ref;
      board.splice(row, 1);
      board.splice(0, 0, []);
      for (column = _i = 0, _ref = board[1].length; 0 <= _ref ? _i < _ref : _i > _ref; column = 0 <= _ref ? ++_i : --_i) {
        board[0][column] = false;
      }
    };

    return TetrisAI;

  })();

  window.TetrisAI = TetrisAI;

}).call(this);
