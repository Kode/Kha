package kha;

import js.html.webgl.GL;
import js.html.WheelEvent;
import js.Browser;
import js.html.CanvasElement;
import js.html.KeyboardEvent;
import js.html.MouseEvent;
import js.html.Touch;
import js.html.TouchEvent;
import kha.graphics4.TextureFormat;
import kha.input.Gamepad;
import kha.input.Keyboard;
import kha.input.Mouse;
import kha.input.Surface;
import kha.js.AudioElementAudio;
import kha.js.AEAudioChannel;
import kha.js.CanvasGraphics;
import kha.js.MobileWebAudio;
import kha.js.vr.VrInterface;
import kha.System;

class GamepadStates {
	public var axes: Array<Float>;
	public var buttons: Array<Float>;

	public function new() {
		axes = new Array<Float>();
		buttons = new Array<Float>();
	}
}

class SystemImpl {
	public static var gl: GL;
	public static var gl2: Bool;
	public static var halfFloat: Dynamic;
	public static var anisotropicFilter: Dynamic;
	public static var depthTexture: Dynamic;
	public static var drawBuffers: Dynamic;
	public static var elementIndexUint: Dynamic;
	@:noCompletion public static var _hasWebAudio: Bool;
	//public static var graphics(default, null): Graphics;
	public static var khanvas: CanvasElement;
	private static var options: SystemOptions;
	public static var mobile: Bool = false;
	public static var ios: Bool = false;
	public static var mobileAudioPlaying: Bool = false;
	private static var chrome: Bool = false;
	private static var firefox: Bool = false;
	private static var ie: Bool = false;
	public static var insideInputEvent: Bool = false;

	private static function errorHandler(message: String, source: String, lineno: Int, colno: Int, error: Dynamic) {
		Browser.console.error(error.stack);
		return true;
	}

	public static function init(options: SystemOptions, callback: Void -> Void) {
		SystemImpl.options = options;
		#if kha_debug_html5
		Browser.window.onerror = cast errorHandler;
		var electron = untyped __js__("require('electron')");
		electron.webFrame.setZoomLevelLimits(1, 1);
		electron.ipcRenderer.send('asynchronous-message', {type: 'showWindow', title: options.title, width: options.width, height: options.height});
		// Wait a second so the debugger can attach
		Browser.window.setTimeout(function () {
			init2();
			callback();
		}, 1000);
		#else
		mobile = isMobile();
		ios = isIOS();
		chrome = isChrome();
		firefox = isFirefox();
		ie = isIE();
		init2();
		callback();
		#end
	}

	public static function initEx(title: String, options: Array<WindowOptions>, windowCallback: Int -> Void, callback: Void -> Void) {
		trace('initEx is not supported on the html5 target, running init() with first window options');

		init({title : title, width : options[0].width, height : options[0].height}, callback);

		if (windowCallback != null) {
			windowCallback(0);
		}
	}

	private static function isMobile(): Bool {
		var agent = js.Browser.navigator.userAgent;
		if (agent.indexOf("Android") >= 0
			|| agent.indexOf("webOS") >= 0
			|| agent.indexOf("BlackBerry") >= 0
			|| agent.indexOf("Windows Phone") >= 0) {
				return true;
		}
		if (isIOS()) return true;
		return false;
	}

	private static function isIOS(): Bool {
		var agent = js.Browser.navigator.userAgent;
		if (agent.indexOf("iPhone") >= 0
			|| agent.indexOf("iPad") >= 0
			|| agent.indexOf("iPod") >= 0) {
				return true;
		}
		return false;
	}

	private static function isChrome(): Bool {
		var agent = js.Browser.navigator.userAgent;
		if (agent.indexOf("Chrome") >= 0) {
			return true;
		}
		return false;
	}

	private static function isFirefox(): Bool {
		var agent = js.Browser.navigator.userAgent;
		if (agent.indexOf("Firefox") >= 0) {
			return true;
		}
		return false;
	}

	private static function isIE(): Bool {
		var agent = js.Browser.navigator.userAgent;
		if (agent.indexOf("MSIE ") >= 0
			|| agent.indexOf("Trident/") >= 0) {
			return true;
		}
		return false;
	}

	public static function windowWidth(windowId: Int = 0): Int {
		return (khanvas.width == 0 && options.width != null) ? options.width : khanvas.width;
	}

	public static function windowHeight(windowId: Int = 0): Int {
		return (khanvas.height == 0 && options.height != null) ? options.height : khanvas.height;
	}

