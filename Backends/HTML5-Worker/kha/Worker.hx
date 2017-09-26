package kha;

class Worker {
	public static function postMessage(m: Dynamic): Void {
		try {
			untyped __js__("self.postMessage(m)");
		}
		catch (e: Dynamic) {
			trace(e);
		}
	}

	public static function handleMessages(messageHandler: Dynamic->Void){
		untyped __js__("self.onmessage = messageHandler");
	} 
}
