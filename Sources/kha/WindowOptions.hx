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

typedef RendererOptions = {
	?textureFormat: TextureFormat, // TextureFormat.RGBA32
	?depthStencilFormat: DepthStencilFormat, // DepthStencilFormat.DepthOnly
	?samplesPerPixel: Int, // 0
}

typedef WindowedModeOptions = {
	?minimizable: Bool, // true
	?maximizable: Bool, // false
	?resizable: Bool, // false
}

// These options are hints only, the target may reject or ignore specific settings when not applicable
// They are pretty much intended for desktop targets only
typedef WindowOptions = {
	width: Int,
	height: Int,

	?mode: Mode, // Windowed
	?title: String, // added to applications title
	?x: Position, // Center
	?y: Position, // Center
	?targetDisplay: TargetDisplay, // Primary

	?rendererOptions: RendererOptions,
	?windowedModeOptions: WindowedModeOptions,
}
