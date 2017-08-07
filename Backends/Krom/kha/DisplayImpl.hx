package kha;

class DisplayImpl {
    public static function count(): Int {
        return Krom.displayCount();
    }

    public static function width(index: Int): Int {
        return Krom.displayWidth(index);
    }

    public static function height(index: Int): Int {
        return Krom.displayHeight(index);
    }

    public static function x(index: Int): Int {
        return Krom.displayX(index);
    }

    public static function y(index: Int): Int {
        return Krom.displayY(index);
    }

    public static function isPrimary(index: Int): Bool {
        return Krom.displayIsPrimary(index);
    }
}
