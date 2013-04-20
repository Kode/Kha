package kha.js;

import haxe.Serializer;
import haxe.Unserializer;
import kha.Storage;

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
	public function new() {
		super();
	}
	
	override public function getTextStorage(filename : String) : TextStorage {
		try {
			return new TextStorage(filename);
		}
		catch (ex : Dynamic) {
			trace ("TextStorage '" + filename + "' not available:");
			trace (ex);
			return null;
		}
	}
	
	override public function getKeyValueStorage(path : String) : KeyValueStorage {
		try {
			return new KeyValueStorage(path);
		}
		catch (ex : Dynamic) {
			trace ("KeyValueStorage '" + path + "' not available:");
			trace (ex);
			return null;
		}
	}
}

private class TextStorage implements kha.TextStorage {
	var storage : WebStorage;
	var filename : String;
	
	public function new(filename : String) {
		this.filename = filename;
		storage = untyped __js__("window.localStorage");
	}
	
	public function save(content : String) : Void {
		try {
			storage.setItem(filename.toString(), content);
		} catch (ex : Dynamic) {
			trace ("Save to '" + filename + "' failed:");
			trace (ex);
		}
	}
	
	public function append(content : String) {
		try {
			storage.setItem(filename.toString(), storage.getItem(filename.toString()) + content);
		} catch (ex : Dynamic) {
			trace ("Append to '" + filename + "' failed:");
			trace (ex);
		}
	}
	
	public function load() : String {
		try {
			return storage.getItem(filename.toString());
		} catch (ex : Dynamic) {
			trace ("Load from '" + filename + "' failed:");
			trace (ex);
			return null;
		}
	}
}


private class KeyValueStorage implements kha.KeyValueStorage {
	var storage : WebStorage;
	var path : String;
	
	public function new(path : String) {
		this.path = path + ".";
		storage = untyped __js__("window.localStorage");
	}
	
	public function get(key : String) : Dynamic {
		var data : String = storage.getItem(path + key);
		if (data == null)
			return null;
		
		return Unserializer.run(data);
	}
	
	public function set(key : String, value : Dynamic) : Void {
		var data : String;
		
		var serializer = new Serializer();
		serializer.useCache = true;
		serializer.serialize(value);
		data = serializer.toString();
		
		storage.setItem(path + key, data);
	}
}