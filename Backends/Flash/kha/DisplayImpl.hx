package kha;

class DisplayImpl {
    public static function count() : Int {
        return 1;
    }

    public static function width(index: Int): Int {
        return flash.Lib.current.stage.fullScreenWidth;
    }

    public static function height(index: Int): Int {
        return flash.Lib.current.stage.fullScreenHeight;
    }

    public static function x(index: Int): Int {
        return Std.int(flash.Lib.current.stage.x);
    }

    public static function y(index: Int): Int {
        return Std.int(flash.Lib.current.stage.y);
    }

    public static function isPrimary(index: Int): Bool {
        return true; // TODO (DK) is there any way to figure out what display flash opened on?
    }
}
