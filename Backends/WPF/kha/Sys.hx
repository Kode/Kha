package kha;

import kha.wpf.Graphics;
import system.diagnostics.Stopwatch;

class Sys {
	private static var watch: Stopwatch;
	
	public static var graphics: Graphics;
	
	public static function init(): Void {
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
}
