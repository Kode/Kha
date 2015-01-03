package kha;

class Worker {
	public static function postMessage(m: Dynamic): Void {
		untyped __js__("self.postMessage(m)");
	}

	public static function handleMessages(messageHandler: Dynamic->Void){
		untyped __js__("self.onmessage = messageHandler");
	} 
}
