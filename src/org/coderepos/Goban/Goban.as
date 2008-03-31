package {
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.MouseEvent;
  public class Goban extends Sprite {
    private var data:Array = [];
    private var size:int = 10;

    private var colors:Array = [ 0xeeaa44, 0x000000, 0xffffff ];
    private var counter:int = 1;
    private var agehama:Array = [null, 0, 0];
    private var memoize_is_dead_of:Array = [];

    public function Goban() {
      for ( var i:int = 0; i < 19; i++ ) {
        data[i] = [];
        for ( var j:int = 0; j < 19; j++ ) {
          data[i][j] = 0;
        }
      }

      for ( var x:int = 0; x < 19; x++ ){
        for ( var y:int = 0; y < 19; y++ ) {
          drawScene(x * size, y * size, data[y][x], new Sprite());
        }
      }
    }

    public function updateScene(x:int, y:int, color:int, sp:Sprite):void {
      if (data[y][x] && color == 0) {
        data[y][x] = color;
        drawScene(x * size, y * size, color, sp);
      } else if ( !data[y][x] && !( prohibit_area_of[color] && prohibit_area_of[color][0] == x && prohibit_area_of[color][1] == y ) ) {
        initMemoizeIsDeadOf();
        data[y][x] = color;
        drawScene(x * size, y * size, color, sp);
        searchDeadArea(x, y, color);
        if ( isDead(x, y, color) ) {
          updateScene(x, y, 0, sp);
        } else {
          counter = ( counter == 1 ) ? 2 : 1;
        }
      }
    }

    private function searchDeadArea(x:int, y:int, color:int):void {
      var target_color:int = opposite_color_of(color);
      initMemoizeIsDeadOf();
      var prev_agehama:int = agehama[target_color];
      if (x - 1 >= 0 ) {
        if ( data[y][x-1] == target_color ) {
          if ( isDead(x-1, y, target_color) ) {
            removeDeadArea(x-1, y, target_color, new Sprite());
          }
        }
      }
      if (x + 1 <= 18 ) {
        if ( data[y][x+1] == target_color ) {
          if ( isDead(x+1, y, target_color) ) {
            removeDeadArea(x+1, y, target_color, new Sprite());
          }
        }
      }
      if (y - 1 >= 0 ) {
        if ( data[y-1][x] == target_color ) {
          if ( isDead(x, y-1, target_color) ) {
            removeDeadArea(x, y-1, target_color, new Sprite());
          }
        }
      }
      if (y + 1 <= 18 ) {
        if ( data[y+1][x] == target_color ) {
          if ( isDead(x, y+1, target_color) ) {
            removeDeadArea(x, y+1, target_color, new Sprite());
          }
        }
      }

      // 一つ殺したとき以外は着手禁止点は設定されない
      if ( (agehama[target_color] - prev_agehama) != 1 ) {
        prohibit_area_of[target_color] = null;
      }
    }

    private function initMemoizeIsDeadOf():void {
      memoize_is_dead_of = [];
      for (var i:int = 0; i < 19; i++ ) {
        memoize_is_dead_of[i] = [];
        for ( var j:int = 0; j < 19; j++ ) {
          memoize_is_dead_of[i][j] = null;
        }
      }
    }

    private var prohibit_area_of:Array = [null, null, null];
    private function removeDeadArea(x:int, y:int, color:int, sp:Sprite):void {
      
      if ( color == data[y][x] ) {
        agehama[color]++;
        updateScene(x, y, 0, sp);
        var is_only_this:Boolean = true;
        if ( x - 1 >= 0 ) {
          if ( data[y][x-1] == color ) {
            is_only_this = false;
            removeDeadArea(x-1, y, color, new Sprite());
          }
        }
        if ( x + 1 <= 18 ) {
          if ( data[y][x+1] == color ) {
            is_only_this = false;
            removeDeadArea(x+1, y, color, new Sprite());
          }
        }
        if ( y - 1 >= 0 ) {
          if ( data[y-1][x] == color ) {
            is_only_this = false;
            removeDeadArea(x, y-1, color, new Sprite());
          }
        }
        if ( y + 1 <= 18 ) {
          if ( data[y+1][x] == color ) {
            is_only_this = false;
            removeDeadArea(x, y+1, color, new Sprite());
          }
        }

        if ( is_only_this ) {
          prohibit_area_of[color] = [x, y];
        }
      }
    }

    private function opposite_color_of(color:int):int {
      switch (color) {
        case 1:
          return 2;
        case 2:
          return 1;
        default :
          return 0;
      };
    }

    public function isDead(x:int, y:int, color:int):Boolean{
      trace(memoize_is_dead_of);
      if ( memoize_is_dead_of[y][x] != null ) {
        return memoize_is_dead_of[y][x];
      }

      if ( data[y][x] == color ) {
        memoize_is_dead_of[y][x] = true;
      }

      if (x - 1 >= 0 ) {
        if (!data[y][x-1]) {
          memoize_is_dead_of[y][x] = false;
          return false;
        } else if ( data[y][x-1] == color ) {
          if ( !isDead(x-1, y, color) ) {
            memoize_is_dead_of[y][x] = false;
            return false;
          }
        }
      }
      if (x + 1 <= 18 ) {
        if (!data[y][x+1]) {
          memoize_is_dead_of[y][x] = false;
          return false;
        } else if ( data[y][x+1] == color ) {
          if ( !isDead(x+1, y, color) ) {
            memoize_is_dead_of[y][x] = false;
            return false;
          }
        }
      }

      if (y - 1 >= 0 ) {
        if (!data[y-1][x]) {
          memoize_is_dead_of[y][x] = false;
          return false;
        } else if ( data[y-1][x] == color ) {
          if ( !isDead(x, y-1, color) ) {
            memoize_is_dead_of[y][x] = false;
            return false;
          }
        }
      }

      if (y + 1 <= 18 ) {
        if (!data[y+1][x]) {
          memoize_is_dead_of[y][x] = false;
          return false;
        } else if ( data[y+1][x] == color ) {
          if ( !isDead(x, y+1, color) ) {
            memoize_is_dead_of[y][x] = false;
            return false;
          }
        }
      }

      memoize_is_dead_of[y][x] = true;
      return true;
    }

    public function drawScene(x:int, y:int, color:int, sp:Sprite):void {
      sp.graphics.lineStyle(1, 0xeeaa44);
      sp.graphics.beginFill(colors[color]);
      if ( color == 0 ) {
        sp.graphics.drawRect(0, 0, size, size);

        drawSceneLine(x/size, y/size, sp);
        drawScenePoint(x/size, y/size, sp);

      } else {
        sp.graphics.drawCircle(size/2, size/2, size/2);
      }
      sp.x = x;
      sp.y = y;
      sp.addEventListener(MouseEvent.CLICK, onClick);
      addChild(sp);
    }

    private function drawSceneLine(x:int, y:int, sp:Sprite):void{
        sp.graphics.lineStyle(1, 0x000000);
        if ( y == 0 ) {
          sp.graphics.moveTo(size/2, size/2);
          sp.graphics.lineTo(size/2, size);
        } else if ( y  == 18 ) {
          sp.graphics.moveTo(size/2, 0);
          sp.graphics.lineTo(size/2, size/2);
        } else {
          sp.graphics.moveTo(size/2, 0);
          sp.graphics.lineTo(size/2, size);
        }
        if ( x  == 0 ) {
          sp.graphics.moveTo(size/2, size/2);
          sp.graphics.lineTo(size, size/2);
        } else if ( x  == 18 ) {
          sp.graphics.moveTo(0, size/2);
          sp.graphics.lineTo(size/2, size/2);
        } else {
          sp.graphics.moveTo(0, size/2);
          sp.graphics.lineTo(size, size/2);
        }
    }

    private function drawScenePoint(x:int, y:int, sp:Sprite):void{
        sp.graphics.lineStyle(1, 0x000000);
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
          if ( x  == point[i][0] && y  == point[i][1] ) {
            sp.graphics.drawCircle(size/2, size/2, size/10);
          }
        }
    }

    private function onClick(event:Event):void {
      updateScene(event.target.x / size, event.target.y / size, counter, new Sprite());
    }

  }
}
