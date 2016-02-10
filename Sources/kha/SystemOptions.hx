package kha;

enum WindowMode {
    Windowed;			// current windowed mode
    BorderlessWindow;	// window without all the system chrome
    Fullscreen;			// exclusive fullscreen mode (switches monitor resolution)
}

enum WindowPosition {
	Center;
	Fixed(v : Int);		// TODO (DK) should be relative to TargetDisplay?
}

enum TargetDisplay {
	Main;				// TODO (DK) whatever is set as 'Use this as main display' in windows; does this exist for linux as well?
	Custom(v : Int);
}

enum WindowFlags {
	Resizable;
	Minimizable;
	Maximizable;
}

// (DK)
//	-these options are hints only, the target may reject or ignore specific settings when not applicable
//	-they are mainly intended for desktop platforms anyway
class SystemOptions {
	public var title : String;
	public var x : WindowPosition = Center;
	public var y : WindowPosition = Center;
	public var width : Int;
	public var height : Int;

	public var targetDisplay : TargetDisplay = Main;
	public var windowMode : WindowMode = Windowed;

	public var minimizable : Bool = true;
	public var maximizable : Bool = false;
	public var resizable : Bool = false;


    public function new( title : String, width : Int = 800, height : Int = 600 ) {
		this.title = title;
		this.width = width;
		this.height = height;
    }

	public function setWindowMode( mode : WindowMode ) : SystemOptions {
		this.windowMode = mode;
		return this;
	}

	public function setWindowPosition( x : WindowPosition, y : WindowPosition ) : SystemOptions {
		this.x = x;
		this.y = y;
		return this;
	}

	public function setTargetDisplay( display : TargetDisplay ) : SystemOptions {
		this.targetDisplay = display;
		return this;
	}

	public function setWindowFlags( resizable : Bool, minimizable : Bool, maximizable : Bool ) : SystemOptions {
		this.resizable = resizable;
		this.minimizable = minimizable;
		this.maximizable = maximizable;
		return this;
	}
}

/*class Main {
	public static function main() {
		var options = new SystemOptions('SystemOptions Example', 512, 512)
			.setWindowMode(BorderlessWindow)
			.setWindowPosition(Fixed(0), Fixed(0))
			;

		System.initEx(options, system_initializedHandler);
	}

	static function system_initializedHandler() {
		// do your setup stuff
	}
}
*/
