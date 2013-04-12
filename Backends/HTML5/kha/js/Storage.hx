package kha.js;


typedef WebStorage = 
{
	var length : Int;
    var key : Int -> String;
	var getItem : String -> String;
	var setItem : String -> String -> Void;
	var removeItem : String -> Void;
	var clear : Void -> Void;
}

class Storage extends kha.Storage
{
	var storage : WebStorage;
	
	public function new() {
		super();
		
		storage = untyped __js__("window.localStorage");
		storage.setItem("TestKey", "TestValue");
	}
	
	override public function saveToFile(filename : String, content : String) {
		storage.setItem(filename, content);
	}
	
	override public function appendToFile(filename : String, content : String) {
		storage.setItem(filename, storage.getItem(filename) + content);
	}
	
	override public function loadFromFile(filename : String) : String {
		return storage.getItem(filename);
	}
}