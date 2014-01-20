package kha;

import kha.psm.Graphics;
//import system.diagnostics.Stopwatch;

class Sys {
	//private static var watch: Stopwatch;
	
	public static var graphics: Graphics;
	
	public static function init(): Void {
		graphics = new Graphics();
		//watch = new Stopwatch();
		//watch.Start();
	}
	
	public static function getFrequency(): Int {
		return 1000;
	}
	
	//@:functionCode('
	//	return (int) watch.ElapsedMilliseconds;
	//')
	public static function getTimestamp(): Int {
		return 0;
	}
}
