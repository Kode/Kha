package kha.flash;

import kha.Storage;
import haxe.Serializer;

class Storage extends kha.Storage {
	#if debug
	override public function getKeyValueStorage(path:String): kha.KeyValueStorage 
	{
		try {
			return new DebugDummyKeyValueStorage(path);
		} catch (ex : Dynamic) {
			trace (ex);
			return null;
		}
	}
	
	override public function getTextStorage(filename:String): kha.TextStorage 
	{
		try {
			return new DebugDummyTextStorage(filename);
		} catch (ex : Dynamic) {
			trace (ex);
			return null;
		}
	}
	#end
}

#if debug
private class DebugDummyTextStorage implements kha.TextStorage {
	var file : String;
	
	public function new(filename : String) {
		file = filename;
	}
	
	public function save(content : String) { }	
	public function append(content : String) {	}
	
	public function load() : String {
		return null;
	}
}

private class DebugDummyKeyValueStorage implements kha.KeyValueStorage {
	var path : String;
	
	public function new(path : String) {
		this.path = path + ".";
	}
	
	public function get(key : String) : Dynamic {
		var file = path + kha.Storage.getInstance().makeFilenameString(key);
		return null;
	}
	
	public function set(key : String, value : Dynamic) {
		var s = new Serializer();
		s.useCache = true;
		s.serialize(value);
		trace ('Virtually saved: ${s.toString()}');
	}
}
#end
