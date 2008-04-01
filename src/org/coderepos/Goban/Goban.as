package {
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.MouseEvent;
  public class Goban extends Sprite {
    public var data:Array = [];
    private var size:int = 15;

    private var colors:Array = [ 0xeeaa44, 0x000000, 0xffffff ];
    public var counter:int = 1;
    public var agehama:Array = [null, 0, 0];
    public var memoize_is_alive_of:Array = [];
    public var prohibit_area_of:Array = [null, null, null];

    public function Goban() {
      for ( var i:int = 0; i < 19; i++ ) {
        data[i] = [];
        for ( var j:int = 0; j < 19; j++ ) {
          data[i][j] = new Move(this, i,j, 0, size);
          data[i][j].show();
          addChild(data[i][j]);
        }
      }
    }

    public function initMemoizeIsAliveOf():void {
      memoize_is_alive_of = [];
      for (var i:int = 0; i < 19; i++ ) {
        memoize_is_alive_of[i] = [];
        for ( var j:int = 0; j < 19; j++ ) {
          memoize_is_alive_of[i][j] = null;
        }
      }
    }

    public function opposite_color_of(color:int):int {
      switch (color) {
        case 1:
          return 2;
        case 2:
          return 1;
        default :
          return 0;
      };
    }

  }
}
