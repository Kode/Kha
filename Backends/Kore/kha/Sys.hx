package kha;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Application.h>
#include <Kore/System.h>
')

class Sys {
	public static var needs3d: Bool = false;
	
	//public static var graphics(default, null): kha.graphics.Graphics;

	public static var mouse(default, null): kha.Mouse;
	
	public static var screenRotation: ScreenRotation = ScreenRotation.RotationNone;

	private static var fullscreenListeners: Array<Void->Void> = new Array();
	private static var previousWidth : Int = 0;
	private static var previousHeight : Int = 0;
	
	public static function init(): Void {
		mouse = new kha.kore.Mouse();
		//graphics = new Graphics();
	}
	
	@:functionCode('
		return Kore::System::time();
	')
	public static function getTime(): Float {
		return 0;
	}
	
	public static var pixelWidth(get, null): Int;
	public static var pixelHeight(get, null): Int;
	
	@:functionCode('return Kore::System::screenWidth();')
	public static function get_pixelWidth(): Int {
		return 0;
	}
	
	@:functionCode('return Kore::System::screenHeight();')
	public static function get_pixelHeight(): Int {
		return 0;
	}
	
	public static function vsynced(): Bool {
		return true;
	}
	
	public static function refreshRate(): Int {
		return 60;
	}

	@:functionCode('return ::String(Kore::System::systemId());')
	public static function systemId(): String {
		return '';
	}
	
	@:functionCode('Kore::Application::the()->stop();')
	public static function requestShutdown(): Void {
		
	}

	public static function canSwitchFullscreen() : Bool{
		return true;
	}

	@:functionCode('return Kore::Application::the()->fullscreen();')
	public static function isFullscreen() : Bool{
		return false;
	}

	public static function requestFullscreen(): Void {
		if(!isFullscreen()){
			previousWidth = untyped __cpp__("Kore::Application::the()->width();");
			previousHeight = untyped __cpp__("Kore::Application::the()->height();");
			untyped __cpp__("Kore::System::changeResolution(Kore::System::desktopWidth(),Kore::System::desktopHeight(), true);");
			for (listener in fullscreenListeners) {
				listener();
			}
		}
		
	}

	public static function exitFullscreen(): Void {
		if(isFullscreen()){
			if (previousWidth == 0 || previousHeight == 0){
				previousWidth = untyped __cpp__("Kore::Application::the()->width();");
				previousHeight = untyped __cpp__("Kore::Application::the()->height();");
			}
			untyped __cpp__("Kore::System::changeResolution(previousWidth,previousHeight, false);");
			for (listener in fullscreenListeners) {
				listener();
			}
		}
  	}

	public function notifyOfFullscreenChange(func : Void -> Void, error  : Void -> Void) : Void{
		if(canSwitchFullscreen() && func != null){
			fullscreenListeners.push(func);
		}
	}


	public function removeFromFullscreenChange(func : Void -> Void, error  : Void -> Void) : Void{
		if(canSwitchFullscreen() && func != null){
			fullscreenListeners.remove(func);
		}	
	}
}
