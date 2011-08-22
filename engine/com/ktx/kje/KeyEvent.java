package com.ktx.kje;

public class KeyEvent {
	public Key key;
	public boolean down;
	
	public KeyEvent(Key key, boolean down) {
		this.key = key;
		this.down = down;
	}
}