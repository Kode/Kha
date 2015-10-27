package kha;

@:allow(kha.SystemImpl)
class System {
	private static var renderListeners: Array<Framebuffer -> Void> = new Array();
	
	public static function init(title: String, width: Int, height: Int, callback: Void -> Void): Void {
		SystemImpl.init(title, width, height, callback);
	}
	
	public static function notifyOnRender(listener: Framebuffer -> Void): Void {
		renderListeners.push(listener);
	}
	
	public static function notifyOnApplicationState(foregroundListener: Void -> Void, resumeListener: Void -> Void,
	pauseListener: Void -> Void, backgroundListener: Void-> Void, shutdownListener: Void -> Void): Void {
			
	}
	
	private static function render(framebuffer: Framebuffer): Void {
		for (listener in renderListeners) {
			listener(framebuffer);
		}
	}
}
