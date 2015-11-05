package kha;

import kha.wpf.Graphics;
import system.diagnostics.Stopwatch;

class Sys {
	private static var watch: Stopwatch;
	
	public static var graphics(default, null): kha.wpf.Graphics;
	
	public static var mouse(default, null): kha.Mouse;
	
	public static var screenRotation: ScreenRotation = ScreenRotation.RotationNone;
	
	public static function init(): Void {
		mouse = new Mouse();
		graphics = new Graphics();
		watch = new Stopwatch();
		watch.Start();
	}
	
	@:functionCode('
		return watch.ElapsedMilliseconds / 1000.0;
	')
	public static function getTime(): Float {
		return 0;
	}
	
	public static function vsynced(): Bool {
		return true;
	}
	
	public static function refreshRate(): Int {
		return 60;
	}
	
	public static var pixelWidth: Int = 640;
	
	public static var pixelHeight: Int = 480;
	
	public static function systemId(): String {
		return "WPF";
	}
	
	@:functionCode('System.Windows.Application.Current.Shutdown();')
	public static function requestShutdown(): Void {
		
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
}
