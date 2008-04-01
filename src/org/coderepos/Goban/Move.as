package {
  import flash.display.Sprite;
  public class Move extends Sprite {
    private var scale:int;
    private var colors:Array = [0xeeaa44, 0x000000, 0xffffff];
    public function Move(h:int, v:int, type:int, scale:int) {
      this.h = h;
      this.v = v;
      this.x = h * scale;
      this.y = v * scale;
      this.type = type;
      this.scale = scale;
    }

    // 0 = null, 1 = black, 2 = white 
    private var move_type:int;
    public function set type(num:int):void {
      move_type = num;
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
      graphics.lineStyle(1, color);
      graphics.beginFill(color);
      if ( type == 0 ) {
        graphics.drawRect(0, 0, scale, scale);
        drawSceneLine();
        drawScenePoint();
      } else {
        graphics.drawCircle(scale/2, scale/2, scale/2);
      }
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
  }
}
