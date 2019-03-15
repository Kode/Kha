package kha;
@:enum abstract WindowFeatures(Int) to Int {
    var None = 0;
    var FeatureResizable = 1;
    var FeatureMinimizable = 2;
    var FeatureMaximizable = 4;
    var FeatureBorderless = 8;
    var FeatureOnTop = 16;	
	
    function new (value:Int) {
        this = value;
    }
    
    @:op(A | B) static function or( a:WindowFeatures, b:WindowFeatures) : WindowFeatures;
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
	?visible: Bool = true, ?windowFeatures:WindowFeatures, ?mode: WindowMode = WindowMode.Windowed) {
		this.title = title;
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		this.display = display == null ? Display.primary : display;
		this.visible = visible;
		this.windowFeatures = (windowFeatures == null) ? WindowFeatures.FeatureResizable | WindowFeatures.FeatureMaximizable | WindowFeatures.FeatureMinimizable : windowFeatures;
		this.mode = mode;
	}
}
