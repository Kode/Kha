package kha;

class Display {
	public static var count(get, never) : Int;

    public static function width( index : Int ) : Int {
        return DisplayImpl.width(index);
    }

    public static function height( index : Int ) : Int {
        return DisplayImpl.height(index);
    }
	
	public static function widthPrimary() : Int {
        return DisplayImpl.widthPrimary();
    }

    public static function heightPrimary() : Int {
        return DisplayImpl.heightPrimary();
    }

	static inline function get_count() : Int {
		return DisplayImpl.count();
	}
}
