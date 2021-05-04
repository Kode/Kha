package kha;

import js.Syntax;
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
import kha.input.KeyCode;
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
	// public static var graphics(default, null): Graphics;
	public static var khanvas: CanvasElement;
	static var options: SystemOptions;
	public static var mobile: Bool = false;
	public static var ios: Bool = false;
	public static var mobileAudioPlaying: Bool = false;
	static var chrome: Bool = false;
	static var firefox: Bool = false;
	static var ie: Bool = false;
	public static var insideInputEvent: Bool = false;
	static var window: Window;
	public static var estimatedRefreshRate: Int = 60;

	static function errorHandler(message: String, source: String, lineno: Int, colno: Int, error: Dynamic) {
		Browser.console.error("Error: " + message);
		Browser.console.error("Stack:\n" + error.stack);
		return true;
	}

	public static function init(options: SystemOptions, callback: Window->Void): Void {
		SystemImpl.options = options;
		#if kha_debug_html5
		Browser.window.onerror = cast errorHandler;

		var showWindow = Syntax.code("window.electron.showWindow");
		showWindow(options.title, options.window.x, options.window.y, options.width, options.height);

		initSecondStep(callback);

		chrome = true;
		mobileAudioPlaying = true;
		#else
		mobile = isMobile();
		ios = isIOS();
		chrome = isChrome();
		firefox = isFirefox();
		ie = isIE();

		mobileAudioPlaying = !mobile && !chrome && !firefox;

		initSecondStep(callback);
		#end
	}

	static function initSecondStep(callback: Window->Void): Void {
		init2(options.window.width, options.window.height);
		initAnimate(callback);
	}

	public static function initSensor(): Void {
		if (ios) { // In Safari for iOS the directions are reversed on axes x, y and z
			Browser.window.ondevicemotion = function(event: DeviceMotionEvent) {
				Sensor._changed(0, -event.accelerationIncludingGravity.x, -event.accelerationIncludingGravity.y, -event.accelerationIncludingGravity.z);
			};
		}
		else {
			Browser.window.ondevicemotion = function(event: DeviceMotionEvent) {
				Sensor._changed(0, event.accelerationIncludingGravity.x, event.accelerationIncludingGravity.y, event.accelerationIncludingGravity.z);
			};
		}
		Browser.window.ondeviceorientation = function(event: DeviceOrientationEvent) {
			Sensor._changed(1, event.beta, event.gamma, event.alpha);
		};
	}

	static function isMobile(): Bool {
		var agent = js.Browser.navigator.userAgent;
		if (agent.indexOf("Android") >= 0 || agent.indexOf("webOS") >= 0 || agent.indexOf("BlackBerry") >= 0 || agent.indexOf("Windows Phone") >= 0) {
			return true;
		}
		if (isIOS())
			return true;
		return false;
	}

	static function isIOS(): Bool {
		var agent = js.Browser.navigator.userAgent;
		if (agent.indexOf("iPhone") >= 0 || agent.indexOf("iPad") >= 0 || agent.indexOf("iPod") >= 0) {
			return true;
		}
		return false;
	}

	static function isChrome(): Bool {
		var agent = js.Browser.navigator.userAgent;
		if (agent.indexOf("Chrome") >= 0) {
			return true;
		}
		return false;
	}

	static function isFirefox(): Bool {
		var agent = js.Browser.navigator.userAgent;
		if (agent.indexOf("Firefox") >= 0) {
			return true;
		}
		return false;
	}

	static function isIE(): Bool {
		var agent = js.Browser.navigator.userAgent;
		if (agent.indexOf("MSIE ") >= 0 || agent.indexOf("Trident/") >= 0) {
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
		final now = js.Browser.window.performance != null ? js.Browser.window.performance.now() : js.lib.Date.now();
		return now / 1000;
	}

	public static function getSystemId(): String {
		return "HTML5";
	}

	public static function vibrate(ms: Int): Void {
		Browser.navigator.vibrate(ms);
	}

	public static function getLanguage(): String {
		final lang = Browser.navigator.language;
		return lang.substr(0, 2).toLowerCase();
	}

	public static function requestShutdown(): Bool {
		Browser.window.close();
		return true;
	}

	static inline var maxGamepads: Int = 4;
	static var frame: Framebuffer;
	static var pressedKeys: Array<Bool>;
	static var keyboard: Keyboard = null;
	static var mouse: kha.input.Mouse;
	static var surface: Surface;
	static var gamepads: Array<Gamepad>;
	static var gamepadStates: Array<GamepadStates>;

	static var minimumScroll: Int = 999;
	static var mouseX: Int;
	static var mouseY: Int;
	static var touchX: Int;
	static var touchY: Int;
	static var lastFirstTouchX: Int = 0;
	static var lastFirstTouchY: Int = 0;

	static function init2(defaultWidth: Int, defaultHeight: Int, ?backbufferFormat: TextureFormat) {
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
		js.Browser.window.addEventListener("gamepadconnected", (e) -> {
			Gamepad.sendConnectEvent(e.gamepad.index);
		});
		js.Browser.window.addEventListener("gamepaddisconnected", (e) -> {
			Gamepad.sendDisconnectEvent(e.gamepad.index);
		});
		var sysGamepads = getGamepads();
		if (sysGamepads != null) {
			for (i in 0...sysGamepads.length) {
				var pad = sysGamepads[i];
				if (pad != null) {
					gamepads[pad.index].connected = true;
				}
			}
		}

		if (ie) {
			pressedKeys = new Array<Bool>();
			for (i in 0...256)
				pressedKeys.push(false);
			for (i in 0...256)
				pressedKeys.push(null);
		}

		function onCopy(e: ClipboardEvent): Void {
			if (System.copyListener != null) {
				var data = System.copyListener();
				if (data != null)
					e.clipboardData.setData("text/plain", data);
				e.preventDefault();
			}
		}

		function onCut(e: ClipboardEvent): Void {
			if (System.cutListener != null) {
				var data = System.cutListener();
				if (data != null)
					e.clipboardData.setData("text/plain", data);
				e.preventDefault();
			}
		}

		function onPaste(e: ClipboardEvent): Void {
			if (System.pasteListener != null) {
				System.pasteListener(e.clipboardData.getData("text/plain"));
				e.preventDefault();
			}
		}

		var document = Browser.document;
		document.addEventListener("copy", onCopy);
		document.addEventListener("cut", onCut);
		document.addEventListener("paste", onPaste);

		CanvasImage.init();
		Scheduler.init();

		loadFinished(defaultWidth, defaultHeight);
	}

	public static function copyToClipboard(text: String) {
		var textArea = Browser.document.createElement("textarea");
		untyped textArea.value = text;
		textArea.style.top = "0";
		textArea.style.left = "0";
		textArea.style.position = "fixed";
		Browser.document.body.appendChild(textArea);
		textArea.focus();
		untyped textArea.select();
		try {
			Browser.document.execCommand("copy");
		}
		catch (err) {}
		Browser.document.body.removeChild(textArea);
	}

	public static function getMouse(num: Int): Mouse {
		if (num != 0)
			return null;
		return mouse;
	}

	public static function getKeyboard(num: Int): Keyboard {
		if (num != 0)
			return null;
		return keyboard;
	}

	static function checkGamepad(pad: js.html.Gamepad) {
		for (i in 0...pad.axes.length) {
			if (pad.axes[i] != null) {
				var axis = pad.axes[i];
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

	static function getCanvasElement(): CanvasElement {
		if (khanvas != null)
			return khanvas;
		// Only consider custom canvas ID for release builds
		#if (kha_debug_html5 || !canvas_id)
		return cast Browser.document.getElementById("khanvas");
		#else
		return cast Browser.document.getElementById(Macros.canvasId());
		#end
	}

	static function loadFinished(defaultWidth: Int, defaultHeight: Int) {
		var canvas: CanvasElement = getCanvasElement();
		canvas.style.cursor = "default";

		var gl: Bool = false;

		#if kha_webgl
		try {
			SystemImpl.gl = canvas.getContext("webgl2",
				{
					alpha: false,
					antialias: options.framebuffer.samplesPerPixel > 1,
					stencil: true
				}); // preserveDrawingBuffer: true } ); Warning: preserveDrawingBuffer can cause huge performance issues on mobile browsers
			SystemImpl.gl.pixelStorei(GL.UNPACK_PREMULTIPLY_ALPHA_WEBGL, 1);

			halfFloat = {HALF_FLOAT_OES: 0x140B}; // GL_HALF_FLOAT
			depthTexture = {UNSIGNED_INT_24_8_WEBGL: 0x84FA}; // GL_UNSIGNED_INT_24_8
			drawBuffers = {COLOR_ATTACHMENT0_WEBGL: GL.COLOR_ATTACHMENT0};
			elementIndexUint = true;
			SystemImpl.gl.getExtension("EXT_color_buffer_float");
			SystemImpl.gl.getExtension("OES_texture_float_linear");
			SystemImpl.gl.getExtension("OES_texture_half_float_linear");
			anisotropicFilter = SystemImpl.gl.getExtension("EXT_texture_filter_anisotropic");
			if (anisotropicFilter == null)
				anisotropicFilter = SystemImpl.gl.getExtension("WEBKIT_EXT_texture_filter_anisotropic");

			gl = true;
			gl2 = true;
			Shaders.init();
		}
		catch (e:Dynamic) {
			trace("Could not initialize WebGL 2, falling back to WebGL.");
		}

		if (!gl2) {
			try {
				SystemImpl.gl = canvas.getContext("experimental-webgl",
					{
						alpha: false,
						antialias: options.framebuffer.samplesPerPixel > 1,
						stencil: true
					}); // preserveDrawingBuffer: true } ); WARNING: preserveDrawingBuffer causes huge performance issues (on mobile browser)!
				SystemImpl.gl.pixelStorei(GL.UNPACK_PREMULTIPLY_ALPHA_WEBGL, 1);
				SystemImpl.gl.getExtension("OES_texture_float");
				SystemImpl.gl.getExtension("OES_texture_float_linear");
				halfFloat = SystemImpl.gl.getExtension("OES_texture_half_float");
				SystemImpl.gl.getExtension("OES_texture_half_float_linear");
				depthTexture = SystemImpl.gl.getExtension("WEBGL_depth_texture");
				SystemImpl.gl.getExtension("EXT_shader_texture_lod");
				SystemImpl.gl.getExtension("OES_standard_derivatives");
				anisotropicFilter = SystemImpl.gl.getExtension("EXT_texture_filter_anisotropic");
				if (anisotropicFilter == null)
					anisotropicFilter = SystemImpl.gl.getExtension("WEBKIT_EXT_texture_filter_anisotropic");
				drawBuffers = SystemImpl.gl.getExtension("WEBGL_draw_buffers");
				elementIndexUint = SystemImpl.gl.getExtension("OES_element_index_uint");
				gl = true;
				Shaders.init();
			}
			catch (e:Dynamic) {
				trace("Could not initialize WebGL, falling back to <canvas>.");
			}
		}
		#end

		setCanvas(canvas);
		window = new Window(0, defaultWidth, defaultHeight, canvas);

		// var widthTransform: Float = canvas.width / Loader.the.width;
		// var heightTransform: Float = canvas.height / Loader.the.height;
		// var transform: Float = Math.min(widthTransform, heightTransform);
		if (gl) {
			var g4 = new kha.js.graphics4.Graphics();
			frame = new Framebuffer(0, null, null, g4);
			frame.init(new kha.graphics2.Graphics1(frame), new kha.js.graphics4.Graphics2(frame), g4); // new kha.graphics1.Graphics4(frame));
		}
		else {
			Syntax.code("kha_js_Font.Kravur = kha_Kravur; kha_Kravur = kha_js_Font");
			var g2 = new CanvasGraphics(canvas.getContext("2d"));
			frame = new Framebuffer(0, null, g2, null);
			frame.init(new kha.graphics2.Graphics1(frame), g2, null);
		}
		// canvas.getContext("2d").scale(transform, transform);

		if (!mobile && kha.audio2.Audio._init()) {
			SystemImpl._hasWebAudio = true;
			kha.audio2.Audio1._init();
		}
		else if (mobile) {
			SystemImpl._hasWebAudio = false;
			MobileWebAudio._init();
			Syntax.code("kha_audio2_Audio1 = kha_js_MobileWebAudio");
		}
		else {
			SystemImpl._hasWebAudio = false;
			Syntax.code("kha_audio2_Audio1 = kha_js_AudioElementAudio");
		}

		kha.vr.VrInterface.instance = new VrInterface();

		// Autofocus
		canvas.focus();

		#if kha_disable_context_menu
		canvas.oncontextmenu = function(event: Dynamic) {
			event.stopPropagation();
			event.preventDefault();
		}
		#end

		canvas.onmousedown = mouseDown;
		canvas.onmousemove = mouseMove;
		if (keyboard != null) {
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

		Browser.document.addEventListener("dragover", function(event) {
			event.preventDefault();
		});

		Browser.document.addEventListener("drop", function(event: js.html.DragEvent) {
			event.preventDefault();
			if (event.dataTransfer != null && event.dataTransfer.files != null) {
				for (file in event.dataTransfer.files) {
					LoaderImpl.dropFiles.set(file.name, file);
					System.dropFiles("drop://" + file.name);
				}
			}
		});

		Browser.window.addEventListener("unload", function() {
			System.shutdown();
		});
	}

	static function initAnimate(callback: Window->Void) {
		var canvas: CanvasElement = getCanvasElement();

		var window: Dynamic = Browser.window;
		var requestAnimationFrame = window.requestAnimationFrame;
		if (requestAnimationFrame == null)
			requestAnimationFrame = window.mozRequestAnimationFrame;
		if (requestAnimationFrame == null)
			requestAnimationFrame = window.webkitRequestAnimationFrame;
		if (requestAnimationFrame == null)
			requestAnimationFrame = window.msRequestAnimationFrame;

		function animate(timestamp) {
			var window: Dynamic = Browser.window;
			if (requestAnimationFrame == null)
				window.setTimeout(animate, 1000.0 / 60.0);
			else
				requestAnimationFrame(animate);

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
				// clientWidth/Height is in downscaled "css pixels" when a <meta viewport="" /> is set in the html file
				var displayWidth = Std.int(canvas.clientWidth);
				var displayHeight = Std.int(canvas.clientHeight);

				// Check if the canvas rendering buffer is not the same size.
				if (canvas.width != displayWidth || canvas.height != displayHeight) {
					// Make the canvas rendering buffer the same size
					canvas.width = displayWidth;
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

		var initialTimestamp: Int = 0;
		var prevTimestamp: Int = 0;
		var currentSamples: Int = 0;
		var timeDiffs: Array<Int> = [];

		var SAMPLE_COUNT: Int = 90;
		var MEAN_TRUNCATION_CUTOFF: Float = 1 / 3;

		function roundToKnownRefreshRate(hz: Int): Int {
			var hz30 = {low: 27, high: 33, target: 30};
			var hz60 = {low: 57, high: 63, target: 60};
			var hz75 = {low: 72, high: 78, target: 75};
			var hz90 = {low: 87, high: 93, target: 90};
			var hz120 = {low: 117, high: 123, target: 120};
			var hz144 = {low: 141, high: 147, target: 144};
			var hz240 = {low: 237, high: 243, target: 240};
			var hz340 = {low: 337, high: 343, target: 340};
			var hz360 = {low: 357, high: 363, target: 360};

			var rates = [hz30, hz60, hz75, hz90, hz120, hz144, hz240, hz340, hz360];

			var nearestHz = hz;
			for (rate in rates) {
				if (hz >= rate.low && hz <= rate.high) {
					nearestHz = rate.target;
				}
			}

			return nearestHz;
		}

		// HTML5 has no real way to query the actual monitor refresh rate
		// The only thing that can be done is attempt to measure the interval between requestAnimationFrame calls
		// Without requestAnimationFrame we're out of luck
		// We try and make a best guess while nothing intensive is happening
		function detectRefreshRate(timestamp) {
			var window: Dynamic = Browser.window;

			if (initialTimestamp == 0) {
				initialTimestamp = timestamp;
			}
			var timeDifferential = (timestamp - prevTimestamp) - initialTimestamp;
			prevTimestamp = timestamp - initialTimestamp;

			if (timeDifferential != 0) {
				timeDiffs.push(timeDifferential);
			}

			if (currentSamples < SAMPLE_COUNT) {
				currentSamples++;

				if (requestAnimationFrame == null)
					window.setTimeout(detectRefreshRate, 1000.0 / 60.0);
				else
					requestAnimationFrame(detectRefreshRate);
			}
			else {
				// Remove extreme frametime values before averaging
				{
					haxe.ds.ArraySort.sort(timeDiffs, (a, b) -> {
						a - b;
					});

					var truncatedTimeDiffs: Array<Int> = [];
					var cutoff = Math.round(timeDiffs.length * MEAN_TRUNCATION_CUTOFF);
					for (i in cutoff...timeDiffs.length - cutoff) {
						truncatedTimeDiffs.push(timeDiffs[i]);
					}

					var total = 0;
					for (time in truncatedTimeDiffs) {
						total += time;
					}

					var avg = total / truncatedTimeDiffs.length;
					// We may have an accurate frequency, but it might be possible to be off the actual refresh rate by a few hz
					// Manually round to common refresh rates as well, just for security's sake
					estimatedRefreshRate = roundToKnownRefreshRate(Math.round(1000 / avg));
				}

				Scheduler.start();

				if (requestAnimationFrame == null)
					window.setTimeout(animate, 1000.0 / 60.0);
				else
					requestAnimationFrame(animate);

				callback(SystemImpl.window);
			}
		}

		// Run through refresh rate detection first and then start animating
		if (requestAnimationFrame == null)
			window.setTimeout(detectRefreshRate, 1000.0 / 60.0);
		else
			requestAnimationFrame(detectRefreshRate);
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
		return Syntax.code("'pointerLockElement' in document ||
		'mozPointerLockElement' in document ||
		'webkitPointerLockElement' in document");
	}

	public static function isMouseLocked(): Bool {
		return Syntax.code("document.pointerLockElement === kha_SystemImpl.khanvas ||
			document.mozPointerLockElement === kha_SystemImpl.khanvas ||
			document.webkitPointerLockElement === kha_SystemImpl.khanvas");
	}

	public static function notifyOfMouseLockChange(func: Void->Void, error: Void->Void): Void {
		js.Browser.document.addEventListener("pointerlockchange", func, false);
		js.Browser.document.addEventListener("mozpointerlockchange", func, false);
		js.Browser.document.addEventListener("webkitpointerlockchange", func, false);

		js.Browser.document.addEventListener("pointerlockerror", error, false);
		js.Browser.document.addEventListener("mozpointerlockerror", error, false);
		js.Browser.document.addEventListener("webkitpointerlockerror", error, false);
	}

	public static function removeFromMouseLockChange(func: Void->Void, error: Void->Void): Void {
		js.Browser.document.removeEventListener("pointerlockchange", func, false);
		js.Browser.document.removeEventListener("mozpointerlockchange", func, false);
		js.Browser.document.removeEventListener("webkitpointerlockchange", func, false);

		js.Browser.document.removeEventListener("pointerlockerror", error, false);
		js.Browser.document.removeEventListener("mozpointerlockerror", error, false);
		js.Browser.document.removeEventListener("webkitpointerlockerror", error, false);
	}

	static function setMouseXY(event: MouseEvent): Void {
		var rect = SystemImpl.khanvas.getBoundingClientRect();
		var borderWidth = SystemImpl.khanvas.clientLeft;
		var borderHeight = SystemImpl.khanvas.clientTop;
		mouseX = Std.int((event.clientX - rect.left - borderWidth) * SystemImpl.khanvas.width / (rect.width - 2 * borderWidth));
		mouseY = Std.int((event.clientY - rect.top - borderHeight) * SystemImpl.khanvas.height / (rect.height - 2 * borderHeight));
	}

	static var iosSoundEnabled: Bool = false;

	static function unlockiOSSound(): Void {
		if (!ios || iosSoundEnabled)
			return;

		var buffer = MobileWebAudio._context.createBuffer(1, 1, 22050);
		var source = MobileWebAudio._context.createBufferSource();
		source.buffer = buffer;
		source.connect(MobileWebAudio._context.destination);
		// untyped(if (source.noteOn) source.noteOn(0));
		source.start();
		source.stop();

		iosSoundEnabled = true;
	}

	static var soundEnabled = false;

	static function unlockSound(): Void {
		if (!soundEnabled) {
			var context = kha.audio2.Audio._context;

			if (context == null) {
				context = Syntax.code("kha_audio2_Audio1._context");
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

	static function mouseLeave(): Void {
		mouse.sendLeaveEvent(0);
	}

	static function mouseWheel(event: WheelEvent): Void {
		unlockSound();
		insideInputEvent = true;

		switch (Mouse.wheelEventBlockBehavior) {
			case Full:
				event.preventDefault();
			case Custom(func):
				if (func(event))
					event.preventDefault();
			case None:
		}

		// Deltamode == 0, deltaY is in pixels.
		if (event.deltaMode == 0) {
			if (event.deltaY < 0) {
				mouse.sendWheelEvent(0, -1);
			}
			else if (event.deltaY > 0) {
				mouse.sendWheelEvent(0, 1);
			}
			insideInputEvent = false;
			return;
		}

		// Lines
		if (event.deltaMode == 1) {
			minimumScroll = Std.int(Math.min(minimumScroll, Math.abs(event.deltaY)));
			mouse.sendWheelEvent(0, Std.int(event.deltaY / minimumScroll));
			insideInputEvent = false;
			return;
		}
		insideInputEvent = false;
		return;
	}

	static function mouseDown(event: MouseEvent): Void {
		insideInputEvent = true;
		unlockSound();

		setMouseXY(event);
		if (event.which == 1) { // left button
			mouse.sendDownEvent(0, 0, mouseX, mouseY);

			if (khanvas.setCapture != null) {
				khanvas.setCapture();
			}
			else {
				khanvas.ownerDocument.addEventListener("mousemove", documentMouseMove, true);
			}
			khanvas.ownerDocument.addEventListener("mouseup", mouseLeftUp);
		}
		else if (event.which == 2) { // middle button
			mouse.sendDownEvent(0, 2, mouseX, mouseY);
			khanvas.ownerDocument.addEventListener("mouseup", mouseMiddleUp);
		}
		else if (event.which == 3) { // right button
			mouse.sendDownEvent(0, 1, mouseX, mouseY);
			khanvas.ownerDocument.addEventListener("mouseup", mouseRightUp);
		}
		else if (event.which == 4) { // backwards sidebutton
			mouse.sendDownEvent(0, 3, mouseX, mouseY);
			khanvas.ownerDocument.addEventListener("mouseup", mouseBackUp);
		}
		else if (event.which == 5) { // forwards sidebutton
			mouse.sendDownEvent(0, 4, mouseX, mouseY);
			khanvas.ownerDocument.addEventListener("mouseup", mouseForwardUp);
		}
		insideInputEvent = false;
	}

	static function mouseLeftUp(event: MouseEvent): Void {
		unlockSound();

		if (event.which != 1)
			return;

		insideInputEvent = true;
		khanvas.ownerDocument.removeEventListener("mouseup", mouseLeftUp);
		if (khanvas.releaseCapture != null) {
			khanvas.ownerDocument.releaseCapture();
		}
		else {
			khanvas.ownerDocument.removeEventListener("mousemove", documentMouseMove, true);
		}

		mouse.sendUpEvent(0, 0, mouseX, mouseY);

		insideInputEvent = false;
	}

	static function mouseMiddleUp(event: MouseEvent): Void {
		unlockSound();

		if (event.which != 2)
			return;

		insideInputEvent = true;
		khanvas.ownerDocument.removeEventListener("mouseup", mouseMiddleUp);
		mouse.sendUpEvent(0, 2, mouseX, mouseY);
		insideInputEvent = false;
	}

	static function mouseRightUp(event: MouseEvent): Void {
		unlockSound();

		if (event.which != 3)
			return;

		insideInputEvent = true;
		khanvas.ownerDocument.removeEventListener("mouseup", mouseRightUp);
		mouse.sendUpEvent(0, 1, mouseX, mouseY);
		insideInputEvent = false;
	}

	static function mouseBackUp(event: MouseEvent): Void {
		unlockSound();

		if (event.which != 4)
			return;

		insideInputEvent = true;
		khanvas.ownerDocument.removeEventListener("mouseup", mouseBackUp);
		mouse.sendUpEvent(0, 3, mouseX, mouseY);
		insideInputEvent = false;
	}

	static function mouseForwardUp(event: MouseEvent): Void {
		unlockSound();

		if (event.which != 5)
			return;

		insideInputEvent = true;
		khanvas.ownerDocument.removeEventListener("mouseup", mouseForwardUp);
		mouse.sendUpEvent(0, 4, mouseX, mouseY);
		insideInputEvent = false;
	}

	static function documentMouseMove(event: MouseEvent): Void {
		event.stopPropagation();
		mouseMove(event);
	}

	static function mouseMove(event: MouseEvent): Void {
		insideInputEvent = true;

		var lastMouseX = mouseX;
		var lastMouseY = mouseY;
		setMouseXY(event);

		var movementX = event.movementX;
		var movementY = event.movementY;

		if (event.movementX == null) {
			movementX = (untyped event.mozMovementX != null) ? untyped event.mozMovementX : ((untyped event.webkitMovementX != null) ? untyped event.webkitMovementX : (mouseX
				- lastMouseX));
			movementY = (untyped event.mozMovementY != null) ? untyped event.mozMovementY : ((untyped event.webkitMovementY != null) ? untyped event.webkitMovementY : (mouseY
				- lastMouseY));
		}

		// this ensures same behaviour across browser until they fix it
		if (firefox) {
			movementX = Std.int(movementX * Browser.window.devicePixelRatio);
			movementY = Std.int(movementY * Browser.window.devicePixelRatio);
		}

		mouse.sendMoveEvent(0, mouseX, mouseY, movementX, movementY);
		insideInputEvent = false;
	}

	static function setTouchXY(touch: Touch): Void {
		var rect = SystemImpl.khanvas.getBoundingClientRect();
		var borderWidth = SystemImpl.khanvas.clientLeft;
		var borderHeight = SystemImpl.khanvas.clientTop;
		touchX = Std.int((touch.clientX - rect.left - borderWidth) * SystemImpl.khanvas.width / (rect.width - 2 * borderWidth));
		touchY = Std.int((touch.clientY - rect.top - borderHeight) * SystemImpl.khanvas.height / (rect.height - 2 * borderHeight));
	}

	static var iosTouchs: Array<Int> = [];

	static function touchDown(event: TouchEvent): Void {
		insideInputEvent = true;
		unlockSound();

		event.stopPropagation();

		switch (Surface.touchDownEventBlockBehavior) {
			case Full:
				event.preventDefault();
			case Custom(func):
				if (func(event))
					event.preventDefault();
			case None:
		}

		var index = 0;
		for (touch in event.changedTouches) {
			var id = touch.identifier;
			if (ios) {
				id = iosTouchs.indexOf(-1);
				if (id == -1)
					id = iosTouchs.length;
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

	static function touchUp(event: TouchEvent): Void {
		insideInputEvent = true;
		unlockSound();

		for (touch in event.changedTouches) {
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

	static function touchMove(event: TouchEvent): Void {
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
			if (ios)
				id = iosTouchs.indexOf(id);

			surface.sendMoveEvent(id, touchX, touchY);
			index++;
		}
		insideInputEvent = false;
	}

	static function touchCancel(event: TouchEvent): Void {
		insideInputEvent = true;
		unlockSound();

		for (touch in event.changedTouches) {
			var id = touch.identifier;
			if (ios)
				id = iosTouchs.indexOf(id);

			setTouchXY(touch);
			mouse.sendUpEvent(0, 0, touchX, touchY);
			surface.sendTouchEndEvent(id, touchX, touchY);
		}
		iosTouchs = [];
		insideInputEvent = false;
	}

	static function onBlur() {
		// System.pause();
		System.background();
	}

	static function onFocus() {
		// System.resume();
		System.foreground();
	}

	static function keycodeToChar(key: String, keycode: Int, shift: Bool): String {
		if (key != null) {
			if (key.length == 1)
				return key;
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
				if (shift)
					return "*";
				else
					return "+";
			case 188:
				if (shift)
					return ";";
				else
					return ",";
			case 189:
				if (shift)
					return "_";
				else
					return "-";
			case 190:
				if (shift)
					return ":";
				else
					return ".";
			case 191:
				if (shift)
					return "'";
				else
					return "#";
			case 226:
				if (shift)
					return ">";
				else
					return "<";
			case 106:
				return "*";
			case 107:
				return "+";
			case 109:
				return "-";
			case 111:
				return "/";
			case 49:
				if (shift)
					return "!";
				else
					return "1";
			case 50:
				if (shift)
					return "\"";
				else
					return "2";
			case 51:
				if (shift)
					return "§";
				else
					return "3";
			case 52:
				if (shift)
					return "$";
				else
					return "4";
			case 53:
				if (shift)
					return "%";
				else
					return "5";
			case 54:
				if (shift)
					return "&";
				else
					return "6";
			case 55:
				if (shift)
					return "/";
				else
					return "7";
			case 56:
				if (shift)
					return "(";
				else
					return "8";
			case 57:
				if (shift)
					return ")";
				else
					return "9";
			case 48:
				if (shift)
					return "=";
				else
					return "0";
			case 219:
				if (shift)
					return "?";
				else
					return "ß";
			case 212:
				if (shift)
					return "`";
				else
					return "´";
		}
		if (keycode >= 96 && keycode <= 105) { // num block
			return String.fromCharCode("0".code - 96 + keycode);
		}
		if (keycode >= "A".code && keycode <= "Z".code) {
			if (shift)
				return String.fromCharCode(keycode);
			else
				return String.fromCharCode(keycode - "A".code + "a".code);
		}
		return String.fromCharCode(keycode);
	}

	static function keyDown(event: KeyboardEvent): Void {
		insideInputEvent = true;
		unlockSound();

		switch (Keyboard.keyBehavior) {
			case Default:
				defaultKeyBlock(event);
			case Full:
				event.preventDefault();
			case Custom(func):
				if (func(cast event.keyCode))
					event.preventDefault();
			case None:
		}
		event.stopPropagation();

		// prevent key repeat
		if (ie) {
			if (pressedKeys[event.keyCode]) {
				event.preventDefault();
				return;
			}
			pressedKeys[event.keyCode] = true;
		}
		else if (event.repeat) {
			event.preventDefault();
			return;
		}
		var keyCode = fixedKeyCode(event);
		keyboard.sendDownEvent(keyCode);
		insideInputEvent = false;
	}

	static function fixedKeyCode(event: KeyboardEvent): KeyCode {
		return switch (event.keyCode) {
			case 91, 93: Meta; // left/right in Chrome
			case 186: Semicolon;
			case 187: Equals;
			case 189: HyphenMinus;
			default:
				cast event.keyCode;
		}
	}

	static function defaultKeyBlock(e: KeyboardEvent): Void {
		// block if ctrl key pressed
		if (e.ctrlKey || e.metaKey) {
			// except for cut-copy-paste
			if (e.keyCode == 67 || e.keyCode == 88 || e.keyCode == 86) {
				return;
			}
			// and quit on macOS
			if (e.metaKey && e.keyCode == 81) {
				return;
			}
			e.preventDefault();
			return;
		}
		// allow F-keys
		if (e.keyCode >= 112 && e.keyCode <= 123)
			return;
		// allow char keys
		if (e.key == null || e.key.length == 1)
			return;
		e.preventDefault();
	}

	static function keyUp(event: KeyboardEvent): Void {
		insideInputEvent = true;
		unlockSound();

		event.preventDefault();
		event.stopPropagation();

		if (ie)
			pressedKeys[event.keyCode] = false;

		var keyCode = fixedKeyCode(event);
		keyboard.sendUpEvent(keyCode);

		insideInputEvent = false;
	}

	static function keyPress(event: KeyboardEvent): Void {
		insideInputEvent = true;
		unlockSound();

		if (event.which == 0)
			return; // for Firefox and Safari
		event.preventDefault();
		event.stopPropagation();
		keyboard.sendPressEvent(String.fromCharCode(event.which));

		insideInputEvent = false;
	}

	public static function canSwitchFullscreen(): Bool {
		return Syntax.code("'fullscreenElement ' in document ||
		'mozFullScreenElement' in document ||
		'webkitFullscreenElement' in document ||
		'msFullscreenElement' in document
		");
	}

	public static function notifyOfFullscreenChange(func: Void->Void, error: Void->Void): Void {
		js.Browser.document.addEventListener("fullscreenchange", func, false);
		js.Browser.document.addEventListener("mozfullscreenchange", func, false);
		js.Browser.document.addEventListener("webkitfullscreenchange", func, false);
		js.Browser.document.addEventListener("MSFullscreenChange", func, false);

		js.Browser.document.addEventListener("fullscreenerror", error, false);
		js.Browser.document.addEventListener("mozfullscreenerror", error, false);
		js.Browser.document.addEventListener("webkitfullscreenerror", error, false);
		js.Browser.document.addEventListener("MSFullscreenError", error, false);
	}

	public static function removeFromFullscreenChange(func: Void->Void, error: Void->Void): Void {
		js.Browser.document.removeEventListener("fullscreenchange", func, false);
		js.Browser.document.removeEventListener("mozfullscreenchange", func, false);
		js.Browser.document.removeEventListener("webkitfullscreenchange", func, false);
		js.Browser.document.removeEventListener("MSFullscreenChange", func, false);

		js.Browser.document.removeEventListener("fullscreenerror", error, false);
		js.Browser.document.removeEventListener("mozfullscreenerror", error, false);
		js.Browser.document.removeEventListener("webkitfullscreenerror", error, false);
		js.Browser.document.removeEventListener("MSFullscreenError", error, false);
	}

	public static function setKeepScreenOn(on: Bool): Void {}

	public static function loadUrl(url: String): Void {
		js.Browser.window.open(url, "_blank");
	}

	public static function getGamepadId(index: Int): String {
		var sysGamepads = getGamepads();
		if (sysGamepads != null && untyped sysGamepads[index]) {
			return sysGamepads[index].id;
		}

		return "unknown";
	}

	public static function getGamepadVendor(index: Int): String {
		return "unknown";
	}

	public static function setGamepadRumble(index: Int, leftAmount: Float, rightAmount: Float) {}

	static function getGamepads(): Array<js.html.Gamepad> {
		if (chrome && kha.vr.VrInterface.instance != null && kha.vr.VrInterface.instance.IsVrEnabled()) {
			return null; // Chrome crashes if navigator.getGamepads() is called when using VR
		}

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

	public static function login(): Void {}

	public static function automaticSafeZone(): Bool {
		return true;
	}

	public static function setSafeZone(value: Float): Void {}

	public static function unlockAchievement(id: Int): Void {}

	public static function waitingForLogin(): Bool {
		return false;
	}

	public static function disallowUserChange(): Void {}

	public static function allowUserChange(): Void {}
}
