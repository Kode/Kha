package kha;

@:headerCode('
namespace Kore { namespace Display {
	int count();
	int width(int);
	int height(int);
    int x(int);
    int y(int);
    bool isPrimary(int);
}}
')
class DisplayImpl {
    public static function count() : Int {
        return untyped __cpp__('Kore::Display::count()');
    }

    public static function width(index: Int): Int {
        return untyped __cpp__('Kore::Display::width(index)');
    }

    public static function height(index: Int): Int {
        return untyped __cpp__('Kore::Display::height(index)');
    }

    public static function x(index: Int): Int {
        return untyped __cpp__('Kore::Display::x(index)');
    }

    public static function y(index: Int): Int {
        return untyped __cpp__('Kore::Display::y(index)');
    }

    public static function isPrimary(index: Int): Bool {
        return untyped __cpp__('Kore::Display::isPrimary(index)');
    }
}
