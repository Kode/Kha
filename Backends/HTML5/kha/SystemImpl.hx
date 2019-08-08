package kha;

import js.html.webgl.GL;
import js.html.WheelEvent;
import js.Browser;
import js.html.CanvasElement;
import js.html.KeyboardEvent;
import js.html.MouseEvent;
import js.html.Touch;
import js.html.TouchEvent;
import js.html.ClipboardEvent;
import js.html.DeviceMotionEvent;
import js.html.DeviceOrientationEvent;
import kha.graphics4.TextureFormat;
import kha.input.Gamepad;
import kha.input.Keyboard;
import kha.input.Mouse;
import kha.input.Sensor;
import kha.input.Surface;
import kha.js.AudioElementAudio;
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
	static var window: Window;

	private static function errorHandler(message: String, source: String, lineno: Int, colno: Int, error: Dynamic) {
		Browser.console.error(error.stack);
		return true;
	}

	public static function init(options: SystemOptions, callback: Window -> Void): Void {
		SystemImpl.options = options;
		#if kha_debug_html5
		Browser.window.onerror = cast errorHandler;
		var electron = untyped __js__("require('electron')");
		if (electron.webFrame.setZoomLevelLimits != null) { // TODO: Figure out why this check is sometimes required
			electron.webFrame.setZoomLevelLimits(1, 1);
		}
		var wndOpts = {
			type: 'showWindow', title: options.title,
			x: options.window.x, y: options.window.y,
			width: options.width, height: options.height,
		}
		electron.ipcRenderer.send('asynchronous-message', wndOpts);		// Wait a second so the debugger can attach
		Browser.window.setTimeout(function () {
			initSecondStep(callback);
		}, 1000);
		#else
		mobile = isMobile();
		ios = isIOS();
		chrome = isChrome();
		firefox = isFirefox();
		ie = isIE();

		if (mobile || chrome) {
			mobileAudioPlaying = false;
		}
		else {
			mobileAudioPlaying = true;
		}

		initSecondStep(callback);
		#end
	}

	private static function initSecondStep(callback: Window -> Void): Void {
		init2(options.window.width, options.window.height);
		callback(window);
	}

	public static function initSensor(): Void {
		if (ios) { // In Safari for iOS the directions are reversed on axes x, y and z
			Browser.window.ondevicemotion = function (event: DeviceMotionEvent) {
				Sensor._changed(0, -event.accelerationIncludingGravity.x, -event.accelerationIncludingGravity.y, -event.accelerationIncludingGravity.z);
			};
		}
		else {
			Browser.window.ondevicemotion = function (event: DeviceMotionEvent) {
				Sensor._changed(0, event.accelerationIncludingGravity.x, event.accelerationIncludingGravity.y, event.accelerationIncludingGravity.z);
			};
		}
		Browser.window.ondeviceorientation = function (event: DeviceOrientationEvent) {
			Sensor._changed(1, event.beta, event.gamma, event.alpha);
		};
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

	public static function getSystemId(): String {
		return "HTML5";
	}

	public static function vibrate(ms:Int): Void {
		Browser.navigator.vibrate(ms);
	}

	public static function getLanguage(): String {
		return Browser.navigator.language;
	}

	public static function requestShutdown(): Bool {
		Browser.window.close();
		return true;
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

	public static function init2(defaultWidth: Int, defaultHeight: Int, ?backbufferFormat: TextureFormat) {
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
		js.Browser.window.addEventListener("gamepadconnected", function(e) {
			Gamepad.sendConnectEvent(e.gamepad.index);
		});
		js.Browser.window.addEventListener("gamepaddisconnected", function(e) {
			Gamepad.sendDisconnectEvent(e.gamepad.index);
		});
		if (ie) {
			pressedKeys = new Array<Bool>();
			for (i in 0...256) pressedKeys.push(false);
			for (i in 0...256) pressedKeys.push(null);
		}

		function onCopy(e: ClipboardEvent):Void {
			if (System.copyListener != null) {
				var data = System.copyListener();
				if (data != null) e.clipboardData.setData("text/plain", data);
				e.preventDefault();
			}
		}

		function onCut(e: ClipboardEvent):Void {
			if (System.cutListener != null) {
				var data = System.cutListener();
				if (data != null) e.clipboardData.setData("text/plain", data);
				e.preventDefault();
			}
		}

		function onPaste(e: ClipboardEvent):Void {
			if (System.pasteListener != null) {
				System.pasteListener(e.clipboardData.getData("text/plain"));
				e.preventDefault();
			}
		}

		var document = Browser.document;
		document.addEventListener("copy", onCopy);
		document.addEventListener("cut", onCut);
		document.addEventListener("paste", onPaste);

		if (firefox) {
			var canvas = getCanvasElement();
			function onPreTextEvents(e: KeyboardEvent):Void {
				if (!(e.ctrlKey || e.metaKey)) return;
				var isEvent = e.keyCode == 67 || e.keyCode == 88 || e.keyCode == 86;
				if (!isEvent) return;

				var input = document.createTextAreaElement();
				var onEvent = function(e: ClipboardEvent) {
					document.body.removeChild(input);
					canvas.focus();
				};
				if (e.keyCode == 67) input.oncopy = onEvent;
				else if (e.keyCode == 88) input.oncut = onEvent;
				else if (e.keyCode == 86) input.onpaste = onEvent;
				document.body.appendChild(input);
				input.select();
			}
			canvas.addEventListener("keydown", onPreTextEvents);
		}

		CanvasImage.init();
		Scheduler.init();

		loadFinished(defaultWidth, defaultHeight);
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
				var axis = pad.axes[i];
				if (i % 2 == 1) axis = -axis;
				if (gamepadStates[pad.index].axes[i] != axis) {
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

	private static function getCanvasElement(): CanvasElement {
		if (khanvas != null) return khanvas;
		// Only consider custom canvas ID for release builds
		#if (kha_debug_html5 || !canvas_id)
		return cast Browser.document.getElementById("khanvas");
		#else
		return cast Browser.document.getElementById(kha.CompilerDefines.canvas_id);
		#end
	}

	private static function loadFinished(defaultWidth: Int, defaultHeight: Int) {
		var canvas: CanvasElement = getCanvasElement();
		canvas.style.cursor = "default";

		var gl: Bool = false;

		#if kha_webgl
		try {
			SystemImpl.gl = canvas.getContext("webgl2", { alpha: false, antialias: options.framebuffer.samplesPerPixel > 1, stencil: true}); // preserveDrawingBuffer: true } ); Warning: preserveDrawingBuffer can cause huge performance issues on mobile browsers
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
				SystemImpl.gl = canvas.getContext("experimental-webgl", { alpha: false, antialias: options.framebuffer.samplesPerPixel > 1, stencil: true}); // preserveDrawingBuffer: true } ); WARNING: preserveDrawingBuffer causes huge performance issues (on mobile browser)!
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
			catch (e: Dynamic) {
				trace("Could not initialize WebGL, falling back to <canvas>.");
			}
		}
		#end

		setCanvas(canvas);
		window = new Window(defaultWidth, defaultHeight, canvas);

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

			if (canvas.getContext != null) {

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

				System.render([frame]);
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
		canvas.focus();

		#if kha_disable_context_menu
		canvas.oncontextmenu = function (event: Dynamic) {
			event.stopPropagation();
			event.preventDefault();
		}
		#end

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

#if kha_debug_html5
		Browser.document.addEventListener('dragover', function( event ) {
			event.preventDefault();
		});

		Browser.document.addEventListener('drop', function( event: js.html.DragEvent ) {
			event.preventDefault();

			if (event.dataTransfer != null && event.dataTransfer.files != null) {
				for (file in event.dataTransfer.files) {
					// https://developer.mozilla.org/en-US/docs/Web/API/File
					//  - use mozFullPath or webkitRelativePath?
					System.dropFiles(untyped __js__('file.path'));
				}
			}
		});
#end

		Browser.window.addEventListener("unload", function () {
			System.shutdown();
		});
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

	private static function setMouseXY(event: MouseEvent): Void {
		var rect = SystemImpl.khanvas.getBoundingClientRect();
		var borderWidth = SystemImpl.khanvas.clientLeft;
		var borderHeight = SystemImpl.khanvas.clientTop;
		mouseX = Std.int((event.clientX - rect.left - borderWidth) * SystemImpl.khanvas.width / (rect.width - 2 * borderWidth));
		mouseY = Std.int((event.clientY - rect.top - borderHeight) * SystemImpl.khanvas.height / (rect.height - 2 * borderHeight));
	}

	private static var iosSoundEnabled: Bool = false;

	private static function unlockiOSSound(): Void {
		if (!ios || iosSoundEnabled) return;

		var buffer = MobileWebAudio._context.createBuffer(1, 1, 22050);
		var source = MobileWebAudio._context.createBufferSource();
		source.buffer = buffer;
		source.connect(MobileWebAudio._context.destination);
		//untyped(if (source.noteOn) source.noteOn(0));
		source.start();
		source.stop();

		iosSoundEnabled = true;
	}

	static var soundEnabled = false;

	static function unlockSound(): Void {
		if (!soundEnabled) {
			var context = kha.audio2.Audio._context;

			if (context == null) {
				context = untyped __js__('kha_audio2_Audio1._context');
			}

			if (context != null) {
				context.resume().then(function(c) {
					soundEnabled = true;
				}).catchError(function(err) {
					trace(err);
				});
			}

			kha.audio2.Audio.wakeChannels();
		}
		unlockiOSSound();
	}

	private static function mouseLeave():Void {
		mouse.sendLeaveEvent(0);
	}

	private static function mouseWheel(event: WheelEvent): Bool {
		unlockSound();
		insideInputEvent = true;

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
		unlockSound();

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
		unlockSound();

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
		unlockSound();

		if (event.which != 2) return;

		insideInputEvent = true;
		khanvas.ownerDocument.removeEventListener('mouseup', mouseMiddleUp);
		mouse.sendUpEvent(0, 2, mouseX, mouseY);
		insideInputEvent = false;
	}

	private static function mouseRightUp(event: MouseEvent): Void {
		unlockSound();

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

		var lastMouseX = mouseX;
		var lastMouseY = mouseY;
		setMouseXY(event);

		var movementX = event.movementX;
		var movementY = event.movementY;

		if (event.movementX == null) {
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
		unlockSound();

		event.stopPropagation();
		event.preventDefault();

		var index = 0;
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
			if (index == 0) {
				lastFirstTouchX = touchX;
				lastFirstTouchY = touchY;
			}
			index++;
		}
		insideInputEvent = false;
	}

	private static function touchUp(event: TouchEvent): Void {
		insideInputEvent = true;
		unlockSound();

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
		unlockSound();

		var index = 0;
		for (touch in event.changedTouches) {
			setTouchXY(touch);
			if (index == 0) {
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
		unlockSound();

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
		insideInputEvent = true;
		unlockSound();

		if ((event.keyCode < 112 || event.keyCode > 123) //F1-F12
			&& (event.key != null && event.key.length != 1)) event.preventDefault();
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
		insideInputEvent = false;
	}

	private static function keyUp(event: KeyboardEvent): Void {
		insideInputEvent = true;
		unlockSound();

		event.preventDefault();
		event.stopPropagation();

		if (ie) pressedKeys[event.keyCode] = false;

		keyboard.sendUpEvent(cast event.keyCode);

		insideInputEvent = false;
	}

	private static function keyPress(event: KeyboardEvent): Void {
		insideInputEvent = true;
		unlockSound();

		if (event.which == 0) return; //for Firefox and Safari
		event.preventDefault();
		event.stopPropagation();
		keyboard.sendPressEvent(String.fromCharCode(event.which));

		insideInputEvent = false;
	}

	public static function canSwitchFullscreen(): Bool {
		return untyped __js__("'fullscreenElement ' in document ||
		'mozFullScreenElement' in document ||
		'webkitFullscreenElement' in document ||
		'msFullscreenElement' in document
		");
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

	public static function getPen(num: Int): kha.input.Pen {
		return null;
	}

	public static function safeZone(): Float {
		return 1.0;
	}
}
