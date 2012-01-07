package com.ktxsoftware.kje;

class KeyEvent {
	public var key : Key;
	public var down : Bool;
	
	public function new(key : Key, down : Bool) {
		this.key = key;
		this.down = down;
	}
}