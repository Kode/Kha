package kha;

import system.diagnostics.Stopwatch;

class Sys {
	private static var watch: Stopwatch;
	
	public static function init(): Void {
		watch = new Stopwatch();
		watch.Start();
	}
	
	public static function getFrequency(): Int {
		return 1000;
	}
	
	@:functionBody('
		return (int) watch.ElapsedMilliseconds;
	')
	public static function getTimestamp(): Int {
		return 0;
	}
}