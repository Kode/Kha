package kha;

import kha.graphics4.TextureFormat;
import kha.input.Gamepad;
import kha.input.Keyboard;
import kha.input.Mouse;
import kha.input.MouseImpl;
import kha.input.Surface;
import kha.System;

class SystemImpl {
	public static function init(options: SystemOptions, callback: Void -> Void): Void {
		
	}

	public static function initEx(title: String, options: Array<WindowOptions>, windowCallback: Int -> Void, callback: Void -> Void): Void {

	}
	
	public static function getScreenRotation(): ScreenRotation {
		return ScreenRotation.RotationNone;
	}
	
	public static function getTime(): Float {
		return 0;
	}
	
	public static function windowWidth(id: Int): Int {
		return 640;
	}
	
	public static function windowHeight(id: Int): Int {
		return 480;
	}
	
	public static function screenDpi(): Int {
		return 96;
	}
	
	public static function getVsync(): Bool {
		return true;
	}
	
	public static function getRefreshRate(): Int {
		return 60;
	}
	
	public static function getSystemId(): String {
		return "Empty";
	}
	
	public static function requestShutdown(): Void {
		
	}
	
	public static function getMouse(num: Int): Mouse {
		return null;
	}
	
	public static function getKeyboard(num: Int): Keyboard {
		return null;
	}
		
	public static function lockMouse(): Void {
		
	}
	
	public static function unlockMouse(): Void {
		
	}

	public static function canLockMouse(): Bool {
		return false;
	}

	public static function isMouseLocked(): Bool {
		return false;
	}

	public static function notifyOfMouseLockChange(func: Void -> Void, error: Void -> Void): Void{
		
	}

	public static function removeFromMouseLockChange(func : Void -> Void, error  : Void -> Void) : Void{
		
	}

	static function unload(): Void {
		
	}
	
	public static function canSwitchFullscreen(): Bool {
		return false;
	}

	public static function isFullscreen(): Bool {
		return false;
	}

	public static function requestFullscreen(): Void {
		
	}

	public static function exitFullscreen(): Void {
		
	}

	public function notifyOfFullscreenChange(func: Void -> Void, error: Void -> Void): Void {
		
	}


	public function removeFromFullscreenChange(func: Void -> Void, error: Void -> Void): Void {
		
	}

	public static function changeResolution(width: Int, height: Int): Void {
		
	}
	
	public static function setKeepScreenOn(on: Bool): Void {
		
	}
}