	public static function screenDpi(): Int {
		var dpiElement = Browser.document.createElement('div');
		dpiElement.style.position = "absolute";
		dpiElement.style.width = "1in";
		dpiElement.style.height = "1in";
		dpiElement.style.left = "-100%";
		dpiElement.style.top = "-100%";
		Browser.document.body.appendChild(dpiElement);
		var dpi:Int = dpiElement.offsetHeight;
		dpiElement.remove();
		return dpi;
	}

	public static function setCanvas(canvas: CanvasElement): Void {
		khanvas = canvas;
	}

	public static function getScreenRotation(): ScreenRotation {
		return ScreenRotation.RotationNone;
	}

	public static function getTime(): Float {
		var performance = (untyped __js__("window.performance ? window.performance : window.Date"));
		return performance.now() / 1000;
	}

	public static function getVsync(): Bool {
		return true;
	}

	public static function getRefreshRate(): Int {
		return 60;
	}

	public static function getSystemId(): String {
		return "HTML5";
	}

	public static function requestShutdown(): Void {
		Browser.window.close();
	}

	private static inline var maxGamepads: Int = 4;
	private static var frame: Framebuffer;
	private static var pressedKeys: Array<Bool>;
	private static var leftMouseCtrlDown: Bool = false;
	private static var keyboard: Keyboard = null;
	private static var mouse: kha.input.Mouse;
	private static var surface: Surface;
	private static var gamepads: Array<Gamepad>;
	private static var gamepadStates: Array<GamepadStates>;

	private static var minimumScroll:Int = 999;
	private static var mouseX: Int;
	private static var mouseY: Int;
	private static var touchX: Int;
	private static var touchY: Int;
	private static var lastFirstTouchX: Int = 0;
	private static var lastFirstTouchY: Int = 0;

	public static function init2(?backbufferFormat: TextureFormat) {
		haxe.Log.trace = untyped js.Boot.__trace; // Hack for JS trace problems
		
		#if !kha_no_keyboard 
		keyboard = new Keyboard();
		#end
		mouse = new kha.input.MouseImpl();
		surface = new Surface();
		gamepads = new Array<Gamepad>();
		gamepadStates = new Array<GamepadStates>();
		for (i in 0...maxGamepads) {
			gamepads[i] = new Gamepad(i);
			gamepadStates[i] = new GamepadStates();
		}
		js.Browser.window.addEventListener("gamepadconnected", function(e_) {
			Gamepad.sendConnectEvent(e_.gamepad.index);
		}); 
		js.Browser.window.addEventListener("gamepaddisconnected", function(e_) {
			Gamepad.sendDisconnectEvent(e_.gamepad.index);
		});
		if (ie) {
			pressedKeys = new Array<Bool>();
			for (i in 0...256) pressedKeys.push(false);
			for (i in 0...256) pressedKeys.push(null);
		}

		js.Browser.document.addEventListener("copy", function (e_) {
			var e: js.html.ClipboardEvent = cast e_;
			if (System.copyListener != null) {
				var data = System.copyListener();
				if (data != null) {
					e.clipboardData.setData("text/plain", data);
				}
				e.preventDefault();
			}
		});

		js.Browser.document.addEventListener("cut", function (e_) {
			var e: js.html.ClipboardEvent = cast e_;
			if (System.cutListener != null) {
				var data = System.cutListener();
				if (data != null) {
					e.clipboardData.setData("text/plain", data);
				}
				e.preventDefault();
			}
		});

		js.Browser.document.addEventListener("paste", function (e_) {
			var e: js.html.ClipboardEvent = cast e_;
			if (System.pasteListener != null) {
				System.pasteListener(e.clipboardData.getData("text/plain"));
				e.preventDefault();
			}
		});

		CanvasImage.init();
		//Loader.init(new kha.js.Loader());
		Scheduler.init();

		loadFinished();
		EnvironmentVariables.instance = new kha.js.EnvironmentVariables();
	}

	public static function getMouse(num: Int): Mouse {
		if (num != 0) return null;
		return mouse;
	}

	public static function getKeyboard(num: Int): Keyboard {
		if (num != 0) return null;
		return keyboard;
	}

