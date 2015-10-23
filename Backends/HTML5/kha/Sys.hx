package kha;

import js.Browser;
import js.html.CanvasElement;

class Sys {
	public static var gl: Dynamic;
	@:noCompletion public static var _hasWebAudio: Bool;
	public static var screenRotation: ScreenRotation = ScreenRotation.RotationNone;
	//public static var graphics(default, null): Graphics;
	private static var theMouse: Mouse;
	public static var khanvas: CanvasElement;
	private static var performance: Dynamic;
	
	public static function initPerformanceTimer(): Void {
		if (Browser.window.performance != null) {
			performance = Browser.window.performance;
		}
		else {
			performance = untyped __js__("window.Date");
		}
	}
	
	public static function init(canvas: CanvasElement): Void {
		khanvas = canvas;
		theMouse = new kha.js.Mouse();
	}
	
	public static function getTime(): Float {
		return performance.now() / 1000;
	}
	
	public static var mouse(get, null): Mouse;
	
	public static function get_mouse(): Mouse {
		return theMouse;
	}
	
	public static var pixelWidth(get, null): Int;
	public static var pixelHeight(get, null): Int;
	
	public static function get_pixelWidth(): Int {
		return khanvas.width;
	}
	
	public static function get_pixelHeight(): Int {
		return khanvas.height;
	}
	
	public static function vsynced(): Bool {
		return true;
	}
	
	public static function refreshRate(): Int {
		return 60;
	}
	
	public static function systemId(): String {
		return "HTML5";
	}
	
	public static function requestShutdown(): Void {
		Browser.window.close();
	}

	public static function canSwitchFullscreen() : Bool{
		return untyped __js__("'fullscreenElement ' in document ||
        'mozFullScreenElement' in document ||
        'webkitFullscreenElement' in document ||
        'msFullscreenElement' in document
        ");
	}

	public static function isFullscreen() : Bool{
		return untyped __js__("document.fullscreenElement === this.khanvas ||
  			document.mozFullScreenElement === this.khanvas ||
  			document.webkitFullscreenElement === this.khanvas ||
  			document.msFullscreenElement === this.khanvas ");
	}

	public static function requestFullscreen(): Void {
		untyped if (khanvas.requestFullscreen) {
        	khanvas.requestFullscreen();
        } else if (khanvas.msRequestFullscreen) {
        	khanvas.msRequestFullscreen();
        } else if (khanvas.mozRequestFullScreen) {
        	khanvas.mozRequestFullScreen();
        } else if(khanvas.webkitRequestFullscreen){
        	khanvas.webkitRequestFullscreen();
        }
	}

	public static function exitFullscreen(): Void {
		untyped if (document.exitFullscreen) {
	      document.exitFullscreen();
	    } else if (document.msExitFullscreen) {
	      document.msExitFullscreen();
	    } else if (document.mozCancelFullScreen) {
	      document.mozCancelFullScreen();
	    } else if (document.webkitExitFullscreen) {
	      document.webkitExitFullscreen();
	    }
  	}

	public function notifyOfFullscreenChange(func : Void -> Void, error  : Void -> Void) : Void{
		js.Browser.document.addEventListener('fullscreenchange', func, false);
		js.Browser.document.addEventListener('mozfullscreenchange', func, false);
		js.Browser.document.addEventListener('webkitfullscreenchange', func, false);
		js.Browser.document.addEventListener('MSFullscreenChange', func, false);

		js.Browser.document.addEventListener('fullscreenerror', error, false);
		js.Browser.document.addEventListener('mozfullscreenerror', error, false);
		js.Browser.document.addEventListener('webkitfullscreenerror', error, false);
		js.Browser.document.addEventListener('MSFullscreenError', error, false);
	}


	public function removeFromFullscreenChange(func : Void -> Void, error  : Void -> Void) : Void{
		js.Browser.document.removeEventListener('fullscreenchange', func, false);
		js.Browser.document.removeEventListener('mozfullscreenchange', func, false);
		js.Browser.document.removeEventListener('webkitfullscreenchange', func, false);
		js.Browser.document.removeEventListener('MSFullscreenChange', func, false);

		js.Browser.document.removeEventListener('fullscreenerror', error, false);
		js.Browser.document.removeEventListener('mozfullscreenerror', error, false);
		js.Browser.document.removeEventListener('webkitfullscreenerror', error, false);
		js.Browser.document.removeEventListener('MSFullscreenError', error, false);
	}

}
