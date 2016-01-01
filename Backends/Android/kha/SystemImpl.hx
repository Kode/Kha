package kha;
import com.ktxsoftware.kha.KhaActivity;
import kha.android.Graphics;
import kha.graphics4.Graphics2;
import kha.input.Keyboard;
import kha.input.Mouse;
import kha.input.Surface;

class SystemImpl {
	public static var w: Int = 640;
	public static var h: Int = 480;
	private static var startTime: Float;
	
	public static function getPixelWidth(): Int {
		return w;
	}
	
	public static function getPixelHeight(): Int {
		return h;
	}
	
	public static function getScreenRotation(): ScreenRotation {
		return ScreenRotation.RotationNone;
	}
	
	public static function getFrequency(): Int {
		return 1000;
	}
	
	@:functionCode('
		return java.lang.System.currentTimeMillis();
	')
	public static function getTimestamp(): Float {
		return 0;
	}
	
	public static function getTime(): Float {
		return (getTimestamp() - startTime) / getFrequency();
	}
	
	public static function getVsync(): Bool {
		return true;
	}
	
	public static function getRefreshRate(): Int {
		return 60;
	}
	
	public static function getSystemId(): String {
		return "Android";
	}
	
	public static function requestShutdown(): Void {
		
	}
	
	public static function changeResolution(width: Int, height: Int): Void {
		
	}

	public static function canSwitchFullscreen() : Bool{
		return false;
	}

	public static function isFullscreen() : Bool{
		return false;
	}

	public static function requestFullscreen(): Void {
		
	}

	public static function exitFullscreen(): Void {
		
  	}

	public function notifyOfFullscreenChange(func : Void -> Void, error  : Void -> Void) : Void{
		
	}


	public function removeFromFullscreenChange(func : Void -> Void, error  : Void -> Void) : Void{
		
	}
	
	private static var framebuffer: Framebuffer;
	public static var mouseX: Int = 0;
	public static var mouseY: Int = 0;
	private static var keyboard: Keyboard;
	private static var shift = false;
	private static var mouse: Mouse;
	private static var surface: Surface;
	
	public static function init(title: String, width: Int, height: Int, done: Void->Void) {
		w = width;
		h = height;
		KhaActivity.the();
		keyboard = new Keyboard();
		mouse = new Mouse();
		//gamepad = new Gamepad();
		surface = new Surface();
		
		LoaderImpl.init(KhaActivity.the().getApplicationContext());
		Scheduler.init();
		
		Shaders.init();
		var graphics = new Graphics();
		framebuffer = new Framebuffer(null, null, graphics);
		var g1 = new kha.graphics2.Graphics1(framebuffer);
		var g2 = new Graphics2(framebuffer);
		framebuffer.init(g1, g2, graphics);
		
		Scheduler.start();
		
		done();
	}
	
	public static function getKeyboard(num: Int = 0): Keyboard {
		if (num == 0) return keyboard;
		else return null;
	}
	
	public static function getMouse(num: Int = 0): Mouse {
		if (num == 0) return mouse;
		else return null;
	}

	public static function lockMouse(): Void {
		
	}
	
	public static function unlockMouse(): Void {
		
	}

	public static function canLockMouse(): Bool {
		return false;
	}

	public static function isMouseLocked(): Bool {
		return false;
	}

	public static function notifyOfMouseLockChange(func: Void -> Void, error: Void -> Void): Void {
		
	}

	public static function removeFromMouseLockChange(func: Void -> Void, error: Void -> Void): Void {
		
	}
	
	public static function preinit(width: Int, height: Int): Void {
		w = width;
		h = height;
		startTime = getTimestamp();
		Main.main();
	}
	
	public static function setWidthHeight(width: Int, height: Int): Void {
		w = width;
		h = height;
	}
	
	public static function step(): Void {
		Scheduler.executeFrame();
		System.render(framebuffer);
	}

	private static function setMousePosition(x : Int, y : Int){
		mouseX = x;
		mouseY = y;
	}
	
	public static function touch(index: Int, x: Int, y: Int, action: Int): Void {
		
		switch (action) {
		case 0: //DOWN
			if (index == 0) {
				setMousePosition(x,y);
				mouse.sendDownEvent(0, x, y);
			}
			surface.sendTouchStartEvent(index, x, y);
		case 1: //MOVE
			if (index == 0) {
				var movementX = x - mouseX;
				var movementY = y - mouseY;
				setMousePosition(x,y);
				mouse.sendMoveEvent(x, y, movementX, movementY);
			}
			surface.sendMoveEvent(index, x, y);
		case 2: //UP
			if (index == 0) {
				setMousePosition(x,y);
				mouse.sendUpEvent(0, x, y);
			}
			surface.sendTouchEndEvent(index, x, y);
		}
	}
	
	public static function keyDown(code: Int): Void {
		switch (code) {
		case 0x00000120:
			shift = true;
			keyboard.sendDownEvent(Key.SHIFT, " ");
		case 0x00000103:
			keyboard.sendDownEvent(Key.BACKSPACE, " ");
		case 0x00000104:
			keyboard.sendDownEvent(Key.ENTER, " ");
		default:
			var char: String;
			if (shift) {
				char = String.fromCharCode(code);
			}
			else {
				char = String.fromCharCode(code + "a".charCodeAt(0) - "A".charCodeAt(0));
			}
			keyboard.sendDownEvent(Key.CHAR, char);
		}
	}
	
	public static function keyUp(code: Int): Void {
		switch (code) {
		case 0x00000120:
			shift = false;
			keyboard.sendUpEvent(Key.SHIFT, " ");
		case 0x00000103:
			keyboard.sendUpEvent(Key.BACKSPACE, " ");
		case 0x00000104:
			keyboard.sendUpEvent(Key.ENTER, " ");
		default:
			var char: String;
			if (shift) {
				char = String.fromCharCode(code);
			}
			else {
				char = String.fromCharCode(code + "a".charCodeAt(0) - "A".charCodeAt(0));
			}
			keyboard.sendUpEvent(Key.CHAR, char);
		}
	}
	
	public static var showKeyboard: Bool;
	
	public static function keyboardShown(): Bool {
		return showKeyboard;
	}
	
	public static function foreground(): Void {
		System.foreground();
	}

	public static function resume(): Void {
		System.resume();
	}

	public static function pause(): Void {
		System.pause();
	}

	public static function background(): Void {
		System.background();
	}

	public static function shutdown(): Void {
		System.shutdown();
	}
}
