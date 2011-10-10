package com.ktxsoftware.kje;

public class KeyEvent {
	public Key key;
	public boolean down;
	
	public KeyEvent(Key key, boolean down) {
		this.key = key;
		this.down = down;
	}
}