	static function checkGamepad(pad: js.html.Gamepad) {
		for (i in 0...pad.axes.length) {
			if (pad.axes[i] != null) {
				if (gamepadStates[pad.index].axes[i] != pad.axes[i]) {
					var axis = pad.axes[i];
					if (i % 2 == 1) axis = -axis;
					gamepadStates[pad.index].axes[i] = axis;
					gamepads[pad.index].sendAxisEvent(i, axis);
				}
			}
		}
		for (i in 0...pad.buttons.length) {
			if (pad.buttons[i] != null) {
				if (gamepadStates[pad.index].buttons[i] != pad.buttons[i].value) {
					gamepadStates[pad.index].buttons[i] = pad.buttons[i].value;
					gamepads[pad.index].sendButtonEvent(i, pad.buttons[i].value);
				}
			}
		}
		if (pad.axes.length <= 4 && pad.buttons.length > 7) {
			// Fix for the triggers not being axis in html5
			gamepadStates[pad.index].axes[4] = pad.buttons[6].value;
			gamepads[pad.index].sendAxisEvent(4, pad.buttons[6].value);
			gamepadStates[pad.index].axes[5] = pad.buttons[7].value;
			gamepads[pad.index].sendAxisEvent(5, pad.buttons[7].value);
		}
	}

	//public function start(game: Game): Void {
	//	gameToStart = game;
	//	Configuration.setScreen(new EmptyScreen(Color.fromBytes(0, 0, 0)));
	//	Loader.the.loadProject(loadFinished);
	//}

