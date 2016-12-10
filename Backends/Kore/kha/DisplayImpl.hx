package kha;

@:headerCode('
namespace Kore { namespace Display {
	int count();
	int width(int);
	int height(int);
	int widthPrimary();
	Int heightPrimary();
}}
')
class DisplayImpl {
    public static function count() : Int {
        return untyped __cpp__('Kore::Display::count()');
    }

    public static function width( index : Int ) : Int {
        return untyped __cpp__('Kore::Display::width(index)');
    }

    public static function height( index : Int ) : Int {
        return untyped __cpp__('Kore::Display::height(index)');
    }
	
	public static function widthPrimary() : Int {
        return untyped __cpp__('Kore::Display::widthPrimary()');
    }

    public static function heightPrimary() : Int {
        return untyped __cpp__('Kore::Display::heightPrimary()');
    }
}
