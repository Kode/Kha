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
	
	public static var pixelWidth: Int = 640;
	
	public static var pixelHeight: Int = 480;
}