	private static function loadFinished() {
		// Only consider custom canvas ID for release builds
		var canvas: Dynamic = khanvas;
		if (canvas == null) {
			#if (kha_debug_html5 || !canvas_id)
			canvas = Browser.document.getElementById("khanvas");
			#else
			canvas = Browser.document.getElementById(kha.CompilerDefines.canvas_id);
			#end
		}
		canvas.style.cursor = "default";

		var gl: Bool = false;

		#if kha_webgl
		try {
			SystemImpl.gl = canvas.getContext("webgl2", { alpha: false, antialias: options.samplesPerPixel > 1, stencil: true, preserveDrawingBuffer: true } );
			SystemImpl.gl.pixelStorei(GL.UNPACK_PREMULTIPLY_ALPHA_WEBGL, 1);

			halfFloat = {HALF_FLOAT_OES: 0x140B}; // GL_HALF_FLOAT
			depthTexture = {UNSIGNED_INT_24_8_WEBGL: 0x84FA}; // GL_UNSIGNED_INT_24_8
			drawBuffers = {COLOR_ATTACHMENT0_WEBGL: GL.COLOR_ATTACHMENT0};
			elementIndexUint = true;
			SystemImpl.gl.getExtension("EXT_color_buffer_float");
			SystemImpl.gl.getExtension("OES_texture_float_linear");
			SystemImpl.gl.getExtension("OES_texture_half_float_linear");
			anisotropicFilter = SystemImpl.gl.getExtension("EXT_texture_filter_anisotropic");
			if (anisotropicFilter == null) anisotropicFilter = SystemImpl.gl.getExtension("WEBKIT_EXT_texture_filter_anisotropic");
			
			gl = true;
			gl2 = true;
			Shaders.init();
		}
		catch (e: Dynamic) {
			trace("Could not initialize WebGL 2, falling back to WebGL.");
		}

		if (!gl2) {
			try {
				SystemImpl.gl = canvas.getContext("experimental-webgl", { alpha: false, antialias: options.samplesPerPixel > 1, stencil: true, preserveDrawingBuffer: true } );
				if (SystemImpl.gl != null) {
					SystemImpl.gl.pixelStorei(GL.UNPACK_PREMULTIPLY_ALPHA_WEBGL, 1);
					SystemImpl.gl.getExtension("OES_texture_float");
					SystemImpl.gl.getExtension("OES_texture_float_linear");
					halfFloat = SystemImpl.gl.getExtension("OES_texture_half_float");
					SystemImpl.gl.getExtension("OES_texture_half_float_linear");
					depthTexture = SystemImpl.gl.getExtension("WEBGL_depth_texture");
					SystemImpl.gl.getExtension("EXT_shader_texture_lod");
					SystemImpl.gl.getExtension("OES_standard_derivatives");
					anisotropicFilter = SystemImpl.gl.getExtension("EXT_texture_filter_anisotropic");
					if (anisotropicFilter == null) anisotropicFilter = SystemImpl.gl.getExtension("WEBKIT_EXT_texture_filter_anisotropic");
					drawBuffers = SystemImpl.gl.getExtension('WEBGL_draw_buffers');
					elementIndexUint = SystemImpl.gl.getExtension("OES_element_index_uint");
					gl = true;
					Shaders.init();
				}
			}
			catch (e: Dynamic) {
				trace("Could not initialize WebGL, falling back to Canvas.");
			}
		}
		#end

		setCanvas(canvas);
		//var widthTransform: Float = canvas.width / Loader.the.width;
		//var heightTransform: Float = canvas.height / Loader.the.height;
		//var transform: Float = Math.min(widthTransform, heightTransform);
		if (gl) {
			var g4 = new kha.js.graphics4.Graphics();
			frame = new Framebuffer(0, null, null, g4);
			frame.init(new kha.graphics2.Graphics1(frame), new kha.js.graphics4.Graphics2(frame), g4); // new kha.graphics1.Graphics4(frame));
		}
		else {
			untyped __js__ ("kha_js_Font.Kravur = kha_Kravur; kha_Kravur = kha_js_Font");
			var g2 = new CanvasGraphics(canvas.getContext("2d"));
			frame = new Framebuffer(0, null, g2, null);
			frame.init(new kha.graphics2.Graphics1(frame), g2, null);
		}
		//canvas.getContext("2d").scale(transform, transform);

		if (!mobile && kha.audio2.Audio._init()) {
			SystemImpl._hasWebAudio = true;
			kha.audio2.Audio1._init();
		}
		else if (mobile) {
			SystemImpl._hasWebAudio = false;
			MobileWebAudio._init();
			untyped __js__ ("kha_audio2_Audio1 = kha_js_MobileWebAudio");
		}
		else {
			SystemImpl._hasWebAudio = false;
			AudioElementAudio._compile();
			untyped __js__ ("kha_audio2_Audio1 = kha_js_AudioElementAudio");
		}
		
		kha.vr.VrInterface.instance = new VrInterface();
		
		Scheduler.start();

		var window: Dynamic = Browser.window;
		var requestAnimationFrame = window.requestAnimationFrame;
		if (requestAnimationFrame == null) requestAnimationFrame = window.mozRequestAnimationFrame;
		if (requestAnimationFrame == null) requestAnimationFrame = window.webkitRequestAnimationFrame;
		if (requestAnimationFrame == null) requestAnimationFrame = window.msRequestAnimationFrame;

		function animate(timestamp) {
			var window: Dynamic = Browser.window;
			if (requestAnimationFrame == null) window.setTimeout(animate, 1000.0 / 60.0);
			else requestAnimationFrame(animate);


			var sysGamepads = getGamepads();
			if (sysGamepads != null) {
				for (i in 0...sysGamepads.length) {
					var pad = sysGamepads[i];
					if (pad != null) {
						checkGamepad(pad);
					}
				}
			}

			Scheduler.executeFrame();

			if (untyped canvas.getContext) {

				// Lookup the size the browser is displaying the canvas.
				//TODO deal with window.devicePixelRatio ?
				var displayWidth  = canvas.clientWidth;
				var displayHeight = canvas.clientHeight;

				// Check if the canvas is not the same size.
				if (canvas.width  != displayWidth ||
					canvas.height != displayHeight) {

					// Make the canvas the same size
					canvas.width  = displayWidth;
					canvas.height = displayHeight;
				}

				System.render(0, frame);
				if (SystemImpl.gl != null) {
					// Clear alpha for IE11
					SystemImpl.gl.clearColor(1, 1, 1, 1);
					SystemImpl.gl.colorMask(false, false, false, true);
					SystemImpl.gl.clear(GL.COLOR_BUFFER_BIT);
					SystemImpl.gl.colorMask(true, true, true, true);
				}
			}
		}

		if (requestAnimationFrame == null) window.setTimeout(animate, 1000.0 / 60.0);
		else requestAnimationFrame(animate);

		// Autofocus
		if (canvas.getAttribute("tabindex") == null) {
			canvas.setAttribute("tabindex", "0"); // needed for keypress events
		}
		canvas.focus();

		// disable context menu
		canvas.oncontextmenu = function(event: Dynamic) { event.stopPropagation(); event.preventDefault(); }

		canvas.onmousedown = mouseDown;
		canvas.onmousemove = mouseMove;
		if(keyboard != null) {
			canvas.onkeydown = keyDown;
			canvas.onkeyup = keyUp;
			canvas.onkeypress = keyPress;
		}
		canvas.onblur = onBlur;
		canvas.onfocus = onFocus;
		untyped (canvas.onmousewheel = canvas.onwheel = mouseWheel);
		canvas.onmouseleave = mouseLeave;

		canvas.addEventListener("wheel mousewheel", mouseWheel, false);
		canvas.addEventListener("touchstart", touchDown, false);
		canvas.addEventListener("touchend", touchUp, false);
		canvas.addEventListener("touchmove", touchMove, false);
		canvas.addEventListener("touchcancel", touchCancel, false);

		Browser.window.addEventListener("unload", unload);
	}

