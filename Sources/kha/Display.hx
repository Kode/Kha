package kha;

extern class Display {
	public static var primary(get, never): Display;
	public static var all(get, never): Array<Display>;
	public var available(get, never): Bool;
	public var name(get, never): String;
	public var x(get, never): Int;
	public var y(get, never): Int;
	public var width(get, never): Int;
	public var height(get, never): Int;
	public var frequency(get, never): Int;
	public var pixelsPerInch(get, never): Int;
	public var modes(get, never): Array<DisplayMode>;
}
