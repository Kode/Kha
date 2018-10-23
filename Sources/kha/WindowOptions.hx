package kha;
@:enum abstract WindowFeatures(Int) from Int to Int {
	var FeatureResizable = 1;
	var FeatureMinimizable = 2;
	var FeatureMaximizable = 4;
	var FeatureBorderless = 8;
	var FeatureOnTop = 16;
}

@:structInit
class WindowOptions {
	@:optional public var title: String = null;
	@:optional public var x: Int = -1;
	@:optional public var y: Int = -1;
	@:optional public var width: Int = 800;
	@:optional public var height: Int = 600;
	@:optional public var display: Display = null;
	@:optional public var visible: Bool = true;
	@:optional public var windowFeatures:WindowFeatures = FeatureResizable | FeatureMaximizable | FeatureMinimizable;
	@:optional public var mode: WindowMode = Windowed;

	public function new(title: String = null, ?x: Int = -1, ?y: Int = -1, ?width: Int = 800, ?height: Int = 600, display: Display = null,
	?visible: Bool = true, ?windowFeatures:WindowFeatures = FeatureResizable | FeatureMaximizable | FeatureMinimizable, ?mode: WindowMode = WindowMode.Windowed) {
		this.title = title;
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		this.display = display == null ? Display.primary : display;
		this.visible = visible;
		this.windowFeatures = windowFeatures;
		this.mode = mode;
	}
}
