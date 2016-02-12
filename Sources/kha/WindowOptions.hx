package kha;

import kha.graphics4.TextureFormat;
import kha.WindowOptions.RendererOptions;

// (DK) only a single window can be fullscreen

enum Mode {
    Windowed;			// current windowed mode
    BorderlessWindow;	// window without all the system chrome
    Fullscreen;			// exclusive fullscreen mode (switches monitor resolution)
}

enum Position {
	Center;
	Fixed(v : Int);		// TODO (DK) should be relative to TargetDisplay?
}

enum TargetDisplay {
	Main;				// TODO (DK) whatever is set as 'Use this as main display' in windows; does this exist for linux as well?
	Custom(v : Int);
}

// only for Mode.Windowed
enum WindowedFlags {
	Resizable;
	Minimizable;
	Maximizable;
}

class RendererOptions {
	public var width : Int;
	public var height : Int;
	public var textureFormat : TextureFormat = TextureFormat.RGBA32;
	public var depthStencilFormat : DepthStencilFormat = DepthStencilFormat.DepthOnly;

	public function new( width : Int, height : Int ) {
		this.width = width;
		this.height = height;
	}

	public function setTextureFormat( format : TextureFormat ) : RendererOptions {
		this.textureFormat = format;
		return this;
	}

	public function setDepthStencilFormat( format : DepthStencilFormat ) : RendererOptions {
		this.depthStencilFormat = format;
		return this;
	}
}

// (DK)
//	-these options are hints only, the target may reject or ignore specific settings when not applicable
//	-they are mainly intended for desktop platforms anyway
class WindowOptions {
	public var title : String;
	public var x : Position = Center;
	public var y : Position = Center;
	public var width : Int;
	public var height : Int;

	public var targetDisplay : TargetDisplay = Main;
	public var mode : Mode = Windowed;

	public var minimizable : Bool = true;
	public var maximizable : Bool = false;
	public var resizable : Bool = false;

	public var rendererOptions : RendererOptions;

    public function new( title : String, width : Int = 800, height : Int = 600 ) {
		this.title = title;
		this.width = width;
		this.height = height;
		this.rendererOptions = new RendererOptions(width, height);
    }

	public function setMode( mode : Mode ) : WindowOptions {
		this.mode = mode;
		return this;
	}

	public function setPosition( x : Position, y : Position ) : WindowOptions {
		this.x = x;
		this.y = y;
		return this;
	}

	public function setTargetDisplay( display : TargetDisplay ) : WindowOptions {
		this.targetDisplay = display;
		return this;
	}

	public function setWindowedFlags( flag : WindowedFlags, value : Bool ) : WindowOptions {
		switch (flag) {
			case Resizable: resizable = value;
			case Minimizable: minimizable = value;
			case Maximizable: maximizable = value;
		}

		return this;
	}

	//public function setWindowFlags( resizable : Bool, minimizable : Bool, maximizable : Bool ) : WindowOptions {
		//this.resizable = resizable;
		//this.minimizable = minimizable;
		//this.maximizable = maximizable;
		//return this;
	//}
}

/*class Main {
	public static function main() {
		var options = new WindowOptions('WindowOptions Example', 512, 512)
			.setWindowMode(BorderlessWindow)
			.setWindowPosition(Fixed(0), Fixed(0))
			;

		System.initEx([options], system_initializedHandler);
	}

	static function system_initializedHandler( window : kha.Window ) {
		// do your setup stuff
	}
}
*/
