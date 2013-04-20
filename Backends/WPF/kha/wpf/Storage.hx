package kha.wpf;

import haxe.io.Path;
import haxe.Serializer;
import haxe.Unserializer;
import kha.Storage;
import system.io.Directory;
import system.io.File;

using StringTools;

class Storage extends kha.Storage {
	
	override public function getKeyValueStorage(path:String):kha.KeyValueStorage 
	{
		try {
			return new KeyValueStorage(path);
		} catch (ex : Dynamic) {
			trace (ex);
			return null;
		}
	}
	
	override public function getTextStorage(filename:String):TextStorage 
	{
		try {
			return new TextStorage(filename);
		} catch (ex : Dynamic) {
			trace (ex);
			return null;
		}
	}
	
	override public function makeFilenameString(path:String):String {
		path = path.replace("<", "-(");
		path = path.replace(">", ")-");
		path = path.replace(":", "_");
		path = path.replace("|", ")(");
		path = path.replace("?", "(Q)");
		path = path.replace("*", "(+)");
		path = path.replace("\"", "''");
		
		return path;
	}
}

private class TextStorage implements kha.TextStorage {
	var file : Path;
	
	public function new(filename : String) {
		file = new Path(filename);
		
		Directory.CreateDirectory(file.dir);
	}
	
	public function save(content : String) {
		File.WriteAllText(file.toString(), content);
	}
	
	public function append(content : String) {
		File.AppendAllText(file.toString(), content);
	}
	
	public function load() : String {
		if (File.Exists(file.toString()))
			return File.ReadAllText(file.toString());
			
		return null;
	}
}

private class KeyValueStorage implements kha.KeyValueStorage {
	var path : String;
	
	public function new(path : String) {
		this.path = path + "/";
		
		Directory.CreateDirectory(path);
	}
	
	public function get(key : String) : Dynamic {
		var file = path + kha.Storage.getInstance().makeFilenameString(key);
		if (File.Exists(file)) {
			var data = File.ReadAllText(file);
			if (data != null) {
				return Unserializer.run(data);
			}
		}
		return null;
	}
	
	public function set(key : String, value : Dynamic) {
		var s = new Serializer();
		s.useCache = true;
		s.serialize(value);
		
		File.WriteAllText(path + kha.Storage.getInstance().makeFilenameString(key), s.toString());
	}
}