	public static function lockMouse(): Void {
		untyped if (SystemImpl.khanvas.requestPointerLock) {
			SystemImpl.khanvas.requestPointerLock();
		}
		else if (SystemImpl.khanvas.mozRequestPointerLock) {
			SystemImpl.khanvas.mozRequestPointerLock();
		}
		else if (SystemImpl.khanvas.webkitRequestPointerLock) {
			SystemImpl.khanvas.webkitRequestPointerLock();
		}
	}

	public static function unlockMouse(): Void {
		untyped if (document.exitPointerLock) {
			document.exitPointerLock();
		}
		else if (document.mozExitPointerLock) {
			document.mozExitPointerLock();
		}
		else if (document.webkitExitPointerLock) {
			document.webkitExitPointerLock();
		}
	}

	public static function canLockMouse(): Bool {
		return untyped __js__("'pointerLockElement' in document ||
		'mozPointerLockElement' in document ||
		'webkitPointerLockElement' in document");
	}

	public static function isMouseLocked(): Bool {
		return untyped __js__("document.pointerLockElement === kha_SystemImpl.khanvas ||
			document.mozPointerLockElement === kha_SystemImpl.khanvas ||
			document.webkitPointerLockElement === kha_SystemImpl.khanvas");
	}

	public static function notifyOfMouseLockChange(func: Void -> Void, error: Void -> Void): Void{
		js.Browser.document.addEventListener('pointerlockchange', func, false);
		js.Browser.document.addEventListener('mozpointerlockchange', func, false);
		js.Browser.document.addEventListener('webkitpointerlockchange', func, false);

		js.Browser.document.addEventListener('pointerlockerror', error, false);
		js.Browser.document.addEventListener('mozpointerlockerror', error, false);
		js.Browser.document.addEventListener('webkitpointerlockerror', error, false);
	}

	public static function removeFromMouseLockChange(func : Void -> Void, error  : Void -> Void) : Void{
		js.Browser.document.removeEventListener('pointerlockchange', func, false);
		js.Browser.document.removeEventListener('mozpointerlockchange', func, false);
		js.Browser.document.removeEventListener('webkitpointerlockchange', func, false);

		js.Browser.document.removeEventListener('pointerlockerror', error, false);
		js.Browser.document.removeEventListener('mozpointerlockerror', error, false);
		js.Browser.document.removeEventListener('webkitpointerlockerror', error, false);
	}

	static function unload(_): Void {
		//Game.the.onPause();
		//Game.the.onBackground();
		//Game.the.onShutdown();
	}

	private static function setMouseXY(event: MouseEvent): Void {
		var rect = SystemImpl.khanvas.getBoundingClientRect();
		var borderWidth = SystemImpl.khanvas.clientLeft;
		var borderHeight = SystemImpl.khanvas.clientTop;
		mouseX = Std.int((event.clientX - rect.left - borderWidth) * SystemImpl.khanvas.width / (rect.width - 2 * borderWidth));
		mouseY = Std.int((event.clientY - rect.top - borderHeight) * SystemImpl.khanvas.height / (rect.height - 2 * borderHeight));
	}

	private static var iosSoundEnabled: Bool = false;

	private static function unlockSoundOnIOS(): Void {
		if (!ios || iosSoundEnabled) return;
		
		var buffer = MobileWebAudio._context.createBuffer(1, 1, 22050);
		var source = MobileWebAudio._context.createBufferSource();
		source.buffer = buffer;
		source.connect(MobileWebAudio._context.destination);
		untyped(if (source.noteOn) source.noteOn(0));

		iosSoundEnabled = true;
	}

	private static function mouseLeave():Void {
		mouse.sendLeaveEvent(0);
	}
	
	private static function mouseWheel(event: WheelEvent): Bool {
		insideInputEvent = true;
		unlockSoundOnIOS();

		event.preventDefault();

		//Deltamode == 0, deltaY is in pixels.
		if (event.deltaMode == 0) {
			if (event.deltaY < 0) {
				mouse.sendWheelEvent(0, -1);
			}
			else if (event.deltaY > 0) {
				mouse.sendWheelEvent(0, 1);
			}
			insideInputEvent = false;
			return false;
		}

		//Lines
		if (event.deltaMode == 1) {
			minimumScroll = Std.int(Math.min(minimumScroll, Math.abs(event.deltaY)));
			mouse.sendWheelEvent(0, Std.int(event.deltaY / minimumScroll));
			insideInputEvent = false;
			return false;
		}
		insideInputEvent = false;
		return false;
	}

	private static function mouseDown(event: MouseEvent): Void {
		insideInputEvent = true;
		unlockSoundOnIOS();

		setMouseXY(event);
		if (event.which == 1) { //left button
			if (event.ctrlKey) {
				leftMouseCtrlDown = true;
				mouse.sendDownEvent(0, 1, mouseX, mouseY);
			}
			else {
				leftMouseCtrlDown = false;
				mouse.sendDownEvent(0, 0, mouseX, mouseY);
			}

			if (khanvas.setCapture != null)  {
				khanvas.setCapture();
			}
			else {
				khanvas.ownerDocument.addEventListener('mousemove', documentMouseMove, true);
			}
			khanvas.ownerDocument.addEventListener('mouseup', mouseLeftUp);
		}
		else if(event.which == 2) { //middle button
			mouse.sendDownEvent(0, 2, mouseX, mouseY);
			khanvas.ownerDocument.addEventListener('mouseup', mouseMiddleUp);
		}
		else if(event.which == 3) { //right button
			mouse.sendDownEvent(0, 1, mouseX, mouseY);
			khanvas.ownerDocument.addEventListener('mouseup', mouseRightUp);
		}
		insideInputEvent = false;
	}

	private static function mouseLeftUp(event: MouseEvent): Void {
		unlockSoundOnIOS();
	
		if (event.which != 1) return;
		
		insideInputEvent = true;
		khanvas.ownerDocument.removeEventListener('mouseup', mouseLeftUp);
		if (khanvas.releaseCapture != null) {
			khanvas.ownerDocument.releaseCapture();
		}
		else {
			khanvas.ownerDocument.removeEventListener("mousemove", documentMouseMove, true);
		}
		if (leftMouseCtrlDown) {
			mouse.sendUpEvent(0, 1, mouseX, mouseY);
		}
		else {
			mouse.sendUpEvent(0, 0, mouseX, mouseY);
		}
		leftMouseCtrlDown = false;
		insideInputEvent = false;
	}

	private static function mouseMiddleUp(event: MouseEvent): Void {
		unlockSoundOnIOS();

		if (event.which != 2) return;
		
		insideInputEvent = true;
		khanvas.ownerDocument.removeEventListener('mouseup', mouseMiddleUp);
		mouse.sendUpEvent(0, 2, mouseX, mouseY);
		insideInputEvent = false;
	}

	private static function mouseRightUp(event: MouseEvent): Void {
		unlockSoundOnIOS();

		if (event.which != 3) return;
		
		insideInputEvent = true;
		khanvas.ownerDocument.removeEventListener('mouseup', mouseRightUp);
		mouse.sendUpEvent(0, 1, mouseX, mouseY);
		insideInputEvent = false;
	}

	private static function documentMouseMove(event: MouseEvent): Void {
		event.stopPropagation();
		mouseMove(event);
	}
	
	private static function mouseMove(event: MouseEvent): Void {
		insideInputEvent = true;
		unlockSoundOnIOS();

		var lastMouseX = mouseX;
		var lastMouseY = mouseY;
		setMouseXY(event);

		var movementX = event.movementX;
		var movementY = event.movementY;

		if(event.movementX == null) {
		   movementX = (untyped event.mozMovementX != null) ? untyped event.mozMovementX : ((untyped event.webkitMovementX != null) ? untyped event.webkitMovementX : (mouseX  - lastMouseX));
		   movementY = (untyped event.mozMovementY != null) ? untyped event.mozMovementY : ((untyped event.webkitMovementY != null) ? untyped event.webkitMovementY : (mouseY  - lastMouseY));
		}

		// this ensures same behaviour across browser until they fix it
		if (firefox) {
			movementX = Std.int(movementX * Browser.window.devicePixelRatio);
			movementY = Std.int(movementY * Browser.window.devicePixelRatio);
		}

		mouse.sendMoveEvent(0, mouseX, mouseY, movementX, movementY);
		insideInputEvent = false;
	}

	private static function setTouchXY(touch: Touch): Void {
		var rect = SystemImpl.khanvas.getBoundingClientRect();
		var borderWidth = SystemImpl.khanvas.clientLeft;
		var borderHeight = SystemImpl.khanvas.clientTop;
		touchX = Std.int((touch.clientX - rect.left - borderWidth) * SystemImpl.khanvas.width / (rect.width - 2 * borderWidth));
		touchY = Std.int((touch.clientY - rect.top - borderHeight) * SystemImpl.khanvas.height / (rect.height - 2 * borderHeight));
	}

	private static var iosTouchs: Array<Int> = [];

	private static function touchDown(event: TouchEvent): Void {
		insideInputEvent = true;
		unlockSoundOnIOS();

		event.stopPropagation();
		event.preventDefault();

		for (touch in event.changedTouches)	{
			var id = touch.identifier;
			if (ios) {
				id = iosTouchs.indexOf(-1);
				if (id == -1) id = iosTouchs.length;
				iosTouchs[id] = touch.identifier;
			}

			setTouchXY(touch);
			mouse.sendDownEvent(0, 0, touchX, touchY);
			surface.sendTouchStartEvent(id, touchX, touchY);
		}
		insideInputEvent = false;
	}

	private static function touchUp(event: TouchEvent): Void {
		insideInputEvent = true;
		unlockSoundOnIOS();

		for (touch in event.changedTouches)	{
			var id = touch.identifier;
			if (ios) {
				id = iosTouchs.indexOf(id);
				iosTouchs[id] = -1;
			}

			setTouchXY(touch);
			mouse.sendUpEvent(0, 0, touchX, touchY);
			surface.sendTouchEndEvent(id, touchX, touchY);
		}
		insideInputEvent = false;
	}

	private static function touchMove(event: TouchEvent): Void {
		insideInputEvent = true;
		unlockSoundOnIOS();

		var index = 0;
		for (touch in event.changedTouches) {
			setTouchXY(touch);
			if(index == 0){
				var movementX = touchX - lastFirstTouchX;
				var movementY = touchY - lastFirstTouchY;
				lastFirstTouchX = touchX;
				lastFirstTouchY = touchY;

				mouse.sendMoveEvent(0, touchX, touchY, movementX, movementY);
			}
			var id = touch.identifier;
			if (ios) id = iosTouchs.indexOf(id);

			surface.sendMoveEvent(id, touchX, touchY);
			index++;
		}
		insideInputEvent = false;
	}

	private static function touchCancel(event: TouchEvent): Void {
		insideInputEvent = true;
		unlockSoundOnIOS();

		for (touch in event.changedTouches)	{
			var id = touch.identifier;
			if (ios) id = iosTouchs.indexOf(id);

			setTouchXY(touch);
			mouse.sendUpEvent(0, 0, touchX, touchY);
			surface.sendTouchEndEvent(id, touchX, touchY);
		}
		iosTouchs = [];
		insideInputEvent = false;
	}

	private static function onBlur() {
		// System.pause();
		System.background();
	}

	private static function onFocus() {
		// System.resume();
		System.foreground();
	}

	private static function keycodeToChar(key: String, keycode: Int, shift: Bool): String {
		if (key != null) {
			if (key.length == 1) return key;
			switch (key) {
				case "Add":
					return "+";
				case "Subtract":
					return "-";
				case "Multiply":
					return "*";
				case "Divide":
					return "/";
			}
		}
		switch (keycode) {
			case 187:
				if (shift) return "*";
				else return "+";
			case 188:
				if (shift) return ";";
				else return ",";
			case 189:
				if (shift) return "_";
				else return "-";
			case 190:
				if (shift) return ":";
				else return ".";
			case 191:
				if (shift) return "'";
				else return "#";
			case 226:
				if (shift) return ">";
				else return "<";
			case 106:
				return "*";
			case 107:
				return "+";
			case 109:
				return "-";
			case 111:
				return "/";
			case 49:
				if (shift) return "!";
				else return "1";
			case 50:
				if (shift) return "\"";
				else return "2";
			case 51:
				if (shift) return "§";
				else return "3";
			case 52:
				if (shift) return "$";
				else return "4";
			case 53:
				if (shift) return "%";
				else return "5";
			case 54:
				if (shift) return "&";
				else return "6";
			case 55:
				if (shift) return "/";
				else return "7";
			case 56:
				if (shift) return "(";
				else return "8";
			case 57:
				if (shift) return ")";
				else return "9";
			case 48:
				if (shift) return "=";
				else return "0";
			case 219:
				if (shift) return "?";
				else return "ß";
			case 212:
				if (shift) return "`";
				else return "´";
		}
		if (keycode >= 96 && keycode <= 105) { // num block
			return String.fromCharCode('0'.code - 96 + keycode);
		}
		if (keycode >= 'A'.code && keycode <= 'Z'.code) {
			if (shift) return String.fromCharCode(keycode);
			else return String.fromCharCode(keycode - 'A'.code + 'a'.code);
		}
		return String.fromCharCode(keycode);
	}

	private static function keyDown(event: KeyboardEvent): Void {
		event.stopPropagation();

		// prevent key repeat
		if (ie) {
			if (pressedKeys[event.keyCode]) {
				event.preventDefault();
				return;
			}
			pressedKeys[event.keyCode] = true;

		} else if (event.repeat) {
			event.preventDefault();
			return;
		}

		keyboard.sendDownEvent(cast event.keyCode);
	}

	private static function keyUp(event: KeyboardEvent): Void {
		event.preventDefault();
		event.stopPropagation();

		if (ie) pressedKeys[event.keyCode] = false;

		keyboard.sendUpEvent(cast event.keyCode);
	}

	private static function keyPress(event: KeyboardEvent): Void {
		event.stopPropagation();
		if (firefox && (event.which == 0 || event.which == 8)) return; // Firefox bug 968056
		keyboard.sendPressEvent(String.fromCharCode(event.which));
	}

	public static function canSwitchFullscreen(): Bool {
		return untyped __js__("'fullscreenElement ' in document ||
		'mozFullScreenElement' in document ||
		'webkitFullscreenElement' in document ||
		'msFullscreenElement' in document
		");
	}

	public static function isFullscreen(): Bool {
		return untyped __js__("document.fullscreenElement === this.khanvas ||
			document.mozFullScreenElement === this.khanvas ||
			document.webkitFullscreenElement === this.khanvas ||
			document.msFullscreenElement === this.khanvas ");
	}

	public static function requestFullscreen(): Void {
		untyped if (khanvas.requestFullscreen) {
			khanvas.requestFullscreen();
		}
		else if (khanvas.msRequestFullscreen) {
			khanvas.msRequestFullscreen();
		}
		else if (khanvas.mozRequestFullScreen) {
			khanvas.mozRequestFullScreen();
		}
		else if(khanvas.webkitRequestFullscreen){
			khanvas.webkitRequestFullscreen();
		}
	}

	public static function exitFullscreen(): Void {
		untyped if (document.exitFullscreen) {
			document.exitFullscreen();
		}
		else if (document.msExitFullscreen) {
			document.msExitFullscreen();
		}
		else if (document.mozCancelFullScreen) {
			document.mozCancelFullScreen();
		}
		else if (document.webkitExitFullscreen) {
			document.webkitExitFullscreen();
		}
	}

	public static function notifyOfFullscreenChange(func: Void -> Void, error: Void -> Void): Void {
		js.Browser.document.addEventListener('fullscreenchange', func, false);
		js.Browser.document.addEventListener('mozfullscreenchange', func, false);
		js.Browser.document.addEventListener('webkitfullscreenchange', func, false);
		js.Browser.document.addEventListener('MSFullscreenChange', func, false);

		js.Browser.document.addEventListener('fullscreenerror', error, false);
		js.Browser.document.addEventListener('mozfullscreenerror', error, false);
		js.Browser.document.addEventListener('webkitfullscreenerror', error, false);
		js.Browser.document.addEventListener('MSFullscreenError', error, false);
	}


	public static function removeFromFullscreenChange(func: Void -> Void, error: Void -> Void): Void {
		js.Browser.document.removeEventListener('fullscreenchange', func, false);
		js.Browser.document.removeEventListener('mozfullscreenchange', func, false);
		js.Browser.document.removeEventListener('webkitfullscreenchange', func, false);
		js.Browser.document.removeEventListener('MSFullscreenChange', func, false);

		js.Browser.document.removeEventListener('fullscreenerror', error, false);
		js.Browser.document.removeEventListener('mozfullscreenerror', error, false);
		js.Browser.document.removeEventListener('webkitfullscreenerror', error, false);
		js.Browser.document.removeEventListener('MSFullscreenError', error, false);
	}

	public static function changeResolution(width: Int, height: Int): Void {

	}

	public static function setKeepScreenOn(on: Bool): Void {

	}

	public static function loadUrl(url: String): Void {
		js.Browser.window.open(url, "_blank");
	}

	public static function getGamepadId(index: Int): String {
		var sysGamepads = getGamepads();
		if (sysGamepads != null &&  untyped sysGamepads[index]) {
				return sysGamepads[index].id;
		}
	
		return "unkown";
	}

	private static function getGamepads(): Array<js.html.Gamepad> {
		if (chrome && kha.vr.VrInterface.instance.IsVrEnabled()) return null; // Chrome crashes if navigator.getGamepads() is called when using VR

		if (untyped navigator.getGamepads) {
			return js.Browser.navigator.getGamepads();
		}
		else {
			return null;
		}
	}
}
