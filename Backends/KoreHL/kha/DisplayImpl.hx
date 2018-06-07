package kha;

class DisplayImpl {
    public static function count() : Int {
        return kore_display_count();
    }

    public static function width(index: Int): Int {
        return kore_display_width(index);
    }

    public static function height(index: Int): Int {
        return kore_display_height(index);
    }

    public static function x(index: Int): Int {
        return kore_display_x(index);
    }

    public static function y(index: Int): Int {
        return kore_display_y(index);
    }

    public static function isPrimary(index: Int): Bool {
        return kore_display_is_primary(index);
    }

    @:hlNative("std", "kore_display_count") static function kore_display_count(): Int { return 0; }
    @:hlNative("std", "kore_display_width") static function kore_display_width(index: Int): Int { return 0; }
    @:hlNative("std", "kore_display_height") static function kore_display_height(index: Int): Int { return 0; }
    @:hlNative("std", "kore_display_x") static function kore_display_x(index: Int): Int { return 0; }
    @:hlNative("std", "kore_display_y") static function kore_display_y(index: Int): Int { return 0; }
    @:hlNative("std", "kore_display_is_primary") static function kore_display_is_primary(index: Int): Bool { return false; }
}
