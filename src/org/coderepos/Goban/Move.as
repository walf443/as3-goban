package {
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.MouseEvent;
  public class Move extends Sprite {
    private var scale:int;
    private var colors:Array = [0xeeaa44, 0x000000, 0xffffff];
    private var board:Goban;
    public function Move(board:Goban, h:int, v:int, type:int, scale:int) {
      this.h = h;
      this.v = v;
      this.x = h * scale;
      this.y = v * scale;
      this.move_type = type;
      this.scale = scale;
      this.board = board;
    }

    // 0 = null, 1 = black, 2 = white 
    private var move_type:int;
    public function set type(num:int):void {
      if ( isDame() && num ) {
        if ( !( board.prohibit_area_of[num] && board.prohibit_area_of[num][0] == h && board.prohibit_area_of[num][1] == v ) ) {
          move_type = num;
          board.initMemoizeIsAliveOf();
          searchDeadArea(move_type);
          board.initMemoizeIsAliveOf();
          if ( isAlive(move_type) ) {
            board.counter = board.opposite_color_of(num);
          } else {
            move_type = 0;
          }
        }
      } else if ( !num ) {
        move_type = 0;
      }
      show();
    }
    public function get type():int {
      return move_type;
    }

    // horizontal
    private var horizontal:int;
    public function set h(num:int):void {
      horizontal = num;
      this.x = num * scale;
    }
    public function get h():int {
      return horizontal;
    }

    // vertical
    private var vertical:int;
    public function set v(num:int):void {
      vertical = num;
      this.y = num * scale;
    }
    public function get v():int {
      return vertical;
    }

    public function get color():int {
      return colors[type];
    }

    public function show():void {
      graphics.lineStyle(1, 0xeeaa44);
      graphics.beginFill(color);
      if ( type == 0 ) {
        graphics.drawRect(0, 0, scale, scale);
        drawSceneLine();
        drawScenePoint();
      } else {
        graphics.drawCircle(scale/2, scale/2, scale/2);
      }
      addEventListener(MouseEvent.CLICK, onClick);
    }

    private function onClick(event:Event):void {
      type = board.counter;
    }

    private function drawSceneLine():void {
      graphics.lineStyle(1, 0x000000);
      if ( h == 0 ) {
        graphics.moveTo(scale/2, scale/2);
        graphics.lineTo(scale, scale/2);
      } else if ( h == 18 ) {
        graphics.moveTo(0, scale/2);
        graphics.lineTo(scale/2, scale/2);
      } else {
        graphics.moveTo(0, scale/2);
        graphics.lineTo(scale, scale/2);
      }
      if ( v == 0 ) {
        graphics.moveTo(scale/2, scale/2);
        graphics.lineTo(scale/2, scale);
      } else if ( v == 18 ) {
        graphics.moveTo(scale/2, 0);
        graphics.lineTo(scale/2, scale/2);
      } else {
        graphics.moveTo(scale/2, 0);
        graphics.lineTo(scale/2, scale);
      }
    }

    private function drawScenePoint():void{
      graphics.lineStyle(1, 0x000000);
      var point:Array = [
        [3, 3],
        [3, 15],
        [15, 3],
        [15, 15],
        [9, 9],
        [3, 9],
        [9, 3],
        [15, 9],
        [9, 15]
      ];

      for (var i:int = 0; i < point.length; i++ ) {
        if ( h  == point[i][0] && v  == point[i][1] ) {
          graphics.drawCircle(scale/2, scale/2, scale/10);
        }
      }
    }

    public function searchDeadArea(target_type:int):void {
      var opposit_color:int = board.opposite_color_of(target_type);
      var prev_agehama:int = board.agehama[opposit_color];
      if ( h - 1 >= 0 ) {
        if ( board.data[h-1][v].type == opposit_color ) {
          if ( board.data[h-1][v].isDead(opposit_color) ) {
            board.data[h-1][v].takeDeadArea();
          }
        }
      }

      if ( h + 1 <= 18 ) {
        if ( board.data[h+1][v].type == opposit_color ) {
          if ( board.data[h+1][v].isDead(opposit_color) ) {
            board.data[h+1][v].takeDeadArea();
          }
        }
      }

      if ( v - 1 >= 0 ) {
        if ( board.data[h][v-1].type == opposit_color ) {
          if ( board.data[h][v-1].isDead(opposit_color) ) {
            board.data[h][v-1].takeDeadArea();
          }
        }
      }

      if ( v + 1 <= 18 ) {
        if ( board.data[h][v+1].type == opposit_color ) {
          if ( board.data[h][v+1].isDead(opposit_color) ) {
            board.data[h][v+1].takeDeadArea();
          }
        }
      }

      if ( ( board.agehama[opposit_color] - prev_agehama ) != 1 ) {
        board.prohibit_area_of[opposit_color] = null;
      }
    }

    // FIXME: it may cause stack heap error.
    public function takeDeadArea():void {
      var target_type:int = type;
      type = 0;
      board.agehama[target_type]++;
      var is_only_this:Boolean = true;
      if ( h - 1 >= 0 ) {
        if ( board.data[h-1][v].type == target_type ) {
          is_only_this = false;
          board.data[h-1][v].takeDeadArea();
        }
      }

      if ( h + 1 <= 18 ) {
        if ( board.data[h+1][v].type == target_type ) {
          is_only_this = false;
          board.data[h+1][v].takeDeadArea();
        }
      }

      if ( v - 1 >= 0 ) {
        if ( board.data[h][v-1].type == target_type ) {
          is_only_this = false;
          board.data[h][v-1].takeDeadArea();
        }
      }

      if ( v + 1 <= 18 ) {
        if ( board.data[h][v+1].type == target_type ) {
          is_only_this = false;
          board.data[h][v+1].takeDeadArea();
        }
      }

      if ( is_only_this ) {
        board.prohibit_area_of[target_type] = [h, v];
      }
    }

    public function isAlive(target_type:int):Boolean {
      if ( board.memoize_is_alive_of[h][v] != null ) {
        return board.memoize_is_alive_of[h][v];
      }

      // 駄目さえ見つかれば良いので、幅優先の方が効率が良いはず
      if ( h - 1 >= 0 ) {
        if ( board.data[h-1][v].isDame() ) {
          board.memoize_is_alive_of[h][v] = true;
          return true;
        }
      }
      if ( h + 1 <= 18 ) {
        if ( board.data[h+1][v].isDame() ) {
          board.memoize_is_alive_of[h][v] = true;
          return true;
        }
      }

      if ( v - 1 >= 0 ) {
        if ( board.data[h][v-1].isDame() ) {
          board.memoize_is_alive_of[h][v] = true;
          return true;
        }
      }

      if ( v + 1 <= 18 ) {
        if ( board.data[h][v+1].isDame() ) {
          board.memoize_is_alive_of[h][v] = true;
          return true;
        }
      }

      // XXX: too import to privent stack over flow.
      board.memoize_is_alive_of[h][v] = false;
      // 駄目がみつからなければ、別の色か駄目にたどり着くまで再帰的に探索
      if ( h - 1 >= 0 ) {
        if ( board.data[h-1][v].type == target_type ) {
          if ( board.data[h-1][v].isAlive(target_type) ) {
            board.memoize_is_alive_of[h][v] = true;
            return true;
          }
        }
      }
      if ( h + 1 <= 18 ) {
        if ( board.data[h+1][v].type == target_type ) {
          if ( board.data[h+1][v].isAlive(target_type) ) {
            board.memoize_is_alive_of[h][v] = true;
            return true;
          }
        }
      }
      if ( v - 1 >= 0 ) {
        if ( board.data[h][v-1].type == target_type ) {
          if ( board.data[h][v-1].isAlive(target_type) ) {
            board.memoize_is_alive_of[h][v] = true;
            return true;
          }
        }
      }
      if ( v + 1 <= 18 ) {
        if ( board.data[h][v+1].type == target_type ) {
          if ( board.data[h][v+1].isAlive(target_type) ) {
            board.memoize_is_alive_of[h][v] = true;
            return true;
          }
        }
      }

      board.memoize_is_alive_of[h][v] = false;
      return false;
    }

    public function isDead(target_type:int):Boolean {
      return !isAlive(target_type);
    }

    public function isDame():Boolean {
      return !type;
    }

  }
}
