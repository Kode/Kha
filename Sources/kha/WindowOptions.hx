package kha;

@:structInit
class WindowOptions {
	public static inline var FeatureResizable = 1;
	public static inline var FeatureMinimizable = 2;
	public static inline var FeatureMaximizable = 4;
	public static inline var FeatureBorderless = 8;
	public static inline var FeatureOnTop = 16;

	@:optional public var title: String = "Kha";
	@:optional public var x: Int = -1;
	@:optional public var y: Int = -1;
	@:optional public var width: Int = 800;
	@:optional public var height: Int = 600;
	@:optional public var display: Display = null;
	@:optional public var visible: Bool = true;
	@:optional public var windowFeatures: Int = FeatureResizable | FeatureMaximizable | FeatureMinimizable;
	@:optional public var mode: WindowMode = Windowed;

	public function new(title: String = "Kha", ?x: Int = -1, ?y: Int = -1, ?width: Int = 800, ?height: Int = 600, display: Display = null,
	?visible: Bool = true, ?windowFeatures: Int = FeatureResizable | FeatureMaximizable | FeatureMinimizable, ?mode: WindowMode = WindowMode.Windowed) {
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
