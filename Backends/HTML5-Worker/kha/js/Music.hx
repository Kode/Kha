package kha.js;

import js.Browser;
import js.html.AudioElement;
import js.html.ErrorEvent;
import js.html.Event;
import js.html.MediaError;
import js.Lib;

using StringTools;

class Music extends kha.Music {
	public function new() {
		super();
	}
	
	override public function play(loop: Bool = false): Void {
		
	}
	
	override public function pause(): Void {
		
	}
	
	override public function stop(): Void {
		
	}
	
	override public function getCurrentPos(): Int {
		return 0;
	}
	
	override public function getLength(): Int {
		return 0;
	}
}
