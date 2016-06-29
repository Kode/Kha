package kha;

import kha.graphics4.TextureFormat;
import kha.graphics4.DepthStencilFormat;

enum Mode {
    Window;				// Window with borders
    BorderlessWindow;	// Window without borders
    Fullscreen;			// Exclusive fullscreen mode (switches monitor resolution), (a win32 feature only?)
}

enum Position {
	Center;				// Centered on TargetDisplay
	Fixed(v: Int);		// Fixed position relative to TargetDisplay
}

enum TargetDisplay {
	Primary;			// Whatever monitor is set as 'Use this as primary display' your system settings
	ById(id: Int);		// id = the number that shows up on 'identify screen' in your system settings
}

@:structInit
class RendererOptions {
	@:optional public var textureFormat: TextureFormat; // TextureFormat.RGBA32
	@:optional public var depthStencilFormat: DepthStencilFormat; // DepthStencilFormat.DepthOnly
	@:optional public var samplesPerPixel: Int; // 0
}

@:structInit
class WindowedModeOptions {
	@:optional public var minimizable: Bool; // true
	@:optional public var maximizable: Bool; // false
	@:optional public var resizable: Bool; // false
}

// These options are hints only, the target may reject or ignore specific settings when not applicable
// They are pretty much intended for desktop targets only
@:structInit
class WindowOptions {
	public var width: Int;
	public var height: Int;

	@:optional public var mode: Mode; // Windowed
	@:optional public var title: String; // added to applications title
	@:optional public var x: Position; // Center
	@:optional public var y: Position; // Center
	@:optional public var targetDisplay: TargetDisplay; // Primary

	@:optional public var rendererOptions: RendererOptions;
	@:optional public var windowedModeOptions: WindowedModeOptions;
}
