package system.windows;

@:native("System.Windows.Window")
extern class Window extends FrameworkElement {
	public function AddChild(child : FrameworkElement) : Void;
}