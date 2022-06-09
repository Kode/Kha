package kha;

class Worker {
	public static function postMessage(m: Dynamic): Void {
		try {
			js.Syntax.code("self.postMessage(m)");
		}
		catch (e:Dynamic) {
			trace(e);
		}
	}

	public static function handleMessages(messageHandler: Dynamic->Void) {
		untyped js.Syntax.code("self.onmessage = messageHandler");
	}
}
