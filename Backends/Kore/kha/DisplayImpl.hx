package kha;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Display.h>
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
}
