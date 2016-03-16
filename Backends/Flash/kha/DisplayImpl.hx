package kha;

class DisplayImpl {
    public static function count() : Int {
        return 1;
    }

    public static function width( id : Int ) : Int {
        return flash.Lib.current.stage.fullScreenWidth;
    }

    public static function height( id : Int ) : Int {
        return flash.Lib.current.stage.fullScreenHeight;
    }
}
