package kha;

class DisplayImpl {
    public static function count() : Int {
        return 1;
        // return untyped __cpp__('Kore::Display::count()');
    }

    public static function width(index: Int): Int {
        return 640;
        // return untyped __cpp__('Kore::Display::width(index)');
    }

    public static function height(index: Int): Int {
        return 480;
        // return untyped __cpp__('Kore::Display::height(index)');
    }

    public static function x(index: Int): Int {
        return 0;
        // return untyped __cpp__('Kore::Display::x(index)');
    }

    public static function y(index: Int): Int {
        return 0;
        // return untyped __cpp__('Kore::Display::y(index)');
    }

    public static function isPrimary(index: Int): Bool {
        return true;
        // return untyped __cpp__('Kore::Display::isPrimary(index)');
    }
}
