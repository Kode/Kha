package system.windows;
import system.windows.input.Cursor;

@:native("System.Windows.FrameworkElement")
extern class FrameworkElement {
	public var Cursor: Cursor;
	public var Width: Float;
	public var Height: Float;
}