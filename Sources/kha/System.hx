package kha;

class System {
	public static function init(title: String, width: Int, height: Int): Void { }
	
	public static function notifyOnRender(listener: Framebuffer -> Void): Void { }
	
	public static function notifyOnApplicationState(foregroundListener: Void -> Void, resumeListener: Void -> Void,
	pauseListener: Void -> Void, backgroundListener: Void-> Void, shutdownListener: Void -> Void): Void {
			
	}
}
